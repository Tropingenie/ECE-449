----------------------------------------------------------------------------------
-- Create Date: 03/11/2023 10:28:05 AM
-- Design Name: ALU Pipeline Retarder
-- Controls whether to stall the pipeline in order to retard the processing speed
-- to allow for ALU operations to complete on time.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_MISC.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALUPipelineRetarder is
  Port (
    clk, rst : in std_logic;
    ex_opcode : in std_logic_vector(6 downto 0);
    alu_stall_enable : inout std_logic := '0'-- inout used to feedback internally
   );
end ALUPipelineRetarder;

architecture Behaviour of ALUPipelineRetarder is

signal counter : integer := 0;

begin

process(clk, rst) begin
    if rst = '1' then
        alu_stall_enable <= '0';
    elsif rising_edge(clk) then
         case ex_opcode is 
     
         when "0000000" | "0000100" | "0000101" | "0000110" | "0000111" | "0100000" | "0100001"=>                    --NOP, NAND, SHR, SHL, TEST, OUT, IN
         -- 1 clock (no delay)
         null;     
             
         when "0000001" | "0000010" =>                    --ADD, SUB op
        -- 2 clocks (1 clock delay)
            if alu_stall_enable = '1' then
                alu_stall_enable <= '0';
            else
                alu_stall_enable <= '1';
            end if;
         when "0000011" =>                    --MULT op
         -- 4 clocks (3 clock delay)
            if alu_stall_enable = '1' then
              case(counter) is
                when 0 | 1 =>
                    counter <= counter + 1; 
                when 2 =>
                    alu_stall_enable <= '0';
                    counter <= 0;
                when others =>
                    assert false report "ALU stall counter out of range" severity failure;
              end case;
            else
                 alu_stall_enable <= '1';
            end if;
             
         when "UUUUUUU" | "XXXXXXX" =>
             assert false report "Uninitialized opcode" severity note;    
                     
         when others =>
             assert false report "ALU operation out of range" severity failure;
             
        end case;
    end if;
end process;

end Behaviour;