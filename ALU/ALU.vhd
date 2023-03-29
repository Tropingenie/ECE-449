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
    op_code  : in STD_LOGIC_VECTOR(6 downto 0);   --Op code of current instuction, used to deduce operation in ALU
    clk, rst : in STD_LOGIC;                      --clock and reset signals
    result   : out STD_LOGIC_VECTOR(15 downto 0); --3 bit result vector
    z_flag, n_flag, o_flag: out STD_LOGIC         --zero, negative and overflow flags
    );
end ALU;

architecture Behavioral of ALU is

    --SIGNAL DECLARATIONS HERE--
    signal data1     : signed(15 downto 0);      --in1 signed 16 bit vector
    signal data2     : signed(15 downto 0);      --in2 signed 16 bit vector
    signal data3     : signed(15 downto 0);      --result 16 bit signed vector
    signal mult_ofr  : signed (31 downto 0);     --cheat 32 bit internal register for multiply overflow
    signal shift_amt : integer;                  --integer amount to shift
        
    --COMPONENT DECLARATIONS HERE--
    
begin

    data1 <= signed(in1(15 downto 0));           --input in1 vector onto data1 as a signed bit
    data2 <= signed(in2(15 downto 0));           --input in2 vector onto data2 as a signed bit
    
    process(clk,rst) 
    
    begin    
    if (rst = '1') then
    result <= (others => '0');
    --Reset Values
    z_flag <= '0';
    n_flag <= '0';
    o_flag <= '0';
    shift_amt <= 0;
    
    elsif(RISING_EDGE(clk)) then
        case op_code is 
        
            when "0000000" =>                               --NOP
                data3 <= (others => '0');        
                
            when "0000001" =>                               --ADD op (OVERFLOW NOT CONSIDERED)
                if (data2 + data1) = 0 then
                    data3 <= data1 + data2;
                    z_flag <= '1';
                else
                    if to_integer(signed(data3)) < 0 then   --check for negative result from an ADD
                        n_flag <= '1';
                    else
                        n_flag <= '0';
                        z_flag <= '0';
                    end if;
                    
                    data3 <= data1 + data2;
                    o_flag <= '0';
                                       
                end if;
                
            when "0000010" =>                               --SUB op (UNDERFLOW NOT CONSIDERED)
                if( to_integer(signed(data2)) > to_integer(signed(data1)) ) then
                    n_flag <= '1';
                elsif( to_integer(signed(data1)) - to_integer(signed(data2)) = 0 ) then
                    z_flag <= '1';
                else
                    data3 <= data1 - data2;
                    n_flag <= '0';
                    z_flag <= '0';
                    
                end if;                   
                
            when "0000011" =>                               --MULT op (No negative operands)
                if( (to_integer(signed(data1))) * (to_integer(signed(data2))) > integer(65536)) then
                    o_flag <= '1';
                elsif( to_integer(signed(data1)) * to_integer(signed(data2)) = 0) then
                    z_flag <= '1';
                    data3 <= X"0000";
                elsif (to_integer(signed(data1)) < 0)then
                    n_flag <= '1';
                elsif (to_integer(signed(data2)) < 0) then
                    n_flag <= '1';
                else
                    mult_ofr <= data1 * data2;
                    data3 <= mult_ofr(15 downto 0);
                    n_flag <= '0';
                    z_flag <= '0';
                    o_flag <= '0';                    
                end if;
              
            when "0000100" =>                               --NAND op
                data3 <= data1 NAND data2;       
                
            when "0000101" =>                               --SHFT R op
                shift_amt <= to_integer(unsigned(in2(3 downto 0)));
                data3 <= SHIFT_LEFT(data1, shift_amt);      --currently sign extends for 2's complement
                
            when "0000110" =>                               --SHFT L op
                shift_amt <= to_integer(unsigned(in2(3 downto 0)));
                data3 <= SHIFT_RIGHT(data1, shift_amt);     --currently sign extends
                
            when "0000111" =>                               --TEST Op
                if (data1 = b"0000000000000000") then
                    z_flag <= '1';
                elsif data1(15) = '1' then
                    n_flag <= '1';
                else
                    z_flag <= '0';
                    n_flag <= '0';
                end if;

            when "0100000"|"0010011" =>                    --OUT, MOV Op
            data3 <= data1;

            when "0100001" =>                               --IN Op
            --???
            
            when "0010010" =>           --LOADIMM
                if in2(8) = '1' then -- bit 8 is "hacked" to be the m.l flag
                    data3 <= signed(in2(7 downto 0)&in1(7 downto 0));
                else
                    data3 <= signed(in1(15 downto 8) & in2(7 downto 0));
                end if;
                
            when "UUUUUUU" | "XXXXXXX" =>
                assert false report "Uninitialized data in ALU" severity note;    
                        
            when others =>
                assert false report "ALU operation out of range" severity failure;
                
           end case;
           
        result <= STD_LOGIC_VECTOR(data3(15 downto 0));     --Typecast data3 back into result vector
        
        end if;         
    end process; 
end Behavioral;
