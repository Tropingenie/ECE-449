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
    clk, rst, stall_IFID : in std_logic;                     
    bubble          : out std_logic                   
);
end RegisterArbitrator;

architecture Behavioral of RegisterArbitrator is

--SIGNAL DECLARATIONS HERE--
signal send_bubble : std_logic := '0';
signal bubbles_to_send : integer := 0;

begin
    bubble <= send_bubble;

    process(clk, rst)
    begin
        if rst = '1' then
            send_bubble <= '0';
        end if;
        if(RISING_EDGE(clk)) then
        case(ID_opcode) is
            when "0000001" | "0000010" | "0000011" | "0000100" | "0000101" | "0000110" | "0100000"=> -- Format A that use registers
                if send_bubble = '0' then
                    bubbles_to_send <= bubbles_to_send + 1;
                end if;
                
            when others =>
                null;
          end case;  
          if stall_IFID = '1' then
                null;
          elsif bubbles_to_send > 0 then
            send_bubble <= '1';
            bubbles_to_send <= bubbles_to_send - 1;
          else
                send_bubble <= '0';
          end if;
      end if;
    end process;
end Behavioral;