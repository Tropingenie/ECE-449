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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity processor is:
port(
    rst : in std_logic;
    ROM_FROM, RAM_FROM_A, RAM_FROM_B, IN_PORT : in std_logic_vector(15 downto 0);
    RAM_TO, OUT_PORT, RAM_ADDR_A, RAM_ADDR_B : out std_logic_vector(15 downto 0);
);
end processor;

architecture Behaviour of processor is

component theregister is
port(
    clk : in std_logic;
    d_in : in std_logic_vector(15 downto 0);
    d_out : out std_logic_vector(15 downto 0));
end component;

component InstructionFetcher is
port(
    M_INSTR : in std_logic_vector(15 downto 0); -- Input from memory
    clk, double_clk : in std_logic; -- clock at twice the rate of the datapath, PC gets double clk to strobe properly
    INSTR, M_ADDR : out std_logic_vector(15 downto 0); -- Instruction output and memory address issuing respectively
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

component RegisterArbitrator is
port(
    opcode_in   : in std_logic_vector(6 downto 0); -- opcode of the "current" instruction
    opcode_back : in std_logic_vector(6 downto 0); -- opcode of the "writing back" instruction
    AR          : in std_logic_vector(15 downto 0); -- Arithmetic result (data) from the "wiring back" instruction
    ra          : in std_logic_vector(2 downto 0); -- writeback register of the "writing back" instruction
    rd_2        : in std_logic_vector(2 downto 0); -- Second register from "current" instruction
    clk         : in std_logic;                      -- Clock at 2x the datapath
    wr_en       : out std_logic;                    -- Write enable for writeback
    r_sel       : out std_logic_vector(2 downto 0) -- Selected register
);
end component;

component ALU is
port(
    in1, in2 : in STD_LOGIC_VECTOR(15 downto 0); --Input 1, Input 2 16-bit inputs including op code and fortmat A(0-3)
    alu_mode : in STD_LOGIC_VECTOR(2 downto 0);  --3 bit vector that determines the ALU operation [ADD (0), ADD(1), SUB (2), MUL(3), NAND(4), SHL (5), SHR(6), TEST(7)]
    clk, rst : in STD_LOGIC;                     --clock and reset signals
    result   : out STD_LOGIC_VECTOR(2 downto 0); --3 bit result vector
    z_flag, n_flag: out STD_LOGIC                --zero and negative flag and done
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

signal  clk, half_clk, quarter_clk      : std_logic := '0'; -- various clock domains for ALU, Memory, and everything else respectively (avoids PLLs)
signal counter                          : integer := 1; -- Counter for clock division
signal fetched_instr                    : std_logic_vector(15 downto 0); -- Instruction from IF stage
signal decoding_instr                   : std_logic_vector(15 downto 0); -- Instruction at start of ID stage
signal ID_opcode, EX_opcode, MEM_opcode, WB_opcode : std_logic_vector(6 downto 0); -- opcode during various stages
signal ID_ra, ID_rb, ID_rc, ID_r_sel, EX_ra, MEM_ra, WB_ra   : std_logic_vector(2 downto 0); -- Register addresses in various stages
signal ID_imm                           : std_logic_vector(3 downto 0); -- Immediate value decoded in the ID stage
signal R_wr_en                          : std_logic; -- Register file write enable
signal EX_AR, MEM_AR, WB_AR             : std_logic_vector(15 downto 0); -- AR in various stages
signal ID_data1, ID_data2, EX_data1, EX_data2 : std_logic_vector(15 downto 0); -- Data from register file for various stages
signal ID_ALU_IN_2                      : std_logic_vector(15 downto 0); -- Intermediate signal for selecting if data is from regisers or an immediate

begin

process begin   --Clocking process, clk has 20us duty cycle
    counter <= counter + 1
    case counter is:
        when 1 =>
            clk <= not clk;
        when 2 =>
            clk <= not clk;
            half_clk <= not half_clk;
        when 3 =>
            clk <= not clk;
        when 4 =>
            clk <= not clk;
            half_clk <= not half_clk;
            quarter_clk <= not quarter_clk;
            counter <= 1;
        when others =>
            assert false report "Clock counter out of range" severity failure;
    end case;
    wait for 10 us;
end process;

IFET    :     InstructionFetcher port map(M_INST=>RAM_FROM_B, clk=>half_clk, double_clk=>clk, INSTR=>fetched_instr, M_ADDR=>RAM_ADDR_B);
R_IFID  :     theregister        port map(clk=>quarter_clk, d_in=>fetched_instr, d_out=>decoding_instr); -- IF/ID stage register
ID      :     InstructionDecoder port map(instruction=>decoding_instr, opcode_out=>ID_opcode, rd_1=>ID_rb, rd_2=>ID_rc, ra=>ID_ra, imm=>ID_imm);
R_ARB   :     RegisterArbitrator port map(opcode_in=>ID_opcode, opcode_back=>WB_opcode, ra=>WB_ra, rd_2=>ID_rc, clk=>half_clk, wr_en=>R_wr_en, r_sel=ID_r_sel); -- Register Arbitrator
R_FILE  :     register_file      port map(clk=>half_clk, rst=>rst, rd_index1=>ID_rb, rd_index2=>ID_rsel, rd_data1=>ID_data1, rd_data2=>ID_data2, wr_index=>ID_r_sel, wr_data=>WB_AR, wr_enable=>R_wr_en);

ID_ALU_IN_2 <=  ID_imm when ID_opcode = x"6" or ID_opcode = x"7" else -- Format A2
                ID_data2;




R_IDEX  :


end Behaviour;