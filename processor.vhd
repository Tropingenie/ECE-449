-----------------------------------------------------------
--
-- Processor
--
-- Connect the ALU, registers, and I/O and integrates
-- distributed controller
--
-- Ben Lyne
--
-----------------------------------------------------------

library IEEE;
Library xpm;
use xpm.vcomponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

XPM_MEMORY_DPDISTRAM_INST : xpm_memory_dpdistram
generic map (
    ADDR_WIDTH_A => 16,            -- DECIMAL [Memory] [16 bit address but only address up to 9 bits]
    ADDR_WIDTH_B => 16,            -- DECIMAL [Instructions]
    BYTE_WRITE_WIDTH_A => 2,       -- DECIMAL
    CLOCKING_MODE => "common_clock", -- String
    MEMORY_OPTIMIZATION => "true", -- String
    MEMORY_SIZE => 1024,           -- DECIMAL
    MESSAGE_CONTROL => 0,          -- DECIMAL
    READ_DATA_WIDTH_A => 16,       -- DECIMAL
    READ_DATA_WIDTH_B => 16,       -- DECIMAL
    READ_LATENCY_A => 0,           -- DECIMAL
    READ_LATENCY_B => 0,           -- DECIMAL
    READ_RESET_VALUE_A => "0",     -- String
    READ_RESET_VALUE_B => "0",     -- String
    RST_MODE_A => "ASYNC",         -- String
    RST_MODE_B => "ASYNC",         -- String
    USE_EMBEDDED_CONSTRAINT => 0,  -- DECIMAL
    USE_MEM_INIT => 1,             -- DECIMAL
    WRITE_DATA_WIDTH_A => 16       -- DECIMAL
)
port map (
  douta => douta,   -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
  doutb => doutb,   -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
  addra => addra,   -- ADDR_WIDTH_A-bit input: Address for port A write and read operations.
  addrb => addrb,   -- ADDR_WIDTH_B-bit input: Address for port B write and read operations.
  clka => clka,     -- 1-bit input: Clock signal for port A. Also clocks port B when parameter
                    -- CLOCKING_MODE is "common_clock".             
  clkb => clkb,     -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                    -- "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".                    
  dina => dina,     -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
  ena => ena,       -- 1-bit input: Memory enable signal for port A. Must be high on clock cycles when read
                    -- or write operations are initiated. Pipelined internally.                   
  enb => enb,       -- 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read
                    -- or write operations are initiated. Pipelined internally.                 
  regcea => regcea, -- 1-bit input: Clock Enable for the last register stage on the output data path.
  regceb => regceb, -- 1-bit input: Do not change from the provided value.
  rsta => rsta,     -- 1-bit input: Reset signal for the final port A output register stage. Synchronously
                    -- resets output port douta to the value specified by parameter READ_RESET_VALUE_A.                   
  rstb => rstb,     -- 1-bit input: Reset signal for the final port B output register stage. Synchronously
                    -- resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.                  
  wea => wea        -- WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1
                    -- bit wide when word-wide writes are used. In byte-wide write configurations, each bit
                    -- controls the writing one byte of dina to address addra. For example, to
                    -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea
                    -- would be 4'b0010.
 );
 -- End of xpm_memory_dpdistram_inst instantiation

entity processor is
port(
    clk, rst : in std_logic;
    ROM_FROM, RAM_FROM_A, RAM_FROM_B, IN_PORT, DEBUG_INSTR_IN : in std_logic_vector(15 downto 0);
    RAM_TO, OUT_PORT, RAM_ADDR_A, RAM_ADDR_B : out std_logic_vector(15 downto 0)
);
end processor;

architecture Behaviour of processor is

component controller is
port(
    clk, rst : in std_logic;
    ID_opcode, EX_opcode, MEM_opcode, WB_opcode : in std_logic_vector(6 downto 0) := (others => '0');
    ID_WRITE_EN : out std_logic := '0' -- Enable writing to the register
);
end component;

component theregister is
port(
    clk, rst : in std_logic;
    d_in : in std_logic_vector(15 downto 0);
    d_out : out std_logic_vector(15 downto 0));
end component;

component InstructionFetcher is
port(
    M_INSTR : in std_logic_vector(15 downto 0); -- Input from memory
    clk, double_clk : in std_logic; -- clock at twice the rate of the datapath, PC gets double clk to strobe properly
    INSTR, M_ADDR : out std_logic_vector(15 downto 0) -- Instruction output and memory address issuing respectively
);
end component;

component InstructionDecoder is
port(
    instruction     : in std_logic_vector(15 downto 0);
    opcode_out      : out std_logic_vector(6 downto 0);
    rd_1, rd_2, ra  : out std_logic_vector(2 downto 0);
    imm             : out std_logic_vector(3 downto 0)
);
end component;

component register_file is
port(
    rst, clk: in std_logic;
    --read signals
    rd_index1, rd_index2 : in std_logic_vector(2 downto 0);
    rd_data1, rd_data2: out std_logic_vector(15 downto 0);
    --write signals
    wr_index: in std_logic_vector(2 downto 0);
    wr_data: in std_logic_vector(15 downto 0);
    wr_enable: in std_logic);
