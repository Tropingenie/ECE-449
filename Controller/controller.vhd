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
        clk, rst : in std_logic;
        ID_opcode, EX_opcode, MEM_opcode, WB_opcode : in std_logic_vector(6 downto 0);
        ID_WRITE_EN : inout std_logic; -- Enable writing to the register. INOUT used so we can feedback into the controller internally
        stall_en : out std_logic_vector(3 downto 0); -- Stalls according to the set bit position 0=IFID, 1=IDEX, 2=EXMEM, 3=MEMWB
        bubble : out std_logic; -- Tells the pipeline to introduce a bubble
        data_mem_sel : out STD_LOGIC; -- 1 when reading from data memory, 0 when passing AR from ALU/writing to memory
        instr_mem_sel : out STD_LOGIC; -- 1 when using RAM, 0 when using ROM
        io_sel : out STD_LOGIC; -- 1 when using IO, 0 when using memory
        ram_ena, ram_enb, we : out std_logic 
    );
end controller;

architecture Behaviour of controller is

component RegisterArbitrator is
port(
    ID_opcode       : in std_logic_vector(6 downto 0);
    clk, rst, stall_IFID : in std_logic;                     
    bubble          : out std_logic := '0'                                       
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

signal stall_stage : std_logic_vector(3 downto 0) := (others => '0');
signal ALU_STALL : std_logic;

begin

REG_ARB     :  RegisterArbitrator port map(ID_opcode=>ID_opcode, clk=>clk, rst=>rst, bubble=>bubble, stall_IFID=>stall_stage(0)); -- Introduces bubbles when register conflcit occurs
                                          
STALL_CONT :  StallController port map(stall_stage=>stall_stage, stall_enable=>stall_en); -- Stall pipeline if necessary

ALUPR : ALUPipelineRetarder port map(clk=>clk, rst=>rst, ID_OPCODE=>ID_OPCODE, alu_stall_enable=>ALU_STALL);

MEM_ARB : MemoryArbiter port map(mem_opcode=>mem_opcode, data_mem_sel=>data_mem_sel, 
                                 instr_mem_sel=>instr_mem_sel, io_sel=>io_sel, ram_ena=>ram_ena, 
                                 ram_enb=>ram_enb, we=>we);

process(clk, rst) begin
    if rst = '1' then
        stall_stage <= (others => '0');
    elsif (rising_edge(clk)) then
        -- Writeback stalling
        -- ======= DEPRECATED. ALTERNATE METHOD FOR HANDLING DATA HAZARD IS WIP
        -- stall_stage(1) <= ID_WRITE_EN;
        
        --stall the pipeline on longer ALU operations
        stall_stage(2) <= ALU_STALL;
    end if;

end process;

with WB_OPCODE select ID_WRITE_EN <=
    '1' when "0000001" | "0000010" | "0000011" | "0000100" | "0000101" | "0000110" | "0100000", -- Format A that use registers
    '0' when others; 

end Behaviour;