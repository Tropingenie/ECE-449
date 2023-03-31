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
use IEEE.NUMERIC_STD.ALL;

entity InstructionDecoder is
port(
    instruction     : in std_logic_vector(15 downto 0);
    opcode_out      : out std_logic_vector(6 downto 0);
    rd_1,               -- Address of register of first operand
    rd_2,               -- Address of register of second operand
    ra              : out std_logic_vector(2 downto 0);
    imm             : out std_logic_vector(3 downto 0)--;
    --bubble          : in std_logic
    );
end InstructionDecoder;

architecture Behavioral of InstructionDecoder is

component theregister is
port(
    clk : in std_logic;
    d_in : in std_logic_vector(15 downto 0);
    d_out : out std_logic_vector(15 downto 0));    
end component;

signal opcode : std_logic_vector(6 downto 0);


begin

    opcode <= instruction(15 downto 9); --when bubble = '0' else "0000000";
    opcode_out <= opcode;
    
    with opcode select ra <=
         --(others=>'-') when "0000000" -- (NOP)
         instruction(8 downto 6) when "0000001"|"0000010"|"0000011"|"0000100"|"0000101"|"0000110"|"0100001", -- Format A1 (ADD, SUB, MUL, NAND, SHL, SHR, IN)
         --when "0000101"|"0000110", -- Format A2 (SHFT R, L)
         --when "0000111"|"0100000", --Format A3 (TEST Op, Out)
         --when "0100001", -- Format A3 (IN)
        (others=>'-') when others;
            
    with opcode select rd_1 <=
        instruction(5 downto 3) when "0000001"|"0000010"|"0000011"|"0000100", -- Format A1 (ADD, SUB, MUL, NAND),
        instruction(8 downto 6) when "0000101"|"0000110"|"0000111"|"0100000", -- Format A2 (SHFT R, L, TEST, OUT)
        (others=>'-') when others;
        
    with opcode select rd_2 <=
        instruction(2 downto 0) when "0000001"|"0000010"|"0000011"|"0000100", -- Format A1 (ADD, SUB, MUL, NAND)
        (others=>'-') when others;
        
    with opcode select imm <=
        instruction(3 downto 0) when "0000101"|"0000110", -- Format A2 (SHFT R, L)
        (others=>'-') when others;
--    process(instruction)
--    begin
--    	--assert false report "Instruction: " & to_hstring(instruction) severity note;
--    	--assert false report "Opcode: " & to_hstring(opcode) severity note;
--        case opcode is
--            when "0000000" => --Format A0 (NOP)  
--            	assert false report "debug" severity note;
--                rd_1 <= (others=>'-');
--                rd_2 <= (others=>'-');
--                ra   <= (others=>'-');    
--                imm  <= (others=>'-');            
--            when "0000001"|"0000010"|"0000011"|"0000100" => -- Format A1 (ADD, SUB, MUL, NAND)
--                rd_1 <= instruction(5 downto 3);
--                rd_2 <= instruction(2 downto 0);
--                ra   <= instruction(8 downto 6);
--                imm  <= (others=>'-');
--            when "0000101"|"0000110" => -- Format A2 (SHFT R, L)
--                ra   <= instruction(8 downto 6);
--                imm  <= instruction(3 downto 0);
--                rd_1 <= instruction(8 downto 6);
--                rd_2 <= (others=>'-');
--            when "0000111"|"0100000" => --Format A3 (TEST Op, Out)
--                ra   <= (others=>'-');
--                rd_1 <= instruction(8 downto 6);
--                rd_2 <= (others=>'-');
--                imm  <= (others=>'-');
--            when "0100001" => -- Format A3 (IN)
--                ra   <= instruction(8 downto 6); 
--                rd_1 <= (others=>'-');
--                rd_2 <= (others=>'-');
--                imm  <= (others=>'-');
--            when "1000000" | "1000001" | "1000010" =>               -- Format B1 (BRR, BRR.N, BRR.Z)                              
--                            rd_1 <= (others=>'0');
--                            rd_2 <= (others=>'0');
--                            ra   <= (others=>'0');    
--                            imm  <= (others=>'0'); 
--                        when "1000011"| "1000100" | "1000101" | "1000110" =>    -- Format B2 (BR, BR.N, BR.Z, BR.SUB)
--                            ra   <= instruction(8 downto 6);
--                            rd_1 <= (others=>'0');
--                            rd_2 <= (others=>'0');    
--                            imm  <= (others=>'0');
--                        when "1000111" =>                                       -- Format B2 (RETURN)
--                            ra <= (others=>'0');
--                            rd_1 <= "111";                                      -- Get R7
--                            rd_2 <= (others=>'0');    
--                            imm  <= (others=>'0'); 
--            when "UUUUUUU" =>
--            	assert false report "Initializing" severity note;
--            when others =>
--                assert false report "Opcode operation out of range" severity failure;
                
--        end case;
--    end process;


end Behavioral;