-----------------------------------------------------------
--
-- Controller
--
-- All control logic and lines
--
-- Ben Lyne
--
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller is
    port(
        clk, pipe_clk, rst : in std_logic;
        ID_opcode, EX_opcode, MEM_opcode, WB_opcode : in std_logic_vector(6 downto 0);
        ID_WRITE_EN : inout std_logic; -- Enable writing to the register. INOUT used so we can feedback into the controller internally
        stall_en : out std_logic_vector(3 downto 0); -- Stalls according to the set bit position 0=IFID, 1=IDEX, 2=EXMEM, 3=MEMWB
        --bubble : out std_logic; -- Tells the pipeline to introduce a bubble
        data_mem_sel : out STD_LOGIC; -- 1 when reading from data memory, 0 when passing AR from ALU/writing to memory
        instr_mem_sel : out STD_LOGIC; -- 1 when using RAM, 0 when using ROM
        io_sel : out STD_LOGIC; -- 1 when using IO, 0 when using memory
        MEMWB_CONTROL_BITS_OUT : in std_logic_vector(15 downto 0);
        ID_rd_1, ID_rd_2, ID_wr, WB_wr  : in std_logic_vector(2 downto 0);
        br_pc      : in std_logic_vector(15 downto 0);  --Value of the PC of the branch instruction that is saved if the branch is taken
        br_instr   : in std_logic_vector(15 downto 0);  --The branch instrcution given to the BranchModule
        br_calc_en : out std_logic;                     --To pause the IF when a branch is being calculated
        pc_out     : out std_logic_vector(15 downto 0); --PC output, either
        pc_br_overwrite : out std_logic;                --PC overwrite enable if branch is taken
        r7_in      : in std_logic_vector(15 downto 0);  --data from r7
        r7_out     : out std_logic_vector(15 downto 0); --data to be written to r7
        reg_data_in: in std_logic_vector(15 downto 0);  --data from register file R[ra]
        n_flag     : in std_logic;                             --Negtive flag of the the test instruction issueed immidiately before the branch instruction    
        z_flag     : in std_logic;                             --Zero flag of the the test instruction issueed immidiately before the branch instruction 
        ram_ena, ram_enb, we : out std_logic 
    );
end controller;

architecture Behaviour of controller is

component RegisterArbitrator is
port(
    ID_opcode, WB_opcode            : in std_logic_vector(6 downto 0);
    ID_rd_1, ID_rd_2, ID_wr, WB_wr  : in std_logic_vector(2 downto 0);
    clk, rst, stall_IFID            : in std_logic;
    stall_IDEX                      : out std_logic                                  
);
end component;

component StallController is
  Port (
  stall_stage : in std_logic_vector(3 downto 0);
  stall_enable : out std_logic_vector(3 downto 0)
 );
end component;

component ALUPipelineRetarder is
  Port (
  clk, rst : in std_logic;
  ID_OPCODE : in std_logic_vector(6 downto 0);
  alu_stall_enable : inout std_logic-- inout used to feedback internally
 );
end component;

component MemoryArbiter is
    Port (
       mem_opcode: in std_logic_vector(6 downto 0);
       data_mem_sel : out STD_LOGIC; -- 1 when reading from data memory, 0 when passing AR from ALU/writing to memory
       instr_mem_sel : out STD_LOGIC; -- 1 when using RAM, 0 when using ROM
       io_sel : out STD_LOGIC; -- 1 when using IO, 0 when using memory
       ram_ena, ram_enb, we : out std_logic
       ); 
end component;

