library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MemoryAccessUnit is
port(
    opcode  : in        std_logic_vector(6 downto 0);
    AR      : in        std_logic_vector(15 downto 0);  -- Result from ALU
    M_ADDR  : out       std_logic_vector(15 downto 0);  -- Address line to memory
    M_DATA  : inout     std_logic_vector(15 downto 0);  -- Data line to/from mem
    DATA_OUT: out       std_logic_vector(15 downto 0);  -- Output to MEM/WB
    clk, rst: in        std_logic                       -- Clock four times as fast as datapath to finish before memory strobes
);
end MemoryAccessUnit;


architecture Behaviour of MemoryAccessUnit is

component theregister is
port(
    clk : in std_logic;
    d_in : in std_logic_vector(15 downto 0);
    d_out : out std_logic_vector(15 downto 0));
end component;


begin

process(clk, rst)
begin
    if rst = '1' or opcode = x"UUUU" then
        M_ADDR <= (others=>'0');
        M_DATA <= (others=>'Z');
        DATA_OUT <= (others=>'0');
    elsif RISING_EDGE(clk) then
        case opcode is
            when "0100000" => -- IN
                M_DATA <= (others=>'Z');
                M_ADDR <= x"FFF0";
                DATA_OUT <= M_DATA;

            when "0100001" => -- OUT
                M_ADDR <= x"FFF2";
                M_DATA <= AR;

            -- ======== NEED TO IMPLEMENT LD/STR LATER ======== --
            --when "" =>

            --when "" =>

            when others =>
                null;
        end case;
    end if;

end Behaviour;