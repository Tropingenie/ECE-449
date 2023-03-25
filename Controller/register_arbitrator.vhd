-----------------------------------------------------------
--
-- Register Arbitrator
--
-- Stalls the pipeline on data hazards.
--
-- Engineer: Kai Herrero, Benjamin Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterArbitrator is
port(
    ID_opcode, WB_opcode            : in std_logic_vector(6 downto 0);
    ID_rd_1, ID_rd_2, ID_wr, WB_wr  : in std_logic_vector(2 downto 0);
    clk, rst, stall_IFID            : in std_logic;
    stall_IDEX                      : out std_logic
    );
end RegisterArbitrator;

architecture Behavioral of RegisterArbitrator is

--SIGNAL DECLARATIONS HERE--
    type reg_array is array (integer range 0 to 7) of std_logic;
    signal reg_checkout : reg_array;
    signal read_1, read_2, ID_write, WB_write : integer;

begin
    read_1   <= to_integer(unsigned(ID_rd_1));
    read_2   <= to_integer(unsigned(ID_rd_2));
    ID_write <= to_integer(unsigned(id_wr));
    WB_write <= to_integer(unsigned(wb_wr));
    

    process(clk, rst)
    begin
        if rst = '1' then
            for i in 0 to 7 loop
                reg_checkout(i)<= '0';
            end loop;
           stall_IDEX <= '0'; 
        end if;
        if(RISING_EDGE(clk)) then
            
            -- Stall pipeline when trying to read from a checked out register, and check out the writeback register when proceeding
            case(ID_opcode) is
                when "0000001" | "0000010" | "0000011" | "0000100" | "0000101" | "0000110" | "0100000"=> -- Format A that use registers
                    if reg_checkout(read_1) = '1' or reg_checkout(read_2) = '1' then
                        stall_IDEX <= '1';
                    else
                        reg_checkout(ID_write) <= '1';
                        stall_IDEX <= '0';
                    end if; 
                when others =>
                    null;
              end case; 
            
            -- Check registers back in
            case(WB_opcode) is
                  when "0000001" | "0000010" | "0000011" | "0000100" | "0000101" | "0000110" | "0100000"=> -- Format A that use registers
                      reg_checkout(WB_write) <= '0';
                  when others =>
                      null;
                end case;   

      end if;
    end process;
end Behavioral;