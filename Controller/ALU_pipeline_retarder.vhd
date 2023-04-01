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
    ID_OPCODE : in std_logic_vector(6 downto 0); -- Check the opcode incoming to the ALU
    alu_stall_enable : inout std_logic
   );
end ALUPipelineRetarder;

architecture Behaviour of ALUPipelineRetarder is

signal counter : integer := 0;

begin

process(clk, rst) begin
    if rst = '1' then
        alu_stall_enable <= '0';
    elsif rising_edge(clk) then
    assert false report "Debug: ALU retarder detected clock" severity note;
        if counter > 0 then
         counter <= counter - 1;
        elsif counter = 0 and alu_stall_enable = '1' then
            alu_stall_enable <= '0';
        else
            assert false report "Debug: ALU retarder not currently stalling" severity note;
             case ID_OPCODE is 
         
             when "0000000" | "0000100" | "0000111" | "0100000" | "0100001"=>                    --NOP, NAND, TEST, OUT, IN
             -- 1 clock (no delay)
             null;       
             when "0000001" | "0000010" =>                    --ADD, SUB op
--                counter <= 0;
--                alu_stall_enable <= '1';
                    null;        
             when "0000101" | "0000110" =>  -- SHR, SHL
                assert false report "Debug: ALU retarder detected shift" severity note; 
                counter <= 3;
                alu_stall_enable <= '1';
             when "0000011" =>                    --MULT op
            
                counter <= 3;
                alu_stall_enable <= '1';
             when "UUUUUUU" | "XXXXXXX" =>
                 assert false report "Uninitialized opcode" severity note;              
             when others =>
                 NULL;
                 
            end case;
        end if;
    end if;
end process;

end Behaviour;