----------------------------------------------------------------------------------
-- Engineer: Kai Herrero
-- Create Date: 03/13/2023 04:41:46 PM
-- Design Name: Branch Module
-- Module Name: BranchModule - Behavioral
-- Description: This module handles tghe PC and the system control
--  in the case of a branch
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity BranchModule is

Port (

    --Clock, Reset--
    clk, rst   : in std_logic;                      --synchronized checking and writing with the IF
    
    --FROM THE INSTRUCTION FETCHER--
    br_pc      : in std_logic_vector(15 downto 0);  --Value of the PC of the branch instruction that is saved if the branch is taken
    br_instr   : in std_logic_vector(15 downto 0);  --The branch instrcution given to the BranchModule
    
    --FROM THE PC REGISTER--
    pc_out     : out std_logic_vector(15 downto 0); --PC output, either
    pc_br_overwrite : out std_logic;                --PC overwrite enable if branch is taken
    
    
    --FROM REGISTER FILE--
    reg_addr_out: out std_logic_vector(2 downto 0); -- reg address of the RETURN to be grabbed from the register file
    r7_pc_ret  : in std_logic_vector(15 downto 0);  -- PC returned from RETURN call

    r7         : in std_logic_vector(15 downto 0);  --data from r7
    reg_data_in: in std_logic_vector(15 downto 0);  --data from register file, either R7 or R[ra]
    
    
    --FROM THE ALU--
    n_flag     : in std_logic;                             --Negtive flag of the the test instruction issueed immidiately before the branch instruction    
    z_flag     : in std_logic;                             --Zero flag of the the test instruction issueed immidiately before the branch instruction 
    ex_opcode  : in std_logic_vector(15 downto 0)          --execution stage opcode, used to enable the branch calculation
    
    --pause_pipe : out std_logic; --pause pipse signal issued to pipe stall controller for pausing when grabbing ra                    
    );
  
end BranchModule;

architecture Behavioral of BranchModule is
--COMPONENT DECLARATIONS HERE--

--SIGNAL DECLARATIONS HERE--
signal opcode : std_logic_vector(6 downto 0);              --opcode of the branch instruction
signal current_pc : std_logic_vector(15 downto 0);         --current PC of the branch instruction
signal next_pc : std_logic_vector(15 downto 0);            --output PC, either branch taken or not taken will change this
signal saved_pc : std_logic_vector (15 downto 0);          --internal storage of the PC if program banches
signal shift_amt : integer;                                --integer value of the shift amount of the PC
signal register_to_shift : std_logic_vector (15 downto 0); --R[ra] for immidiate branching

signal branch_calc_en : std_logic;                         --signal to turn on when a branch is being calculated


--TODO 
-- need to go into every function and add enable pc_br_overwrite and disable somewhere too
-- need to make the branch module in the conrtroller and hook it up in the processor
-- need to finish logic for instructions 69, 70, 71
-- now that I am in the execution phase need to get decoder to issue data

