-----------------------------------------------------------
--
-- Register Arbitrator
--
-- Stalls the pipeline on data hazards.
--
-- Engineer: Kai Herrero, Benjamin Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterArbitrator is
port(
    ID_opcode, WB_opcode            : in std_logic_vector(6 downto 0);
    ID_rd_1, ID_rd_2, ID_wr, WB_wr  : in std_logic_vector(2 downto 0);
    clk, rst, stall_IFID            : in std_logic;
    stall_IDEX                      : out std_logic;
    wb_control                      : in std_logic_vector(15 downto 0)
    );
end RegisterArbitrator;

architecture Behavioral of RegisterArbitrator is

--SIGNAL DECLARATIONS HERE--
    type reg_array is array (integer range 0 to 7) of std_logic;
    signal reg_checkout : reg_array;
    signal read_1, read_2, ID_write, WB_write, check_in : integer;
    signal last_instr, middle_instr, current_instr, wb_control_1, wb_control_2 : std_logic_vector(15 downto 0);
    signal single_reg_operation, loadimm_passed : std_logic := '0';

begin
    read_1   <= to_integer(unsigned(ID_rd_1));
    read_2   <= to_integer(unsigned(ID_rd_2));
    ID_write <= to_integer(unsigned(id_wr));
    WB_write <= to_integer(unsigned(wb_wr));
    
    single_reg_operation <=
        '1' when (read_1 = ID_write or read_2 = ID_write )and not(ID_opcode = "0000000") else
        '0';
    

    process(clk, rst)
    begin
        if rst = '1' then
            for i in 0 to 7 loop
                reg_checkout(i)<= '0';
            end loop;
           stall_IDEX <= '0'; 
        end if;
        
            last_instr <= middle_instr;
            middle_instr <= current_instr; -- accounts for down clock cycle
            current_instr <= ID_opcode & ID_rd_1 & ID_rd_2 & ID_wr;
           
       if(rising_edge(clk)) then
            wb_control_1 <= wb_control;
            wb_control_2 <= wb_control_1;
            -- Stall pipeline when trying to read from a checked out register, and check out the writeback register when proceeding
            case(ID_opcode) is
                when "0000001" | "0000010" | "0000011" | "0000100" | "0000101" | "0000110" | "0100000" | "0100001" | "0010011"| "0010010"=> -- Format A that use registers
                    if (
                        (reg_checkout(read_1) = '1' or reg_checkout(read_2) = '1') 
                        and (single_reg_operation = '0' or not (current_instr = last_instr))
                        ) then
                        stall_IDEX <= '1';
                    else
                        if not(ID_opcode = "0100000") then
                            reg_checkout(ID_write) <= '1';
                        end if;
                        stall_IDEX <= '0';
                    end if; 
                when others =>
                    null;
              end case;
          end if; 
        if(falling_edge(clk)) then
            -- Check registers back in (with a delay of one cycle)           
                if check_in > -1 then
                    if WB_opcode = "0010010" then --LOADIMM is a special case, where we need to keep the register checked out but allow the stall to go low for a moment
                        if(loadimm_passed = '0') then
                            loadimm_passed <= '1';
                            stall_IDEX <= '0';
                            
                        elsif loadimm_passed = '1' and wb_control_1 = wb_control_2 then
                            reg_checkout(check_in) <= '0';
                        else
                            reg_checkout(check_in) <= '0';
                        end if;
                    end if;
                end if;
                case(WB_opcode) is
                      when "0000001" | "0000010" | "0000011" | "0000100" | "0000101" | "0000110" | "0100001" | "0010010"=> -- Format A that use registers, MOV, LOADIMM
                          check_in <= WB_write;
                      when others =>
                          check_in <= -1;
                end case;   
            end if;
    end process;
end Behavioral;