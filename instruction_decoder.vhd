-----------------------------------------------------------
--
-- Instruction Decoder
--
-- Plug in module to go between raw instruction and ALU and
-- decide what and where everything in the instruction is
-- and goes.
--
-- Ben Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InstructionDecoder is:
port(
    instruction     : in std_logic_vector(15 downto 0);
    opcode          : out std_logic_vector(6 downto 0);
    rd_1, rd_2, ra  : out std_logic_vector(2 downto 0);
    imm             : std_logic_vector(3 downto 0)
    );
end InstructionDecoder;

architecture Behavioral of InstructionDecoder is



begin

    opcode <= instruction(15 downto 9);

    case opcode is
        when "0000000" => --Format A0 (NOP)  
            rd_1 <= (others=>'0');
            rd_2 <= (others=>'0');
            ra   <= (others=>'0');    
            imm  <= (others=>'0');            
        when "0000001"|"0000010"|"0000011"|"0000100" => -- Format A1 (ADD, SUB, MUL, NAND)
            rd_1 <= instruction(5 downto 3);
            rd_2 <= instruction(2 downto 0);
            ra   <= instruction(8 downto 6);
            imm  <= (others=>'0');
        when "0000101"|"0000110" => -- Format A2 (SHFT R, L)
            ra   <= instruction(8 downto 6);
            imm  <= instruction(3 downto 0);
            rd_1 <= instruction(8 downto 6);
            rd_2 <= (others=>'0');
        when "0000111"|"0100000" => --Format A3 (TEST Op, Out)
            ra   <= instruction(8 downto 6);
            rd_1 <= instruction(8 downto 6);
            rd_2 <= (others=>'0');
            imm  <= (others=>'0');
        when "0100001" =>
            ra   <= instruction(8 downto 6); 
            rd_1 <= (others=>'0');
            rd_2 <= (others=>'0');
            imm  <= (others=>'0');     
        when others =>
            assert false report "Opcode operation out of range" severity failure;
                
    end case;


end Behavioral;