begin
    
    
    --FROM IF--
    process(br_instr)                                           --save the branch instruction and the branch instruction PC
    begin
        opcode <= br_instr(15 downto 9);                         --branch instruction received from the IF
        saved_pc <= br_pc;                                       --save the value of the PC at the branch instruction
    end process;
    
    --BRANCH CALCULATION--
    process(ex_opcode)
    begin
    if (ex_opcode(15) = '1') then
        case (opcode) is
        
            when "1000000" =>   --BRR op
                                
                if br_instr(8) = '1' then --shift right (negative displacement value)
                    shift_amt <=  to_integer(signed(br_instr(8 downto 0)));
                    next_pc <= std_logic_vector(SHIFT_RIGHT(signed(current_pc), shift_amt));
                    shift_amt <= 0;
                    
                elsif br_instr(8) = '0' then --shift left (positive displacement value
                    shift_amt <=  to_integer(signed(br_instr(8 downto 0)));
                    next_pc <= std_logic_vector(SHIFT_RIGHT(signed(current_pc), shift_amt));
                    shift_amt <= 0;
               
                else
                     assert false report "Incorrect displacement value in the Branch Module" severity note;
                end if;
                
            when "1000001" => --BRR.N op 
                if n_flag = '1' then
                    if br_instr(8) = '1' then --shift right (negative displacement value)
                        shift_amt <=  to_integer(signed(br_instr(8 downto 0)));
                        next_pc <= std_logic_vector(SHIFT_RIGHT(signed(current_pc), shift_amt));
                        shift_amt <= 0;
                                        
                    elsif br_instr(8) = '0' then --shift left (positive displacement value
                        shift_amt <=  to_integer(signed(br_instr(8 downto 0)));
                        next_pc <= std_logic_vector(SHIFT_RIGHT(signed(current_pc), shift_amt));
                        shift_amt <= 0;
                                   
                    else
                        assert false report "Incorrect displacement value in the Branch Module" severity note;
                    end if;
                    
                elsif n_flag = '0' then --if value not negative    
                --do nothing
                
                else
                    assert false report "n_flag not '0' or '1' " severity note;
                end if;
                
            when "1000010" => --BRR.Z op
                if z_flag = '1' then
                    if br_instr(8) = '1' then --shift right (negative displacement value)
                        shift_amt <=  to_integer(signed(br_instr(8 downto 0)));
                        next_pc <= std_logic_vector(SHIFT_RIGHT(signed(current_pc), shift_amt));
                        shift_amt <= 0;
                                        
                    elsif br_instr(8) = '0' then --shift left (positive displacement value
                        shift_amt <=  to_integer(signed(br_instr(8 downto 0)));
                        next_pc <= std_logic_vector(SHIFT_RIGHT(signed(current_pc), shift_amt));
                        shift_amt <= 0;
                                   
                    else
                        assert false report "Incorrect displacement value in the Branch Module" severity note;
                    end if;
                    
                elsif z_flag = '0' then --if value not zero   
                --do nothing
                
                else
                    assert false report "z_flag not '0' or '1' " severity note;
                end if;

            when "1000011" => --BR op            
                if br_instr(8) = '1' then --shift right (negative displacement value)
                    shift_amt <=  to_integer(signed(br_instr(8 downto 0)));
                    next_pc <= std_logic_vector(SHIFT_RIGHT(signed(reg_data_in), shift_amt));
                    shift_amt <= 0;
                                    
                elsif br_instr(8) = '0' then --shift left (positive displacement value
                    shift_amt <=  to_integer(signed(br_instr(8 downto 0)));
                    next_pc <= std_logic_vector(SHIFT_RIGHT(signed(reg_data_in), shift_amt));
                    shift_amt <= 0;
                               
                else
                    assert false report "Incorrect displacement value in the Branch Module" severity note;
                end if;     
                   
            when "1000100" =>   --BR.N Instruction
                if (n_flag = '1') then
                    if br_instr(8) = '1' then --shift right (negative displacement value)
                        shift_amt <=  to_integer(signed(br_instr(8 downto 0)));
                        next_pc <= std_logic_vector(SHIFT_RIGHT(signed(reg_data_in), shift_amt));
                        shift_amt <= 0;
                                        
                    elsif br_instr(8) = '0' then --shift left (positive displacement value)
                        shift_amt <=  to_integer(signed(br_instr(8 downto 0)));
                        next_pc <= std_logic_vector(SHIFT_RIGHT(signed(reg_data_in), shift_amt));
                        shift_amt <= 0;
                                   
                    else
                        assert false report "Incorrect displacement value in the Branch Module" severity note;
                    end if;
                elsif (n_flag = '0') then
                    --Instruction fetcher will update the PC
                else
                    assert false report "n_flag is not returned in Branch Module" severity note;
                end if;
                
            when "1000101" =>       
                if (z_flag = '1') then
                    if br_instr(8) = '1' then --shift right (negative displacement value)
                        shift_amt <=  to_integer(signed(br_instr(8 downto 0)));
                        next_pc <= std_logic_vector(SHIFT_RIGHT(signed(reg_data_in), shift_amt));
                        shift_amt <= 0;
                                        
                    elsif br_instr(8) = '0' then --shift left (positive displacement value)
                        shift_amt <=  to_integer(signed(br_instr(8 downto 0)));
                        next_pc <= std_logic_vector(SHIFT_RIGHT(signed(reg_data_in), shift_amt));
                        shift_amt <= 0;
                                   
                    else
                        assert false report "Incorrect displacement value in the Branch Module" severity note;
                    end if;
                elsif (z_flag = '0') then
                    --Instruction fetcher will update the PC
                else
                    assert false report "n_flag is not returned in Branch Module" severity note;
                end if;
                
            when "1000110" =>
                
            when "1000111" =>
                next_pc <= r7;         
            when others =>
                assert false report "Opcode operation out of range in Branch Module" severity failure;
            
                   --send opcode to register arbitrator for return
                  
                   
            end case;
        end if;
        branch_calc_en <= '0';
    end process;
    
    if(falling_edge(clk)) then --UNSURE ABOUT THIS
            pc_out <= next_pc; --output changed or unchaged 
    end if;
    
    
end Behavioral;
