library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Processor_testbench is
end Processor_testbench;

architecture Behavioral of Processor_testbench is

--COMPONENT DECLARATIONS HERE--
component Processor port(
    clk, rst : in std_logic;
    ROM_FROM, RAM_FROM_A, RAM_FROM_B, IN_PORT : in std_logic_vector(15 downto 0);
    RAM_TO, OUT_PORT, RAM_ADDR_A, RAM_ADDR_B  : out std_logic_vector(15 downto 0)
    );
end component;

--SIGNAL DECLARATIONS HERE--
    signal clk, rst : std_logic;
    signal ROM_FROM, RAM_FROM_A, RAM_FROM_B, IN_PORT: std_logic_vector(15 downto 0);
    signal RAM_TO, OUT_PORT, RAM_ADDR_A, RAM_ADDR_B : std_logic_vector(15 downto 0);
    
begin

    UUT: processor port map(
    clk=>clk,rst=>rst,
    ROM_FROM=>ROM_FROM,
    RAM_FROM_A=>RAM_FROM_A,
    RAM_FROM_B=>RAM_FROM_B,
    IN_PORT=>IN_PORT,
    RAM_TO=>RAM_TO,
    OUT_PORT=>OUT_PORT,
    RAM_ADDR_A=>RAM_ADDR_A,
    RAM_ADDR_B=>RAM_ADDR_B);
    
    process begin
    rst <= '1';
    wait for 20 us;
    rst <= '0';
    wait;
    end process;

    process begin   --Clocking process, 500MhZ duty cycle
    clk <= '0';
    wait for 1 us;
    clk <= '1';
    wait for 1 us;
    end process;
    
    process(clk) begin
        case(RAM_ADDR_B) is
        -- UNCOMMENT THE FOLLOWING FOR TESTING FORMAT A
--            when x"0000" => RAM_FROM_B <= "0100001001000000"; -- IN r1 (NOP for now)
--            when x"0002" => RAM_FROM_B <= "0100001010000000"; -- IN r2 (NOP for now)
--            when x"0004" => RAM_FROM_B <= "0000000000000000";
--            when x"0006" => RAM_FROM_B <= "0000000000000000";
--            when x"0008" => RAM_FROM_B <= "0000000000000000";
--            when x"000A" => RAM_FROM_B <= "0000000000000000"; -- 4 NOPs
--            when x"000C" => RAM_FROM_B <= "0000001011010001"; --ADD r3,r2,r1
--            when x"000E" => RAM_FROM_B <= "0000000000000000";
--            when x"0010" => RAM_FROM_B <= "0000000000000000";
--            when x"0012" => RAM_FROM_B <= "0000000000000000";
--            when x"0014" => RAM_FROM_B <= "0000000000000000"; -- 4 NOPs
--            when x"0016" => RAM_FROM_B <= "0000101011000010"; --SHL r3,2
--            when x"0018" => RAM_FROM_B <= "0000000000000000";
--            when x"001A" => RAM_FROM_B <= "0000000000000000";
--            when x"001C" => RAM_FROM_B <= "0000000000000000";
--            when x"001E" => RAM_FROM_B <= "0000000000000000"; -- 4 NOPs
--            when x"0020" => RAM_FROM_B <= "0000011010001011"; --MUL r2,r1,r3
--            when x"0022" => RAM_FROM_B <= "0000000000000000";
--            when x"0024" => RAM_FROM_B <= "0000000000000000";
--            when x"0026" => RAM_FROM_B <= "0000000000000000";
--            when x"0028" => RAM_FROM_B <= "0000000000000000"; -- 4 NOPs
--            when x"002A" => RAM_FROM_B <= "0100000010000000"; --OUT r2
--            when x"002C" => RAM_FROM_B <= "0000000000000000";
--            when x"002E" => RAM_FROM_B <= "0000000000000000";
--            when x"0030" => RAM_FROM_B <= "0000000000000000";
--            when x"0032" => RAM_FROM_B <= "0000000000000000"; -- 4 NOPs
        
        
        -- UNCOMMENT THE FOLLOWING FOR TESTING DATA HAZARDS (FORMAT A WITHOUT NOPS)
--            when x"0000" => RAM_FROM_B <= "0100001001000000"; -- IN r1 
--            when x"0002" => RAM_FROM_B <= "0100001010000000"; -- IN r2 
--            when x"0004" => RAM_FROM_B <= "0000001011010001"; --ADD r3,r2,r1
--            when x"0006" => RAM_FROM_B <= "0000101011000010"; --SHL r3,2
--            when x"0008" => RAM_FROM_B <= "0000011010001011"; --MUL r2,r1,r3
--            when x"000A" => RAM_FROM_B <= "0100000010000000"; --OUT r2
            
        -- UNCOMMENT THE FOLLOWING TO TEST FORMAT B PART 1 (DATA HAZARDS)
--            when x"0000" => RAM_FROM_B <= "0100001000000000"; -- IN r0
--            when x"0002" => RAM_FROM_B <= "0100001001000000"; -- IN r1
--            when x"0004" => RAM_FROM_B <= "0100001010000000"; -- IN r2
--            when x"0006" => RAM_FROM_B <= "0100001011000000"; -- IN r3
--            when x"0008" => RAM_FROM_B <= "0000001001001010"; -- ADD R1, R1, R2
--            when x"000A" => RAM_FROM_B <= "0000010010001000"; -- SUB R2, R1, R0
--            when x"000C" => RAM_FROM_B <= "0000010001011010";  --SUB R1, R3, R2
--            when x"000E" => RAM_FROM_B <= "0000000000000000";

        -- UNCOMMENT THE FOLLOWING TO TEST FORMAT L TEST CODE
            when x"0000" => RAM_FROM_B <= "0010010000001111"; -- LOADIMM.LOWER 15
            when x"0002" => RAM_FROM_B <= "0010010100000101"; -- LOADIMM.UPPER 5
            when x"0004" => RAM_FROM_B <= "0010011001111000"; -- MOV R1, R7
            when x"0006" => RAM_FROM_B <= "0010010000000000"; -- LOADIMM.LOWER 0
            when x"0008" => RAM_FROM_B <= "0010010100000110"; -- LOADIMM.UPPER 6
            when x"000A" => RAM_FROM_B <= "0010011010111000"; -- MOV R2, R7
--            when x"000C" => RAM_FROM_B <= "0000010001011010"; -- STORE R2, R1
--            when x"000E" => RAM_FROM_B <= "0000000000000000"; -- LOAD R3, R2
            
          -- Leave this :)
            when others => assert false report "Testbench memory out of range" severity note;
        end case;
    end process;
    
    process begin   --behavioural process
    -- UNCOMMENT FOR FORMAT A TESTBENCH
--        wait for 30 us;
--        wait until (clk='1' and clk'event);
--        IN_PORT <= x"0003";
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        IN_PORT <= x"0005";
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        IN_PORT <= (others=>'-');
--        wait;
    
    
    -- UNCOMMENT FOR FORMAT B PART 1 TESTBENCH
--        wait for 30 us;
--        wait until (clk='1' and clk'event);
--        IN_PORT <= x"0002";
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        IN_PORT <= x"0003";
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        IN_PORT <= x"0001";
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        IN_PORT <= x"0005";
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        wait until (clk='1' and clk'event);
--        IN_PORT <= (others=>'-');
--        wait;
        
        null;
        wait;
    end process;
end Behavioral;
