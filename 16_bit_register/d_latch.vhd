library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DLatch is
port(
    D, E : in std_logic;
    Q : out std_logic);
end DLatch;

architecture Structure of DLatch is

signal EnotD, ED, Qinternal, notQ : std_logic;

begin
    EnotD <= not D and E;
    ED <= D and E;
    Qinternal <= EnotD nor notQ;
    notQ <= Qinternal nor ED;

    Q <= Qinternal;

end Structure;