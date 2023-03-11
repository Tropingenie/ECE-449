----------------------------------------------------------------------------------
-- Engineer: Kai Herrero, benjamin Lyne
-- 
-- Create Date: 03/01/2023 02:01:10 PM
-- Design Name: Format A Instuctions Testbench 
-- Module Name: Processor_testbench - Behavioral
-- Project Name: ECE 458 16 bit processor
-- Target Devices: processor
-- Description: Testbench uses the format A assembly test and simulates
-- the pipeline with instruction.
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity Processor_testbench is
end Processor_testbench;

architecture Behavioral of Processor_testbench is

--COMPONENT DECLARATIONS HERE--
component Processor port(

    clk, rst : in std_logic;
    ROM_FROM, RAM_FROM_A, RAM_FROM_B, IN_PORT, DEBUG_INSTR_IN : in std_logic_vector(15 downto 0);
    RAM_TO, OUT_PORT, RAM_ADDR_A, RAM_ADDR_B : out std_logic_vector(15 downto 0));
    
end component;

--SIGNAL DECLARATIONS HERE--
    signal clk, rst : std_logic;
    signal ROM_FROM, RAM_FROM_A, RAM_FROM_B, IN_PORT, DEBUG_INSTR_IN : std_logic_vector(15 downto 0);
    signal RAM_TO, OUT_PORT, RAM_ADDR_A, RAM_ADDR_B : std_logic_vector(15 downto 0);
    
 
begin

    UUT: processor port map(clk=>clk,rst=>rst,ROM_FROM=>ROM_FROM,RAM_FROM_A=>RAM_FROM_A,RAM_FROM_B=>RAM_FROM_B,IN_PORT=>IN_PORT,DEBUG_INSTR_IN=>DEBUG_INSTR_IN,RAM_TO=>RAM_TO,OUT_PORT=>OUT_PORT,RAM_ADDR_A=>RAM_ADDR_A,RAM_ADDR_B=>RAM_ADDR_B);


    process begin   --Clocking process, 500MhZ duty cycle
    clk <= '0';
    wait for 100 us;
    clk <= '1';
    wait for 100 us;
    end process;
    
    process begin   --behavioural process
    rst <= '0';
    DEBUG_INSTR_IN <= "0000000000000000";
    wait until (clk='1' and clk'event);
    rst <= '1';
    wait until (clk='1' and clk'event);
    rst <= '0';
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000001011010001"; --ADD r3,r2,r1
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000101011000010"; --SHL r3,2
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000011010001011"; --MUL r2,r1,r3
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0100000010000000"; --OUT r2
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    DEBUG_INSTR_IN <= "0000000000000000"; --NO OP
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait until (clk='1' and clk'event);
    wait;
    end process;
end Behavioral;
