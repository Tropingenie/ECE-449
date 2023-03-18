----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2023 09:56:01 AM
-- Design Name: 
-- Module Name: northbridge - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity northbridge is
  Port (
    INPORT : in std_logic_vector(15 downto 0);
    OUTPORT : out std_logic_vector(15 downto 0);
    clk, rst: in std_logic
   );
end northbridge;

architecture Behavioral of northbridge is

signal RAMREADA, RAMREADB, ROMREAD, RAMWRITE, RAM_ADDR_A, RAM_ADDR_B, ROM_ADDR, WE : std_logic_vector(15 downto 0);
signal ram_ena, ram_enb, rom_en, we_flag : std_logic;

component RAM is
  Port (
  douta, doutb            : out   std_logic_vector(15 downto 0);
  addra, addrb, dina, we  : in    std_logic_vector(15 downto 0);
  clk, rst, ena, enb      : in    std_logic
);
end component;

component Processor is
port(
    clk, rst : in std_logic;
    ROM_FROM, RAM_FROM_A, RAM_FROM_B, IN_PORT : in std_logic_vector(15 downto 0);
    RAM_TO, OUT_PORT, RAM_ADDR_A, RAM_ADDR_B  : out std_logic_vector(15 downto 0);
    ram_ena, ram_enb, rom_en, we              : out std_logic
);
end component;

begin

    we <= (others=>we_flag); -- Fan out WE flag since we never write bitwise

    MEM: RAM port map(  douta => ramreada, doutb => ramreadb, addra => ram_addr_a, 
                        addrb => ram_addr_b, dina=>RAMWRITE, clk=>clk, rst=>rst, 
                        ena=>ram_ena, enb=>ram_enb, we=>we); -- MAIN MEMORY

--BOOTLOADER:

    CPU: processor port map(clk=>clk, rst=>rst, ROM_FROM=>ROMREAD, RAM_FROM_A=>RAMREADA, 
                            RAM_FROM_B=>RAMREADB, IN_PORT=>INPORT, OUT_PORT=>OUTPORT, 
                            RAM_TO=>RAMWRITE, RAM_ADDR_A=>RAM_ADDR_A, RAM_ADDR_B=>RAM_ADDR_B,
                            ram_ena=>ram_ena, ram_enb=>ram_enb, rom_en=>rom_en, we=>we_flag);

end Behavioral;