end component;

component ALU is
port ( 
    in1, in2 : in STD_LOGIC_VECTOR(15 downto 0);  --Input 1, Input 2 16-bit inputs including op code and fortmat A(0-3)
    op_code  : in STD_LOGIC_VECTOR(6 downto 0);   --Op code of current instuction, used to deduce operation in ALU
    clk, rst : in STD_LOGIC;                      --clock and reset signals
    result   : out STD_LOGIC_VECTOR(15 downto 0); --3 bit result vector
    z_flag, n_flag, o_flag: out STD_LOGIC         --zero, negative and overflow flags
    );
end component;

component MemoryAccessUnit is
port(
    opcode  : in        std_logic_vector(6 downto 0);
    AR      : in        std_logic_vector(15 downto 0);  -- Result from ALU
    M_ADDR  : out       std_logic_vector(15 downto 0);  -- Address line to memory
    M_DATA  : inout     std_logic_vector(15 downto 0);  -- Data line to/from mem
    DATA_OUT: out       std_logic_vector(15 downto 0);  -- Output to MEM/WB
    clk, rst: in        std_logic                       -- Clock four times as fast as processor to finish before memory strobes
);
end component;

signal half_clk, quarter_clk            : std_logic := '0'; -- various clock domains for ALU, Memory, and everything else respectively (avoids PLLs)
signal counter                          : integer := 1; -- Counter for clock division
signal IF_INSTR, ID_INSTR               : std_logic_vector(15 downto 0); -- Instruction from various stages
signal ID_opcode, EX_opcode, 
    MEM_opcode, WB_opcode               : std_logic_vector(6 downto 0); -- opcode during various stages
signal ID_ra, ID_rb, ID_rc, 
    EX_ra, MEM_ra, WB_ra                : std_logic_vector(2 downto 0); -- Register addresses in various stages
signal ID_imm                           : std_logic_vector(3 downto 0); -- Immediate value decoded in the ID stage
signal ID_WRITE_EN                      : std_logic; -- Register file write enable (for writeback)
signal EX_AR, MEM_AR                    : std_logic_vector(15 downto 0); -- AR in various stages
signal ID_data1, ID_data2, EX_data1, 
    EX_data2                            : std_logic_vector(15 downto 0); -- Data from register file for various stages
signal ID_RSEL                          : std_logic_vector(2 downto 0); -- Selected address of register arbitrator
signal ID_RC_DATA                       : std_logic_vector(15 downto 0); -- Intermediate signal for holding contents of RC while selecting if data is from registers or an immediate
signal IDEX_CONTROL_BITS_IN, 
    IDEX_CONTROL_BITS_OUT, 
    EXMEM_CONTROL_BITS_IN, 
    EXMEM_CONTROL_BITS_OUT, 
    MEMWB_CONTROL_BITS_IN, 
    MEMWB_CONTROL_BITS_OUT              : std_logic_vector(15 downto 0); -- Intermediate signals to concatenate control bits for input into a fixed-width register
signal EX_Flags, MEM_Flags, WB_Flags    : std_logic_vector(2 downto 0); -- ALU flags
signal MEM_WB_DATA, MEM_DATA            : std_logic_vector(15 downto 0); -- Intermediate signals for MEM stage to select what to pass to WB
signal MEM_OPCODE_VAL                   : unsigned(15 downto 0); -- For comparison using <, >, etc
signal WB_DATA                          : std_logic_vector(15 downto 0); -- Data to write back in WB stage

begin

process (clk) begin   --Clocking process, based on counter incrementing on each clock

    counter <= counter + 1;
    case counter is
        when 1 =>
            null;
        when 2 =>
            half_clk <= not half_clk;
        when 3 =>
            null;
        when 4 =>
            half_clk <= not half_clk;
            quarter_clk <= not quarter_clk;
            counter <= 1;
        when others =>
            assert false report "Clock counter out of range" severity failure;
    end case;
end process;

-- Controller

MAINCONT    :   controller port map(clk=>clk, rst=>rst, ID_opcode=>ID_opcode, EX_opcode=>EX_opcode, MEM_opcode=>MEM_opcode, WB_opcode=>WB_opcode, ID_WRITE_EN=>ID_WRITE_EN);

--==============================================================================
--==============================================================================

-- Start of the pipeline
--==============================================================================
-- Instruction Fetch

--I_FETCH :     InstructionFetcher port map(M_INSTR=>RAM_FROM_B, clk=>half_clk, double_clk=>clk, INSTR=>IF_INSTR, M_ADDR=>RAM_ADDR_B);
IF_INSTR <= DEBUG_INSTR_IN;
R_IFID  :     theregister        port map(clk=>quarter_clk, rst=>rst, d_in=>IF_INSTR, d_out=>ID_INSTR); -- IF/ID stage register

--==============================================================================
-- Instruction Decode

I_DECODE:     InstructionDecoder port map(instruction=>ID_INSTR, opcode_out=>ID_opcode, 
                                          rd_1=>ID_rb, rd_2=>ID_rc, ra=>ID_ra, imm=>ID_imm);

