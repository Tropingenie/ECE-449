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
  br_pc      : in std_logic_vector(15 downto 0); --Value of the PC of the branch instruction that is saved if the branch is taken
  br_instr   : in std_logic_vector(15 downto 0); --The branch instrcution given to the BranchModule
  n_flag     : in std_logic;                     --Negtive flag of the the test instruction issueed immidiately before the branch instruction    
  o_flag     : in std_logic;                     --Zero flag of the the test instruction issueed immidiately before the branch instruction 
  pc_out     : out std_logic_vector(15 downto 0);--PC output, either
  reg_addr_out: out std_logic_vector(2 downto 0); --reg address of the RETURN to be grabbed from the register file
  r7_pc_ret  : in std_logic_vector(15 downto 0); --PC returned from RETURN call
  reg_data_in: in std_logic_vector(15 downto 0)  --data from register file, either R7 or R[ra]
  --pause_pipe : out std_logic; --pause pipse signal issued to pipe stall controller for pausing when grabbing ra                    
  );
  
end BranchModule;

architecture Behavioral of BranchModule is
--COMPONENT DECLARATIONS HERE--

--SIGNAL DECLARATIONS HERE--
signal opcode : std_logic_vector(6 downto 0);      --opcode of the branch instruction
signal current_pc : std_logic_vector(15 downto 0); --current PC of the branch instruction
signal next_pc : std_logic_vector(15 downto 0);    --output PC, either branch taken or not taken will change this
signal saved_pc : std_logic_vector (15 downto 0);  --internal storage of the PC if program banches
signal shift_amt : integer;                        --integer value of the shift amount of the PC

begin
    
    opcode <= br_instr(15 downto 9);
    
    process(opcode)
    begin
    
    saved_pc <= br_pc; --save the value of the PC at the branch instruction
    
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
            if o_flag = '1' then
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
                
            elsif o_flag = '0' then --if value not zero   
            --do nothing
            
            else
                assert false report "z_flag not '0' or '1' " severity note;
            end if;
        
        when "1000011" => --BR op            

        when "1000100" =>
        when "1000101" =>
        when "1000110" =>
            
        when "1000111" =>
            next_pc <= reg_data_in;         
        when others =>
            assert false report "Opcode operation out of range in Branch Module" severity failure;
        
               --send opcode to register arbitrator for return
              
               
        end case;
        
        pc_out <= next_pc; --output changed or unchaged 
    end process;
end Behavioral;
