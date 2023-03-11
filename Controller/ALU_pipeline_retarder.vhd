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
        if counter > 0 then
         counter <= counter - 1;
        else
            alu_stall_enable <= '0';
             case ex_opcode is 
         
             when "0000000" | "0000100" | "0000111" | "0100000" | "0100001"=>                    --NOP, NAND, TEST, OUT, IN
             -- 1 clock (no delay)
             null;       
             when "0000001" | "0000010" =>                    --ADD, SUB op
            -- 2 clocks (1 clock delay)
                counter <= 1;
                alu_stall_enable <= '1';        
             when "0000101" | "0000110" =>  -- SHR, SHL
             -- 3 clocks (2 clock delay)
                counter <= 2;
                alu_stall_enable <= '1';
             when "0000011" =>                    --MULT op
             -- 4 clocks (3 clock delay)
                counter <= 3;
                alu_stall_enable <= '1';
             when "UUUUUUU" | "XXXXXXX" =>
                 assert false report "Uninitialized opcode" severity note;              
             when others =>
                 assert false report "ALU operation out of range" severity failure;
                 
            end case;
        end if;
    end if;
end process;

end Behaviour;