REG_FILE:     register_file      port map(clk=>clk, rst=>rst, rd_index1=>ID_rb, 
                                          rd_index2=>ID_rsel, rd_data1=>ID_data1, 
                                          rd_data2=>ID_RC_DATA, wr_index=>WB_ra, 
                                          wr_data=>WB_DATA, wr_enable=>ID_WRITE_EN);

ID_rsel <= ID_rc;  

-- MUX controlled by register arbitrator
--process(ID_WRITE_EN) begin
--    case(ID_WRITE_EN) is
--        when '0' => ID_rsel <= ID_rc;   
--        when '1' => ID_rsel <= WB_ra;
--        when others => null;
--    end case;
--end process;

-- Register/Immediate select for input to the ALU
 ID_DATA2 <=  x"000" & ID_imm when ID_opcode = "0000110" or ID_opcode = "0000101" else -- Format A2 needs the immediate as the second operand
              ID_RC_DATA; -- All other instructions just use the second operand verbatim (may be 0 if there is no second operand)

-- Concatenate control bits for input to register
IDEX_CONTROL_BITS_IN <= ID_opcode & ID_ra & "------"; -- Contains: opcode(15 downto 9), ra (8 downto 6)

-- Inter-stage registers                
R_IDEX_1:     theregister port map(clk=>quarter_clk, rst=>rst, d_in=>ID_data1, d_out=>EX_DATA1); -- ALU in1
R_IDEX_2:     theregister port map(clk=>quarter_clk, rst=>rst, d_in=>ID_data2, d_out=>EX_DATA2); -- ALU in2
R_IDEX_3:     theregister port map(clk=>quarter_clk, rst=>rst, d_in=>IDEX_CONTROL_BITS_IN, 
                                   d_out=>IDEX_CONTROL_BITS_OUT);

--==============================================================================
-- Execute
EX_opcode <= IDEX_CONTROL_BITS_OUT(15 downto 9);
EX_ra <= IDEX_CONTROL_BITS_OUT(8 downto 6);
theALU: ALU port map(in1=>EX_DATA1, in2=>EX_DATA2, op_code=>EX_opcode, clk=>clk, 
                     rst=>rst, result=> EX_AR, Z_flag=>EX_flags(2), N_flag=>EX_flags(1), 
                     O_Flag=>EX_flags(0));

-- Concatenate control bits for input to register                     
EXMEM_CONTROL_BITS_IN <= EX_OPCODE & EX_FLAGS & EX_RA & "---"; -- Contains: Opcode(15 downto 9), Flags (8 downto 6), ra (5 downto 3)

-- Inter-stage registers 
R_EXMEM_1: theregister port map(clk=>quarter_clk, rst=>rst, d_in=>EX_AR, d_out=>MEM_AR); -- ALU output (AR)
R_EXMEM_2: theregister port map(clk=>quarter_clk, rst=>rst, d_in=>EXMEM_CONTROL_BITS_IN, 
                                d_out=>EXMEM_CONTROL_BITS_OUT);

--==============================================================================
-- Memory
MEM_OPCODE <= EXMEM_CONTROL_BITS_OUT(15 downto 9);
MEM_FLAGS <= EXMEM_CONTROL_BITS_OUT(8 downto 6);
MEM_RA <= EXMEM_CONTROL_BITS_OUT(5 downto 3);
MEM_OPCODE_VAL <= unsigned("000000000" & MEM_OPCODE);
-- NOTE: Memory access not implemented yet (waiting until IN, OUT, and L format instructions are implemented)
-- Uncomment the following line once memory and memory control is to be implemented
--MEM:    MemoryAccessUnit port map(opcode=>MEM_OPCODE, clk=>clk, rst=>rst, AR=>MEM_AR,M_ADDR=>);

-- Select AR from ALU or data from memory to pass to WB stage
MEM_WB_DATA <= MEM_AR when MEM_opcode_val < 7 else
           MEM_DATA when (MEM_opcode_val >= 16 and MEM_opcode_val <= 19) or MEM_opcode_val = 32 or MEM_opcode_val = 33 else
           (others=>'-');--don't care

-- Concatenate control bits for input to register
MEMWB_CONTROL_BITS_IN <= MEM_OPCODE & MEM_FLAGS & MEM_RA & "---"; -- Contains: Opcode(15 downto 9), Flags (8 downto 6), ra (5 downto 3)

-- Inter-stage registers        
R_MEMWB_1: theregister port map(clk=>quarter_clk, rst=>rst, d_in=>MEM_WB_DATA, d_out=>WB_DATA);
R_MEMWB_2: theregister port map(clk=>quarter_clk, rst=>rst, d_in=>MEMWB_CONTROL_BITS_IN, 
                                d_out=>MEMWB_CONTROL_BITS_OUT);
 
 --==============================================================================
 -- Writeback
 WB_OPCODE <= MEMWB_CONTROL_BITS_OUT(15 downto 9);
 WB_FLAGS <= MEMWB_CONTROL_BITS_OUT(8 downto 6);
 WB_RA <= MEMWB_CONTROL_BITS_OUT(5 downto 3);

end Behaviour;