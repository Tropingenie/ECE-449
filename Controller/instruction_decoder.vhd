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
    n_flag, z_flag  : in std_logic; --negative and zero flags for branch instructions
    imm             : out std_logic_vector(3 downto 0)
    );
end InstructionDecoder;

architecture Behavioral of InstructionDecoder is

component theregister is
port(
    clk : in std_logic;
    d_in : in std_logic_vector(15 downto 0);
    d_out : out std_logic_vector(15 downto 0));    
end component;

signal current_pc, next_pc : std_logic_vector(15 downto 0);
signal branch_instr_op : std_logic_vector(6 downto 0);
signal shift_amt : integer;

signal opcode : std_logic_vector(6 downto 0);

begin

    opcode <= instruction(15 downto 9);
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
            when "1000000" =>   --BRR op
                                
                if instruction(8) = '1' then --shift right (negative displacement value)
                    shift_amt <=  to_integer(signed(instruction(8 downto 0)));
                    next_pc <= std_logic_vector(SHIFT_RIGHT(signed(current_pc), shift_amt));
                    shift_amt <= 0;
                    
                elsif instruction(8) = '0' then --shift left (positive displacement value
                    shift_amt <=  to_integer(signed(instruction(8 downto 0)));
                    next_pc <= std_logic_vector(SHIFT_RIGHT(signed(current_pc), shift_amt));
                    shift_amt <= 0;
               
                else
                     assert false report "Incorrect displacement value in the instruction_fetcher.vhd module" severity note;
                end if;
                
            when "1000001" => --BRR.N op 
                if n_flag = '1' then
                    if instruction(8) = '1' then --shift right (negative displacement value)
                        shift_amt <=  to_integer(signed(instruction(8 downto 0)));
                        next_pc <= std_logic_vector(SHIFT_RIGHT(signed(current_pc), shift_amt));
                        shift_amt <= 0;
                                        
                    elsif instruction(8) = '0' then --shift left (positive displacement value
                        shift_amt <=  to_integer(signed(instruction(8 downto 0)));
                        next_pc <= std_logic_vector(SHIFT_RIGHT(signed(current_pc), shift_amt));
                        shift_amt <= 0;
                                   
                    else
                        assert false report "Incorrect displacement value in the instruction_fetcher.vhd module" severity note;
                    end if;
                    
                elsif n_flag = '0' then --if value not negative    
                next_pc <= std_logic_vector(unsigned(current_pc) + x"0002"); --increment pc as usual
                
                else
                    assert false report "n_flag not '0' or '1' " severity note;
                end if;
                
            when "1000010" => --BRR.Z op
                if z_flag = '1' then
                    if instruction(8) = '1' then --shift right (negative displacement value)
                        shift_amt <=  to_integer(signed(instruction(8 downto 0)));
                        next_pc <= std_logic_vector(SHIFT_RIGHT(signed(current_pc), shift_amt));
                        shift_amt <= 0;
                                        
                    elsif instruction(8) = '0' then --shift left (positive displacement value
                        shift_amt <=  to_integer(signed(instruction(8 downto 0)));
                        next_pc <= std_logic_vector(SHIFT_RIGHT(signed(current_pc), shift_amt));
                        shift_amt <= 0;
                                   
                    else
                        assert false report "Incorrect displacement value in the instruction_fetcher.vhd module" severity note;
                    end if;
                    
                elsif z_flag = '0' then --if value not zero   
                next_pc <= std_logic_vector(unsigned(current_pc) + x"0002"); --increment pc as usual
                
                else
                    assert false report "z_flag not '0' or '1' " severity note;
                end if;
            
            when "1000011" => --BR op
                
            when "1000100" =>
            when "1000101" =>
            when "1000110" =>
            when "1000111" =>
                   --send opcode to register arbitrator for return
            when "UUUUUUU" =>
            	assert false report "Initializing" severity note;
            when others =>
                assert false report "Opcode operation out of range" severity failure;
                
            
                
        end case;
    end process;


end Behavioral;