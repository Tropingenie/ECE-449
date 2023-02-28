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
    component RegisterArbitrator Port(
    opcode_in   : in std_logic_vector(6 downto 0);  -- opcode of the "current" instruction
    opcode_back : in std_logic_vector(6 downto 0);  -- opcode of the "writing back" instruction
    clk         : in std_logic;
    wr_en       : out std_logic);                   -- Write enable for writeback
    end component;
    
    signal opcode_in   : std_logic_vector(6 downto 0);
    signal opcode_back : std_logic_vector(6 downto 0);
    signal clk         : std_logic;
    signal wr_en       : std_logic;
    
begin

    UUT: RegisterArbitrator port map(opcode_in=>opcode_in, opcode_back=>opcode_back, clk=>clk, wr_en=>wr_en);
    
    process begin   --Clocking process, 20us duty cycle
    clk <= '0';
    wait for 10 us;
    clk <= '1';
    wait for 10 us;
    end process;
    
    process begin   --behavioural process
          
    opcode_back <= "0000001";
    wait;
    end process;


end Behavioral;
