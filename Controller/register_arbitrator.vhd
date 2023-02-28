-----------------------------------------------------------
--
-- Register Arbitrator
--
-- Plug in module to arbitrate register file access. Allows
-- writing when one or fewer instructions are used, and
-- sends a "pause" signal to stop the pipeline for two
-- register instructions. In current state, Register arbitrator 
-- favours write back.
--
-- Engineer: Kai Herrero, Benjamin Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterArbitrator is
port(
    opcode_in   : in std_logic_vector(6 downto 0);  -- opcode of the "current" instruction
    opcode_back : in std_logic_vector(6 downto 0);  -- opcode of the "writing back" instruction
    clk         : in std_logic;                     -- Clock at twice the rate of the datapath
    wr_en       : out std_logic                     -- Write enable for writeback

);
end RegisterArbitrator;

architecture Behavioral of RegisterArbitrator is

--SIGNAL DECLARATIONS HERE--
signal counter : integer := 0;
signal write   : std_logic := '0';

begin
    

    process(clk)
    begin
     counter <= counter + 1;

     if (counter mod 3) = 0 then
         counter <= 0;    
           
         case opcode_back is
         
            when "0000001" | "0000010" | "0000011" | "0000100" | "0000101" | "0000110"  =>       --ADD/SUB/MULT/NAND/SHIFTR/SHIFTL Ops
                write <= NOT write;
                
            when others =>
                write <= '0';
                assert false report "Opcode is not a writeback" severity note;
                                       
        end case;  
                  
     end if;


     wr_en <= write;   

    end process;
end Behavioral;