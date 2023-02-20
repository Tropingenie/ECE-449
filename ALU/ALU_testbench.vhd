----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2023 09:28:57 AM
-- Design Name: 
-- Module Name: ALU_testbench - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_testbench is  
end ALU_testbench;

architecture Behavioral of ALU_testbench is
    component ALU Port ( 
    in1,in2 : in STD_LOGIC_VECTOR(15 downto 0);
    alu_mode : in STD_LOGIC_VECTOR(2 downto 0);
    clk, rst : in STD_LOGIC;
    result : out STD_LOGIC_VECTOR(15 downto 0);
    --check : out signed(15 downto 0);
    z_flag, n_flag, o_flag : out STD_LOGIC);
    end component;
    
    signal in1,in2 : STD_LOGIC_VECTOR(15 downto 0);
    signal alu_mode : STD_LOGIC_VECTOR(2 downto 0);
    signal clk,rst : STD_LOGIC;
    signal result : STD_LOGIC_VECTOR(15 downto 0);
    --signal check : signed(15 downto 0);
    signal z_flag, n_flag, o_flag : STD_LOGIC;
    
begin
    
    UUT: ALU port map(in1=>in1, in2=>in2, alu_mode=>alu_mode, clk=>clk, rst=>rst, result=>result, z_flag=>z_flag, n_flag=>n_flag, o_flag=>o_flag);
    
    process begin   --Clocking process, 20us duty cycle
    clk <= '0';
    wait for 10 us;
    clk <= '1';
    wait for 10 us;
    end process;
    
    process begin   --behavioural process
    rst <= '1';
    in1 <= "0000000000000000";
    in2 <= X"0000";
    alu_mode <= "000";

    wait until (clk='0' and clk'event); wait until (clk='1' and clk'event); wait until (clk='1' and clk'event);
    rst <= '0';

    wait until (clk='1' and clk'event); --ADD 1+2 (WORKS) [BASIC ADD]
    in1 <= b"0000000000000010";
    in2 <= b"0000000000000001";
    alu_mode <= "001";
    
    wait until (clk='1' and clk'event); --NOOP (WORKS) [NO OP]
    alu_mode <= "000";
    in1 <= b"0000000000000010";
    in2 <= b"0000000000000011";
    
    --wait until (clk='1' and clk'event); --ADD 131,071 + 1 () [OVERFLOW ADD]
    --in1 <= b"1111111111111111";
    --in2 <= b"0000000000000001";
    --alu_mode <= "001";
    
    --wait until (clk='1' and clk'event); --MULT 3 x 2 (WORKS) [BASIC MULT]
    --in1 <= b"0000000000000011";
    --in2 <= b"0000000000000010";
    --alu_mode <= "011";
    wait;
    end process;


end Behavioral;
