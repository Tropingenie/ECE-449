----------------------------------------------------------------------------------
-- Engineer: Kai Herrero, Benjamin Lyne
-- 
-- Create Date: 02/06/2023 04:18:06 PM
-- Design Name: ALU
-- Module Name: ALU - Behavioral
-- Project Name: 16 Bit Processor 
-- Description: This is the ALU for the 16 Bit Processor Project
-- Notes: Overflow flag needs to be implemented, currently multiply just ignores overflow
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is

port ( 
    in1, in2 : in STD_LOGIC_VECTOR(15 downto 0);  --Input 1, Input 2 16-bit inputs including op code and fortmat A(0-3)
    alu_mode : in STD_LOGIC_VECTOR(2 downto 0);   --3 bit vector that determines the ALU operation [ADD (0), ADD(1), SUB (2), MUL(3), NAND(4), SHL (5), SHR(6), TEST(7)]
    clk, rst : in STD_LOGIC;                      --clock and reset signals
    result   : out STD_LOGIC_VECTOR(15 downto 0); --3 bit result vector
    z_flag, n_flag, o_flag: out STD_LOGIC         --zero, negative and overflow flags
    );
end ALU;

architecture Behavioral of ALU is

    --SIGNAL DECLARATIONS HERE--
    signal data1 : signed(15 downto 0); --in1 signed 16 bit vector
    signal data2 : signed(15 downto 0); --in2 signed 16 bit vector
    signal data3 : signed(15 downto 0); --result 16 bit signed vector
    signal shift_amt : integer;         --integer amount to shift
        
    --COMPONENT DECLARATIONS HERE--
    component BarrelShifter is          --UNUSED ATM
        port(
         direction : in std_logic;      -- Right shift is "positive" == one
         shift_amount : in std_logic_vector(3 downto 0);
         rin : in std_logic_vector(15 downto 0);
         rout : out std_logic_vector(15 downto 0));
    end component;
    
begin

    data1 <= signed(in1);               --input in1 vector onto data1 as a signed bit
    data2 <= signed(in2);               --input in2 vector onto data2 as a signed bit
    
    process(clk,rst) 
    
    begin    
    if (rst = '1') then
    result <= (others => '0');
    
    elsif(RISING_EDGE(clk)) then
        case alu_mode is 
        
            when "000" =>
                result <= (others => '0');   --NOP
                
            when "001" => 
                data3 <= data1 + data2;      --ADD op
                
            when "010" => 
                data3 <= data1 - data2;    --SUB op
                
            when "011" => 
                data3 <= data1 * data2;   --Need to find out where overflow goes
              
            when "100" => 
                data3 <= data1 NAND data2;                  --NAND op
                
            when "101" =>                                   --SHFT R op
                shift_amt <= to_integer(unsigned(in1(8 downto 6)));
                
                data3 <= SHIFT_LEFT(data1, shift_amt);
                
            when "110" =>                                   --SHFT L op
                shift_amt <= to_integer(unsigned(in1(8 downto 6)));
                data3 <= SHIFT_RIGHT(data1, shift_amt);     --currently sign extends
                
            when "111" =>                                   --TEST Op
                if (data1 = (others=>'0')) then
                    z_flag <= '1';
                elsif data1(15) = '1' then
                    n_flag <= '1';
                end if;
                    
            when others =>
                assert false report "ALU operation out of range" severity failure;
                
           end case;
           
        result <= STD_LOGIC_VECTOR(data3);
        
        end if;         
    end process; 
end Behavioral;