component BranchModule is
Port (
    clk, rst   : in std_logic;                      --synchronized checking and writing with the IF
    br_pc      : in std_logic_vector(15 downto 0);  --Value of the PC of the branch instruction that is saved if the branch is taken
    br_instr   : in std_logic_vector(15 downto 0);  --The branch instrcution given to the BranchModule
    pc_out     : out std_logic_vector(15 downto 0); --PC output, either
    pc_br_overwrite : out std_logic;                --PC overwrite enable if branch is taken
    br_calc_en : out std_logic;
    r7_in      : in std_logic_vector(15 downto 0);  --data from r7
    r7_out     : out std_logic_vector(15 downto 0); --data to be written to r7
    reg_data_in: in std_logic_vector(15 downto 0);  --data from register file R[ra]
    n_flag     : in std_logic;                             --Negtive flag of the the test instruction issueed immidiately before the branch instruction    
    z_flag     : in std_logic;                             --Zero flag of the the test instruction issueed immidiately before the branch instruction 
    ex_opcode  : in std_logic_vector(6 downto 0)           --execution stage opcode, used to enable the branch calculation
    --pause_pipe : out std_logic; --pause pipse signal issued to pipe stall controller for pausing when grabbing ra                    
    );
end component;

signal stall_stage : std_logic_vector(3 downto 0) := (others => '0');
signal ALU_STALL, REG_STALL, written : std_logic := '0';
signal last_wb_bits, delay_wb_bits, current_wb_bits : std_logic_vector(15 downto 0);

begin

REG_ARB     :  RegisterArbitrator port map(ID_opcode=>ID_opcode, WB_opcode=>WB_opcode, id_rd_1=>id_rd_1, id_rd_2=>id_rd_2, id_wr=>id_wr, wb_wr=>wb_wr,
                                           clk=>clk, rst=>rst, stall_IFID=>stall_stage(0), stall_IDEX=>REG_STALL); 
                                          
--STALL_CONT :  StallController port map(stall_stage=>stall_stage, stall_enable=>stall_en); -- Stall pipeline if necessary

ALUPR : ALUPipelineRetarder port map(clk=>clk, rst=>rst, ID_OPCODE=>ID_OPCODE, alu_stall_enable=>ALU_STALL);

MEM_ARB : MemoryArbiter port map(mem_opcode=>mem_opcode, data_mem_sel=>data_mem_sel, 
                                 instr_mem_sel=>instr_mem_sel, io_sel=>io_sel, ram_ena=>ram_ena, 
                                 ram_enb=>ram_enb, we=>we);
BR_MOD : BranchModule port map(clk=>clk, rst=>rst, br_pc => br_pc, br_instr =>br_instr, pc_out =>pc_out, pc_br_overwrite => pc_br_overwrite, r7_in => r7_in, r7_out => r7_out, reg_data_in =>reg_data_in, n_flag => n_flag, z_flag => z_flag, ex_opcode => ex_opcode, br_calc_en => br_calc_en);

-- Writeback stalling
 stall_stage(1) <= REG_STALL;

--stall the pipeline on longer ALU operations
stall_stage(2) <= ALU_STALL;

stall_en <= '0' & ALU_STALL & (REG_STALL or ALU_STALL) & (REG_STALL or ALU_STALL);

process(clk, rst) begin
    if rst = '1' then
        stall_stage <= (others => '0');
    else--if (rising_edge(clk)) then
        
        --Enable writeback for one clock
        last_wb_bits <= delay_wb_bits;
        delay_wb_bits <= current_wb_bits; -- Need an extra clock delay so that there is a clock edge where last and current differ
        current_wb_bits <= MEMWB_CONTROL_BITS_OUT;
        
        
        case(WB_OPCODE) is
            when "0000001" | "0000010" | "0000011" | "0000100" | "0000101" | "0000110" | "0100001"| "0010011" => -- Format A that write to registers, and MOV
                if written = '1' and last_wb_bits = current_wb_bits then
                    if falling_edge(clk) then
                        ID_WRITE_EN <= '0';
                    end if;
                elsif written <= '0' then
                    ID_WRITE_EN <= '1';
                    written <= '1';
                else
                    ID_WRITE_EN <= '0';
                    written <= '0';
                end if;
            when others =>
                ID_WRITE_EN <= '0';
                written <= '0';
        end case;
    end if;
end process;

--    with WB_OPCODE select ID_WRITE_EN <=
--        '1' and not written when "0000001" | "0000010" | "0000011" | "0000100" | "0000101" | "0000110" | "0100000", -- Format A that use registers
--        '0' when others; 



end Behaviour;