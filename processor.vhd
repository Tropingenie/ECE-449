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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity processor is
port(
    clk, rst : in std_logic;
    ROM_FROM, RAM_FROM_A, RAM_FROM_B, IN_PORT : in std_logic_vector(15 downto 0);
    RAM_TO, OUT_PORT, RAM_ADDR_A, RAM_ADDR_B  : out std_logic_vector(15 downto 0);
    ram_ena, ram_enb, rom_en, ram_we              : out std_logic
);
end processor;

architecture Behaviour of processor is

component controller is
port(
    clk, pipe_clk, rst : in std_logic;
    ID_opcode, EX_opcode, MEM_opcode, WB_opcode : in std_logic_vector(6 downto 0);
    ID_WRITE_EN : inout std_logic; -- Enable writing to the register. INOUT used so we can feedback into the controller internally
    stall_en : out std_logic_vector(3 downto 0); -- Stalls according to the set bit position 0=IFID, 1=IDEX, 2=EXMEM, 3=MEMWB
    bubble : out std_logic; -- Tells the pipeline to introduce a bubble
    data_mem_sel : out STD_LOGIC; -- 1 when reading from data memory, 0 when passing AR from ALU/writing to memory
    instr_mem_sel : out STD_LOGIC; -- 1 when using RAM, 0 when using ROM
    io_sel : out STD_LOGIC; -- 1 when using IO, 0 when using memory
    br_pc      : in std_logic_vector(15 downto 0);  --Value of the PC of the branch instruction that is saved if the branch is taken
    br_instr   : in std_logic_vector(15 downto 0);  --The branch instrcution given to the BranchModule
    pc_out     : out std_logic_vector(15 downto 0); --PC output, either
    pc_br_overwrite : out std_logic;                --PC overwrite enable if branch is taken
    br_calc_en : out std_logic;
    r7_in      : in std_logic_vector(15 downto 0);  --data from r7
    r7_out     : out std_logic_vector(15 downto 0); --data to be written to r7
    reg_data_in: in std_logic_vector(15 downto 0);  --data from register file R[ra]
    n_flag     : in std_logic;                             --Negtive flag of the the test instruction issueed immidiately before the branch instruction    
    z_flag     : in std_logic;                             --Zero flag of the the test instruction issueed immidiately before the branch instruction 
    ram_ena, ram_enb, we : out std_logic 
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
    clk, rst, bubble: in std_logic;                           
    PC_IN           : in std_logic_vector(15 downto 0);         
    PC_OUT          : out std_logic_vector(15 downto 0);        
    M_INSTR         : in std_logic_vector(15 downto 0);        
    INSTR, M_ADDR   : out std_logic_vector(15 downto 0); 
    BR_INSTR        : out std_logic_vector(15 downto 0);        
    BR_PC           : out std_logic_vector(15 downto 0);
    BR_CALC_EN      : in std_logic;
    PC_OVERWRITE_VAL: in std_logic_vector (15 downto 0);      
    PC_OVERWRITE_EN : in std_logic                                    
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
    AR, IN_PORT, RAM_READA : in std_logic_vector(15 downto 0);
    WB_DATA, OUT_PORT, RAM_WRITE : out std_logic_vector(15 downto 0);
    data_mem_sel, io_sel : in std_logic
);
end component;

signal IFID_clk, IDEX_clk, 
       EXMEM_clk, MEMWB_clk             : std_logic := '0';              -- various clock signals that can be enabled or disabled
signal stall_en                         : std_logic_vector(3 downto 0);  -- Stalls according to the set bit position 0=IFID, 1=IDEX, 2=EXMEM, 3=MEMWB
signal current_pc, next_pc              : std_logic_vector(15 downto 0); -- PC register current and next PC values
signal pc_overwrite_en                  : std_logic;                     -- Allows the branch module to update the PC
signal IF_INSTR, ID_INSTR               : std_logic_vector(15 downto 0); -- Instruction from various stages
signal IF_PC_IN                         : std_logic_vector(15 downto 0); -- Instruction fetcher PC in from PC register
signal IF_PC_OUT                        : std_logic_vector(15 downto 0); -- PC register in from Instruction fetch
signal IF_BR_PC                         : std_logic_vector(15 downto 0); -- Instruction fetcher to branch module branch PC
signal IF_BR_INSTR                      : std_logic_vector(15 downto 0); -- Instruction fetcher to branch module branch instruction
signal BM_PC_OVERWRITE                  : std_logic_vector(15 downto 0); -- New PC value from branch calculation to overwrite PC register value
signal BM_BR_EN                         : std_logic;                     -- Branch calculation enable, this is on when a branch is being determined
signal ID_opcode, EX_opcode, 
    MEM_opcode, WB_opcode               : std_logic_vector(6 downto 0);  -- opcode during various stages
