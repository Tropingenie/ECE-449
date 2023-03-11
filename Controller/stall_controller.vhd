----------------------------------------------------------------------------------
-- Create Date: 03/11/2023 10:28:05 AM
-- Design Name: Stall Controller
-- Module Name: StallController - Behavioral
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

entity StallController is
  Port (
    stall_stage : in std_logic_vector(3 downto 0);
    stall_enable : out std_logic_vector(3 downto 0)
   );
end StallController;

architecture Behavioral of StallController is

signal stall_IFID, stall_IDEX, stall_EXMEM, stall_MEMWB : std_logic := '0';

begin

stall_IFID  <= stall_stage(3) or stall_stage(2) or stall_stage(1) or stall_stage(0);
stall_IDEX  <= stall_stage(3) or stall_stage(2) or stall_stage(1);
stall_EXMEM <= stall_stage(3) or stall_stage(2);
stall_MEMWB <= stall_stage(3);

stall_enable(3) <= stall_MEMWB;  
stall_enable(2) <= stall_EXMEM;
stall_enable(1) <= stall_IDEX;
stall_enable(0) <= stall_IFID;

end Behavioral;
