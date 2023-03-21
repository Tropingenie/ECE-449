----------------------------------------------------------------------------------
-- Engineer: Kai Herrero, benjamin Lyne
-- 
-- Create Date: 20/03/2023 02:01:10 PM
-- Design Name: Format b Instuctions Testbench 
-- Module Name: Processor_testbench - Behavioral
-- Project Name: ECE 458 16 bit processor
-- Target Devices: processor
-- Description: Testbench uses the format b assembly test and simulates
-- the pipeline with instruction.
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Format_B_Test_2 is
end Format_B_Test_2;

architecture Behavioral of Format_B_Test_2 is

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
        DEBUG_INSTR_IN <= "1000110100001010"; --BR.SUB R4,10
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
        DEBUG_INSTR_IN <= "1000000000000000"; --BRR 0
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
        DEBUG_INSTR_IN <= "0000001010001101"; --ADD R2, R1, R5
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
        DEBUG_INSTR_IN <= "0000011001000010"; --MUL R1, R0, R2
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
        DEBUG_INSTR_IN <= "0000010110110101"; --SUB R6, R5, R5
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
        DEBUG_INSTR_IN <= "0000111110000000"; --TEST R6
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
        DEBUG_INSTR_IN <= "1000010000000010"; --BRR.z 2
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
        DEBUG_INSTR_IN <= "1000000111111011"; --BRR -5
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
        DEBUG_INSTR_IN <= "1000111000000000"; --Return
        wait;
    end process;
end Behavioral;