signal ID_ra, ID_rb, ID_rc, 
    EX_ra, MEM_ra, WB_ra                : std_logic_vector(2 downto 0);  -- Register addresses in various stages
signal ID_imm                           : std_logic_vector(3 downto 0);  -- Immediate value decoded in the ID stage
signal ID_WRITE_EN                      : std_logic;                     -- Register file write enable (for writeback)
signal EX_AR, MEM_AR                    : std_logic_vector(15 downto 0); -- AR in various stages
signal ID_data1, ID_data2, EX_data1, 
    EX_data2                            : std_logic_vector(15 downto 0); -- Data from register file for various stages
signal ID_RSEL                          : std_logic_vector(2 downto 0);  -- Selected address of register arbitrator
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
signal bubble                           : std_logic; -- Signal to indicate to IF to introduce a bubble
signal data_mem_sel, instr_mem_sel, io_sel : std_logic; -- Signals to control during memory access

signal SUBROUTINE_R7_WRITEBACK: std_logic_vector(15 downto 0); --branch subroutine r7 writeback value
begin

-- Controller

MAINCONT    :   controller port map(clk=>clk, pipe_clk=>EXMEM_clk, rst=>rst, ID_opcode=>ID_opcode, EX_opcode=>EX_opcode, 
                                    MEM_opcode=>MEM_opcode, WB_opcode=>WB_opcode, ID_WRITE_EN=>ID_WRITE_EN,
                                    stall_en=>stall_en, bubble=>bubble, data_mem_sel=>data_mem_sel, 
                                    instr_mem_sel=>instr_mem_sel, io_sel=>io_sel, ram_ena=>ram_ena,
                                    ram_enb=>ram_enb, we=>ram_we, br_pc => IF_BR_PC, br_instr => IF_BR_INSTR, pc_out => BM_PC_OVERWRITE,
                                    pc_br_overwrite => pc_overwrite_en,r7_in => EX_DATA1, r7_out => SUBROUTINE_R7_WRITEBACK,
                                    reg_data_in => EX_DATA2, n_flag => EX_FLAGS(1), z_flag => EX_FLAGS(2), br_calc_en => BM_BR_EN);
                                   

-- -- Stalls according to the set bit position 0=IFID, 1=IDEX, 2=EXMEM, 3=MEMWB                                    
IFID_clk <= clk when stall_en(0) = '0' else '0';
IDEX_clk <= clk when stall_en(1) = '0' else '0';
EXMEM_clk <= clk when stall_en(2) = '0' else '0';
MEMWB_clk <= clk when stall_en(3) = '0' else '0';

--PC Register
--==============================================================================
PC : theregister port map (clk=>IFID_CLK, d_in => IF_PC_OUT, d_out => IF_PC_IN, rst=>rst);
--==============================================================================

-- Start of the pipeline
--==============================================================================
-- Instruction Fetch

--IF_INSTR <= DEBUG_INSTR_IN;
I_FETCH :     InstructionFetcher port map(M_INSTR=>RAM_FROM_B, clk=>IFID_CLK, INSTR=>IF_INSTR, M_ADDR=>RAM_ADDR_B, 
                                          rst=>rst, pc_in=>IF_PC_IN, pc_out=>IF_PC_OUT, br_instr => IF_BR_INSTR,
                                          br_pc => IF_BR_PC, bubble=>bubble,PC_OVERWRITE_EN => pc_overwrite_en,
                                          PC_OVERWRITE_VAL => BM_PC_OVERWRITE, BR_CALC_EN => BM_BR_EN);                               
                                          
R_IFID  :     theregister        port map(clk=>IFID_clk, rst=>rst, d_in=>IF_INSTR, d_out=>ID_INSTR); -- IF/ID stage register                                       
--==============================================================================
-- Instruction Decode

