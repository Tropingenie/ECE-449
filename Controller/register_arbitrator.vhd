-----------------------------------------------------------
--
-- Register Arbitrator
--
-- Plug in module to arbitrate register file access. Allows
-- writing when one or fewer instructions are used, and
-- sends a "pause" signal to stop the pipeline for two
-- register instructions.
--
-- Engineer: Kai Herrero, Benjamin Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterArbitrator is
port(
    opcode_in   : in std_logic_vector(6 downto 0); -- opcode of the "current" instruction
    opcode_back : in std_logic_vector(6 downto 0); -- opcode of the "writing back" instruction
    AR          : in std_logic_vector(15 downto 0); -- Arithmetic result (data) from the "wiring back" instruction
    ra          : in std_logic_vector(2 downto 0); -- writeback register of the "writing back" instruction
    rd_2        : in std_logic_vector(2 downto 0); -- Second register from "current" instruction
    clk         : in std_logic;                     -- Clock at twice the rate of the datapath
    wr_en       : out std_logic;                    -- Write enable for writeback
    r_sel       : out std_logic_vector(2 downto 0); -- Selected register

);
end RegisterArbitrator;

architecture Behavioral of RegisterArbitrator is

--SIGNAL DECLARATIONS HERE--
    signal register_a  : STD_LOGIC_VECTOR(6 downto 0);
    signal register_d2 : STD_LOGIC_VECTOR(2 downto 0);
    signal op_in       : STD_LOGIC_VECTOR(6 downto 0);
    signal op_back     : STD_LOGIC_VECTOR(6 downto 0);
    signal result      : STD_LOGIC_VECTOR(15 downto 0);
    signal write_enable: STD_LOGIC
--COMPONENT DECLARATIONS HERE--

begin

    register_a  <= ra;
    register_d2 <= rd_2;
    op_in       <= opcode_in;
    op_back     <= opcode_back;
    result      <= AR;
    wr_en       <= 

    process(clk)

    begin
       
    end process;
end Behavioral;