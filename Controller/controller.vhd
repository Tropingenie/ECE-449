-----------------------------------------------------------
--
-- Controller
--
-- All control logic and lines
--
-- Ben Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller is
    port(
        clk, rst : in std_logic;
        ID_opcode, EX_opcode, MEM_opcode, WB_opcode : in std_logic_vector(6 downto 0) := (others => '0');
        ID_WRITE_EN : out std_logic := '0' -- Enable writing to the register
    );
end controller;

architecture Behaviour of controller is

component RegisterArbitrator is
port(
    opcode_in   : in std_logic_vector(6 downto 0);  -- opcode of the "current" (ID) instruction
    opcode_back : in std_logic_vector(6 downto 0);  -- opcode of the "writing back" (WB) instruction
    clk         : in std_logic;                     -- Clock at twice the rate of the datapath
    wr_en       : out std_logic                    -- Write enable for writeback
);
end component;

begin

REG_ARB :     RegisterArbitrator port map(opcode_in=>ID_opcode, opcode_back=>WB_opcode, 
                                          clk=>clk, wr_en=>ID_WRITE_EN); -- Register Arbitrator

end Behaviour;