-----------------------------------------------------------
--
-- Register Arbitrator
--
-- Decides whether to send a bubble or the instrucion based
-- on whether a register is being written back to.
--
-- Engineer: Kai Herrero, Benjamin Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterArbitrator is
port(
    ID_opcode       : in std_logic_vector(6 downto 0);
    clk, stall_IFID : in std_logic;                     
    bubble          : out std_logic                    

);
end RegisterArbitrator;

architecture Behavioral of RegisterArbitrator is

--SIGNAL DECLARATIONS HERE--
signal bubble_sent : std_logic;

begin
    

    process(clk)
    begin
        if(RISING_EDGE(clk)) then
        case(ID_opcode) is
            when "0000001" | "0000010" | "0000011" | "0000100" | "0000101" | "0000110" | "0100000"=> -- Format A that use registers
                if bubble_sent = '0' then
                    bubble <= '1';
                    bubble_sent <= '1';
                elsif stall_IFID = '1' then
                null;
                else
                bubble_sent <= '0';
                bubble <= '0';
                end if;
                
            when others =>
                null;
 
          end case;  
      end if;
    end process;
end Behavioral;