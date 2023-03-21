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

entity InstructionDecoder is
port(
    instruction     : in std_logic_vector(15 downto 0);
    opcode_out      : out std_logic_vector(6 downto 0);
    rd_1,               -- Address of register of first operand
    rd_2,               -- Address of register of second operand
    ra              : out std_logic_vector(2 downto 0);
    imm             : out std_logic_vector(3 downto 0);
    bubble          : in std_logic
    );
end InstructionDecoder;

architecture Behavioral of InstructionDecoder is

signal opcode : std_logic_vector(6 downto 0);

begin

    opcode <= instruction(15 downto 9) when bubble = '0' else "0000000";
    opcode_out <= opcode;
    
    process(opcode)
    begin
    	--assert false report "Instruction: " & to_hstring(instruction) severity note;
    	--assert false report "Opcode: " & to_hstring(opcode) severity note;
        case opcode is
            when "0000000" => --Format A0 (NOP)  
            	assert false report "debug" severity note;
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
                ra   <= (others=>'0');
                rd_1 <= instruction(8 downto 6);
                rd_2 <= (others=>'0');
                imm  <= (others=>'0');
            when "0100001" => -- Format A3 (IN)
                ra   <= instruction(8 downto 6); 
                rd_1 <= (others=>'0');
                rd_2 <= (others=>'0');
                imm  <= (others=>'0'); 
            when "UUUUUUU" =>
            	assert false report "Initializing" severity note;
            when others =>
                assert false report "Opcode operation out of range" severity failure;
                
        end case;
    end process;


end Behavioral;