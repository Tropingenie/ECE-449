-----------------------------------------------------------
--
-- Datapath
--
-- Connect the ALU, registers, and I/O while providing
-- mechanisms for further control
--
-- Ben Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is:
port();
end datapath;

begin Behaviour of datapath is

component theregister is
port(
    clk : in std_logic;
    d_in : in std_logic_vector(15 downto 0);
    d_out : out std_logic_vector(15 downto 0));
end component;

component ALU is
port(
    in1, in2 : in STD_LOGIC_VECTOR(15 downto 0); --Input 1, Input 2 16-bit inputs including op code and fortmat A(0-3)
    alu_mode : in STD_LOGIC_VECTOR(2 downto 0);  --3 bit vector that determines the ALU operation [ADD (0), ADD(1), SUB (2), MUL(3), NAND(4), SHL (5), SHR(6), TEST(7)]
    clk, rst : in STD_LOGIC;                     --clock and reset signals
    result   : out STD_LOGIC_VECTOR(2 downto 0); --3 bit result vector
    z_flag, n_flag: out STD_LOGIC                --zero and negative flag and done
    );
end component

component register_file
port(
    rst : in std_logic; clk: in std_logic;
    --read signals
    rd_index1, rd_index2 : in std_logic_vector(2 downto 0);
    rd_data1, rd_data2: out std_logic_vector(15 downto 0);
    --write signals
    wr_index: in std_logic_vector(2 downto 0);
    wr_data: in std_logic_vector(15 downto 0);
    wr_enable: in std_logic);
end component

component InstructionDecoder
--not implemented yet
end component

component RegisterArbitrator
--not implemented yet
end component

signal  opcode                       : std_logic_vector(6 downto 0);
signal  ra, rb, rc                   : std_logic_vector(2 downto 0);
signal  imm                          : std_logic_vector(3 downto 0);
signal  AR                           : std_logic_vector(15 downto 0);
signal  clk, half_clk, quarter_clk   : std_logic; -- various clock domains for ALU, Memory, and everything else respectively (avoids PLLs)


end Behaviour;