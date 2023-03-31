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
    
    --FROM/TO THE INSTRUCTION FETCHER--
    br_pc      : in std_logic_vector(15 downto 0);  --Value of the PC of the branch instruction that is saved if the branch is taken
    br_instr   : in std_logic_vector(15 downto 0);  --The branch instrcution given to the BranchModule
    br_calc_en : out std_logic;                     --Pauses the incrementation of the PC if the branch is being calculated
    
    --TO THE PC REGISTER--
    pc_out     : out std_logic_vector(15 downto 0); --PC output, either
    pc_br_overwrite : out std_logic;                --PC overwrite enable if branch is taken
    
    
    --FROM/TO REGISTER FILE--
    r7_in      : in std_logic_vector(15 downto 0);  --data from r7
    r7_out     : out std_logic_vector(15 downto 0); --data to be written to r7
    reg_data_in: in std_logic_vector(15 downto 0);  --data from register file R[ra]
    
    
    --FROM THE ALU--
    n_flag     : in std_logic;                             --Negtive flag of the the test instruction issueed immidiately before the branch instruction    
    z_flag     : in std_logic;                             --Zero flag of the the test instruction issueed immidiately before the branch instruction 
    ex_opcode  : in std_logic_vector(6 downto 0)           --execution stage opcode, used to enable the branch calculation
    
    --pause_pipe : out std_logic; --pause pipse signal issued to pipe stall controller for pausing when grabbing ra                    
    );
  
end BranchModule;

architecture Behavioral of BranchModule is
--COMPONENT DECLARATIONS HERE--

--SIGNAL DECLARATIONS HERE--
signal opcode : std_logic_vector(6 downto 0);              --opcode of the branch instruction
signal current_pc : std_logic_vector(15 downto 0);         --current PC of the branch instruction
signal next_pc : std_logic_vector(15 downto 0);            --output PC, either branch taken or not taken will change this
signal shift_amt : integer;                                --integer value of the shift amount of the PC
signal register_to_shift : std_logic_vector (15 downto 0); --R[ra] for immidiate branching
signal reg7_out: std_logic_vector (15 downto 0);           --R7 output for BR.SUB and RETURN function


--TODO 
-- Need to figure out a way to use register arbitrarator to write to r7 for subroutine call
-- Need to stop pipeline after BR is detected
-- Need to test

begin
    
    current_pc <= br_pc;
    
    
    --FROM IF--
    process(br_instr)                                            --save the branch instruction and the branch instruction PC
    begin
        opcode <= br_instr(15 downto 9);                         --branch instruction received from the IF
        current_pc <= br_pc;                                     --save the value of the PC at the branch instruction
        br_calc_en <= '1';                                       -- stop the IF from incrementing the PC
    end process;
    
    --BRANCH CALCULATION--
    process(ex_opcode) --This process executes when the 
    begin
    if (ex_opcode(6) = '1') then
        case (ex_opcode) is
        
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
                
            when "1000101" =>  -- BR.Z Instruction
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
                
            when "1000110" => --BR.SUB Instruction
                reg7_out <= std_logic_vector(unsigned(current_pc) + x"0002");
                next_pc <= reg_data_in;
                  
            when "1000111" => --RETURN Instruction
                next_pc <= r7_in;
                 
            when others =>
                assert false report "Opcode operation out of range in Branch Module" severity failure;                  
                   
            end case;
        end if;
    end process;
    
    process(clk)
    begin
        if(falling_edge(clk)) then --UNSURE ABOUT THIS
                pc_out <= next_pc; --output changed or unchaged
                r7_out <= reg7_out; --output r7
        end if;
    end process; 
     
end Behavioral;
