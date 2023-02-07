----------------------------------------------------------------------------------
-- Engineer: Kai Herrero, Benjamin Lyne
-- 
-- Create Date: 02/06/2023 04:18:06 PM
-- Design Name: ALU
-- Module Name: ALU - Behavioral
-- Project Name: 16 Bit Processor 
-- Description: This is the ALU for the 16 Bit Processoer Project
-- Revision: 0.01
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is

port ( 
    in1, in2 : in STD_LOGIC_VECTOR(15 downto 0); --Input 1, Input 2 16-bit inputs including op code and fortmat A(0-3)
    alu_mode : in STD_LOGIC_VECTOR(2 downto 0);  --3 bit vector that determines the ALU operation [ADD (0), ADD(1), SUB (2), MUL(3), NAND(4), SHL (5), SHR(6), TEST(7)]
    clk, rst : in STD_LOGIC;                     --clock and reset signals
    result   : out STD_LOGIC_VECTOR(2 downto 0); --3 bit result vector
    z_flag, n_flag: out STD_LOGIC                --zero and negative flag and done
    );
end ALU;

architecture Behavioral of ALU is

    --SIGNAL DECLARATIONS HERE--
    signal data1 : STD_LOGIC_VECTOR(15 downto 0);
    signal data2 : STD_LOGIC_VECTOR(15 downto 0);
    signal reset : STD_LOGIC;
    
    --COMPONENT DECLARATIONS HERE--
begin

    process(clk)
    
    begin    
    
    
    case alu_mode(2 downto 0) is
        --when "000" => result <= NULL;               --NOP
        when "001" => result <= in1 + in2;          --ADD op
        when "010" => result <= data1 - data2;      --SUB op
        when "011" => result <= data1 * data2;      --Need to find out where overflow goes
        when "100" => result <= data1 NAND data2;   --NAND op
        --when "101" => result <= RSH
        --when "110" => result <= LSH
        when "111" =>                               --TEST Op
            if (data1 == "0x00") begin
                z_flag <= '1'
                end
            elsif data1(15) == '1' begin
                n_flag <= '1'
                end  
       end case;             
    end process;
    
end Behavioral;
