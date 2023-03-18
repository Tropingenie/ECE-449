----------------------------------------------------------------------------------

-- Engineer: Ben Lyne
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MemoryArbiter is
    Port (
           mem_opcode: in std_logic_vector(6 downto 0);
           data_mem_sel : out STD_LOGIC; -- 1 when reading from data memory, 0 when passing AR from ALU/writing to memory
           instr_mem_sel : out STD_LOGIC; -- 1 when using RAM, 0 when using ROM
           io_sel : out STD_LOGIC; -- 1 when using IO, 0 when using memory
           ram_ena, ram_enb, we : out std_logic
           ); 
end MemoryArbiter;

architecture Behavioral of MemoryArbiter is

begin
-- ==================================================
process(mem_opcode) begin
    case(mem_opcode) is
        when "0100001" =>               -- IN
            data_mem_sel <= '1';
            io_sel <= '1';
            ram_ena <= '0';
            we <= '0';
        when "0010000" | "0010010" =>   --LOAD, LOADIMM
            data_mem_sel <= '1';
            io_sel <= '0';
            ram_ena <= '1';
            we <= '0';
        when "0100000" =>               -- OUT
            data_mem_sel <= '0';
            io_sel <= '1';
            ram_ena <= '0';
            we <= '0';   
        when "0010001" => -- STORE
            data_mem_sel <= '0';
            io_sel <= '0';
            ram_ena <= '1';
            we <= '1';           
        when others =>
            data_mem_sel <= '0';
            ram_ena <= '0';
            io_sel <= '0';
            we <= '0';    
    end case;
end process;
-- ==================================================


-- ==================================================
-- ROM/RAM selection
--PLACEHOLDER                
instr_mem_sel <= --'1' when instr_addr = "" else
                 '0';
                 
ram_enb <= '0';
-- ==================================================

end Behavioral;