I_DECODE:     InstructionDecoder port map(instruction=>ID_INSTR, opcode_out=>ID_opcode, 
                                          rd_1=>ID_rb, rd_2=>ID_rc, ra=>ID_ra, imm=>ID_imm);
                                     
REG_FILE:     register_file      port map(clk=>clk, rst=>rst, rd_index1=>ID_rb, 
                                          rd_index2=>ID_rsel, rd_data1=>ID_data1, 
                                          rd_data2=>ID_RC_DATA, wr_index=>WB_ra, 
                                          wr_data=>WB_DATA, wr_enable=>ID_WRITE_EN);

ID_rsel <= ID_rc;  

-- Register/Immediate select for input to the ALU
 ID_DATA2 <=  x"000" & ID_imm when ID_opcode = "0000110" or ID_opcode = "0000101" else -- Format A2 needs the immediate as the second operand
              ID_RC_DATA; -- All other instructions just use the second operand verbatim (may be 0 if there is no second operand)

-- Concatenate control bits for input to register
IDEX_CONTROL_BITS_IN <= ID_opcode & ID_ra & "------"; -- Contains: opcode(15 downto 9), ra (8 downto 6)

-- Inter-stage registers                
R_IDEX_1:     theregister port map(clk=>IDEX_clk, rst=>rst, d_in=>ID_data1, d_out=>EX_DATA1); -- ALU in1
R_IDEX_2:     theregister port map(clk=>IDEX_clk, rst=>rst, d_in=>ID_data2, d_out=>EX_DATA2); -- ALU in2
R_IDEX_3:     theregister port map(clk=>IDEX_clk, rst=>rst, d_in=>IDEX_CONTROL_BITS_IN, 
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
R_EXMEM_1: theregister port map(clk=>EXMEM_clk, rst=>rst, d_in=>EX_AR, d_out=>MEM_AR); -- ALU output (AR)
R_EXMEM_2: theregister port map(clk=>EXMEM_clk, rst=>rst, d_in=>EXMEM_CONTROL_BITS_IN, 
                                d_out=>EXMEM_CONTROL_BITS_OUT);

--==============================================================================
-- Memory
MEM_OPCODE <= EXMEM_CONTROL_BITS_OUT(15 downto 9);
MEM_FLAGS <= EXMEM_CONTROL_BITS_OUT(8 downto 6);
MEM_RA <= EXMEM_CONTROL_BITS_OUT(5 downto 3);
MEM_OPCODE_VAL <= unsigned("000000000" & MEM_OPCODE);

-- MEM gets forwarded data from ALU to solve latency issue for now
MEM:    MemoryAccessUnit port map(AR=>EX_AR, IN_PORT=>IN_PORT, RAM_READA=>RAM_FROM_A, WB_DATA=>MEM_WB_DATA, OUT_PORT=>OUT_PORT, RAM_WRITE=>RAM_TO, data_mem_sel=>data_mem_sel, io_sel=>io_sel);

-- Select AR from ALU or data from memory to pass to WB stage
--MEM_WB_DATA <= MEM_AR when MEM_opcode_val < 7 else
--           MEM_DATA when (MEM_opcode_val >= 16 and MEM_opcode_val <= 19) or MEM_opcode_val = 32 or MEM_opcode_val = 33 else
--           (others=>'-');--don't care

-- Concatenate control bits for input to register
MEMWB_CONTROL_BITS_IN <= MEM_OPCODE & MEM_FLAGS & MEM_RA & "---"; -- Contains: Opcode(15 downto 9), Flags (8 downto 6), ra (5 downto 3)

-- Inter-stage registers        
R_MEMWB_1: theregister port map(clk=>MEMWB_clk, rst=>rst, d_in=>MEM_WB_DATA, d_out=>WB_DATA);
R_MEMWB_2: theregister port map(clk=>MEMWB_clk, rst=>rst, d_in=>MEMWB_CONTROL_BITS_IN, 
                                d_out=>MEMWB_CONTROL_BITS_OUT);
 
 --==============================================================================
 -- Writeback
 WB_OPCODE <= MEMWB_CONTROL_BITS_OUT(15 downto 9);
 WB_FLAGS <= MEMWB_CONTROL_BITS_OUT(8 downto 6);
 WB_RA <= MEMWB_CONTROL_BITS_OUT(5 downto 3);

end Behaviour;