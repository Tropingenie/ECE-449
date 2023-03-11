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
        ID_opcode, EX_opcode, MEM_opcode, WB_opcode : in std_logic_vector(6 downto 0) := (others => '0');
        ID_WRITE_EN : inout std_logic := '0'; -- Enable writing to the register. INOUT used so we can feedback into the controller internally
        stall_en : out std_logic_vector(3 downto 0) -- Stalls according to the set bit position 0=IFID, 1=IDEX, 2=EXMEM, 3=MEMWB
    );
end controller;

architecture Behaviour of controller is

component RegisterArbitrator is
port(
    opcode_in   : in std_logic_vector(6 downto 0);  -- opcode of the "current" (ID) instruction
    opcode_back : in std_logic_vector(6 downto 0);  -- opcode of the "writing back" (WB) instruction
    clk         : in std_logic;                     -- Clock at twice the rate of the datapath
    wr_en       : out std_logic                    -- Write enable for writeback
);
end component;

component StallController is
  Port (
  stall_stage : in std_logic_vector(3 downto 0);
  stall_enable : out std_logic_vector(3 downto 0)
 );
end component;

signal stall_stage : std_logic_vector(3 downto 0) := (others=>'0');

begin

REG_ARB     :  RegisterArbitrator port map(opcode_in=>ID_opcode, opcode_back=>WB_opcode, 
                                           clk=>clk, wr_en=>ID_WRITE_EN); -- Register Arbitrator
                                          
STALL_CONT :  StallController port map(stall_stage=>stall_stage, stall_enable=>stall_en); -- Stall pipeline if necessary

process(clk, rst) begin
    if (rst = '1') then
        stall_en <= (others => '0');
    elsif (rising_edge(clk)) then
        -- Writeback stalling
        if ID_WRITE_EN = '1' then -- Stall the pipeline if we need to write to the register file
            stall_stage <= stall_stage or "0010"; -- Enable bit 2 to stall pipeline at IDEX register
        elsif stall_stage(1) = '1' then
            stall_stage <= not (stall_stage nand "1101"); -- Disable bit 2 to resume pipeline
        end if;
        
        if ALU_STALL = '1' then --stall the pipeline on longer ALU operations
           stall_stage <= stall_stage or "0100"; -- Enable bit 3 to stall pipeline at EXMEM register
        elsif stall_stage(2) = '1' then
         stall_stage <= not (stall_stage nand "1011"); -- Disable bit 3 to resume pipeline
        end if;
        
    end if;

end process;

end Behaviour;