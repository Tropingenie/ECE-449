----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2023 03:48:02 PM
-- Design Name: 
-- Module Name: register_arbitrator_testbench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_arbitrator_testbench is
end register_arbitrator_testbench;

architecture Behavioral of register_arbitrator_testbench is
    component register_arbitrator Port(
    opcode_in   : in std_logic_vector(6 downto 0);  -- opcode of the "current" instruction
    opcode_back : in std_logic_vector(6 downto 0);  -- opcode of the "writing back" instruction
    AR_in       : in std_logic_vector(15 downto 0); -- Arithmetic result (data) from the "wiring back" instruction
    ra          : in std_logic_vector(2 downto 0);  -- writeback register of the "writing back" instruction
  --rd_2        : in std_logic_vector(2 downto 0);  -- Second register from "current" instruction [UNUSED]
    clk         : in std_logic;                     -- Clock at twice the rate of the datapath
    AR_out      : out std_logic_vector(15 downto 0);-- Output numeric result of the data
    wr_en       : out std_logic;                    -- Write enable for writeback
    r_sel       : out std_logic_vector(2 downto 0)  -- Selected register
    );
begin


end Behavioral;
