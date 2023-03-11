----------------------------------------------------------------------------------
-- Create Date: 03/11/2023 10:28:05 AM
-- Design Name: Stall Controller
-- Module Name: stall_controller - Behavioral
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_MISC.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity stall_controller is
  Port (
    stall_stage : in std_logic_vector(3 downto 0);
    stall_enable : out std_logic_vector(3 downto 0)
   );
end stall_controller;

architecture Behavioral of stall_controller is

signal stall_IFID, stall_IDEX, stall_EXMEM, stall_MEMWB : std_logic;

begin

stall_IFID  <= or_reduce(stall_stage);
stall_IDEX  <= or_reduce(stall_stage(3 downto 1));
stall_EXMEM <= or_reduce(stall_stage(3 downto 2));
stall_MEMWB <= stall_stage(3);

stall_enable <= stall_MEMWB & stall_IDEX & stall_EXMEM & stall_MEMWB;

end Behavioral;
