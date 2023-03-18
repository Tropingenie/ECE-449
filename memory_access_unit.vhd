library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MemoryAccessUnit is
port(
    AR, IN_PORT, RAM_READA : in std_logic_vector(15 downto 0);
    WB_DATA, OUT_PORT, RAM_WRITE : out std_logic_vector(15 downto 0);
    data_mem_sel, io_sel : in std_logic
);
end MemoryAccessUnit;


architecture Behaviour of MemoryAccessUnit is

signal M_DATA : std_logic_vector(15 downto 0);

begin

    with data_mem_sel select WB_DATA <= 
        M_DATA when '1',
        AR when '0';
        
    with IO_SEL select M_DATA <=
        IN_PORT when '1',
        RAM_READA when '0';
        
    process(io_sel) begin
        case io_sel is
            when '1' =>
                OUT_PORT <= AR;
                RAM_WRITE <= (others => 'Z');
            when others =>
                OUT_PORT <= (others => 'Z');
                RAM_WRITE <= AR;
        end case;
    end process;

end Behaviour;