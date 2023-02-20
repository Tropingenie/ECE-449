-- Testbench for FA
library IEEE;
use IEEE.std_logic_1164.all;
 
entity testbench is
-- empty
end testbench; 

architecture tb of testbench is

-- DUT component
component InstructionDecoder is
port(
    instruction     : in std_logic_vector(15 downto 0);
    opcode_out          : out std_logic_vector(6 downto 0);
    rd_1, rd_2, ra  : out std_logic_vector(2 downto 0);
    imm             : out std_logic_vector(3 downto 0)
    );
end component;

signal    instruction     :  std_logic_vector(15 downto 0);
signal    opcode_out          :  std_logic_vector(6 downto 0);
signal    rd_1, rd_2, ra  :  std_logic_vector(2 downto 0);
signal    imm             :  std_logic_vector(3 downto 0);

begin

  -- Connect DUT
  DUT: InstructionDecoder port map(instruction => instruction, opcode_out => opcode_out, rd_1 => rd_1, rd_2 => rd_2, ra => ra, imm => imm);
  
  process
  begin

	assert false report "Begin" severity note;
    
    instruction <= x"0000"; -- NOP
    wait for 100 ns;

    assert rd_1 = "000" report "T1 rd_1 Mismatch: " & to_hstring(rd_1) severity failure;
    assert rd_2 = "000" report "T1 rd_2 Mismatch: " & to_hstring(rd_2) severity failure;
    assert ra = "000" report "T1 ra Mismatch: " & to_hstring(ra) severity failure;
    assert imm = "0000" report "T1 imm Mismatch: " & to_hstring(imm) severity failure;
    assert opcode_out = "0000000" report "T1 opcode Mismatch: " & to_hstring(opcode_out) severity failure;

   
    instruction <= "0000001000001010"; -- Add R0, R1, R2
    wait for 100 ns;

    assert rd_1 = "001" report "T2 rd_1 Mismatch: " & to_hstring(rd_1) severity failure;
    assert rd_2 = "010" report "T2 rd_2 Mismatch: " & to_hstring(rd_2) severity failure;
    assert ra = "000" report "T2 ra Mismatch: " & to_hstring(ra) severity failure;
    assert imm = "0000" report "T2 imm Mismatch: " & to_hstring(imm) severity failure;
    assert opcode_out = "0000001" report "T2 opcode Mismatch: " & to_hstring(opcode_out) severity failure;

    instruction <= "0000010001010011"; -- Sub R1, R2, R3
    wait for 100 ns;

    assert rd_1 = "010" report "T3 rd_1 Mismatch: " & to_hstring(rd_1) severity failure;
    assert rd_2 = "011" report "T3 rd_2 Mismatch: " & to_hstring(rd_2) severity failure;
    assert ra = "001" report "T3 ra Mismatch: " & to_hstring(ra) severity failure;
    assert imm = "0000" report "T3 imm Mismatch: " & to_hstring(imm) severity failure;
    assert opcode_out = "0000010" report "T3 opcode Mismatch: " & to_hstring(opcode_out) severity failure;

    instruction <= "0000011100101110"; -- Mul R4, R5, R6
    wait for 100 ns;

    assert rd_1 = "101" report "T4 rd_1 Mismatch: " & to_hstring(rd_1) severity failure;
    assert rd_2 = "110" report "T4 rd_2 Mismatch: " & to_hstring(rd_2) severity failure;
    assert ra = "100" report "T4 ra Mismatch: " & to_hstring(ra) severity failure;
    assert imm = "0000" report "T4 imm Mismatch: " & to_hstring(imm) severity failure;
    assert opcode_out = "0000011" report "T4 opcode Mismatch: " & to_hstring(opcode_out) severity failure;

    instruction <= "0000100111001010"; -- NAND R7, R1, R2
    wait for 100 ns;

    assert rd_1 = "001" report "T5 rd_1 Mismatch: " & to_hstring(rd_1) severity failure;
    assert rd_2 = "010" report "T5 rd_2 Mismatch: " & to_hstring(rd_2) severity failure;
    assert ra = "111" report "T5 ra Mismatch: " & to_hstring(ra) severity failure;
    assert imm = "0000" report "T5 imm Mismatch: " & to_hstring(imm) severity failure;
    assert opcode_out = "0000100" report "T5 opcode Mismatch: " & to_hstring(opcode_out) severity failure;

    instruction <= "0000101011001000"; -- RSR R3, imm
    wait for 100 ns;

    assert rd_1 = "011" report "T6 rd_1 Mismatch: " & to_hstring(rd_1) severity failure;
    assert rd_2 = "000" report "T6 rd_2 Mismatch: " & to_hstring(rd_2) severity failure;
    assert ra = "011" report "T6 ra Mismatch: " & to_hstring(ra) severity failure;
    assert imm = "1000" report "T6 imm Mismatch: " & to_hstring(imm) severity failure;
    assert opcode_out = "0000101" report "T6 opcode Mismatch: " & to_hstring(opcode_out) severity failure;
 
    instruction <= "0000110100001010"; -- LSR R4, imm
    wait for 100 ns;

    assert rd_1 = "100" report "T7 rd_1 Mismatch: " & to_hstring(rd_1) severity failure;
    assert rd_2 = "000" report "T7 rd_2 Mismatch: " & to_hstring(rd_2) severity failure;
    assert ra = "100" report "T7 ra Mismatch: " & to_hstring(ra) severity failure;
    assert imm = "1010" report "T7 imm Mismatch: " & to_hstring(imm) severity failure;
    assert opcode_out = "0000110" report "T7 opcode Mismatch: " & to_hstring(opcode_out) severity failure;
  
    instruction <= "0000111101000000"; -- Test R5
    wait for 100 ns;

    assert rd_1 = "101" report "T8 rd_1 Mismatch: " & to_hstring(rd_1) severity failure;
    assert rd_2 = "000" report "T8 rd_2 Mismatch: " & to_hstring(rd_2) severity failure;
    assert ra = "000" report "T8 ra Mismatch: " & to_hstring(ra) severity failure;
    assert imm = "0000" report "T8 imm Mismatch: " & to_hstring(imm) severity failure;
    assert opcode_out = "0000111" report "T8 opcode Mismatch: " & to_hstring(opcode_out) severity failure;
  
    instruction <= "0100000110000000"; -- OUT R6
    wait for 100 ns;

    assert rd_1 = "110" report "T9 rd_1 Mismatch: " & to_hstring(rd_1) severity failure;
    assert rd_2 = "000" report "T9 rd_2 Mismatch: " & to_hstring(rd_2) severity failure;
    assert ra = "000" report "T9 ra Mismatch: " & to_hstring(ra) severity failure;
    assert imm = "0000" report "T9 imm Mismatch: " & to_hstring(imm) severity failure;
    assert opcode_out = "0100000" report "T9 opcode Mismatch: " & to_hstring(opcode_out) severity failure;
  
    instruction <= "0100001111000000"; -- IN R7
    wait for 100 ns;

    assert rd_1 = "000" report "T10 rd_1 Mismatch: " & to_hstring(rd_1) severity failure;
    assert rd_2 = "000" report "T10 rd_2 Mismatch: " & to_hstring(rd_2) severity failure;
    assert ra = "111" report "T10 ra Mismatch: " & to_hstring(ra) severity failure;
    assert imm = "0000" report "T10 imm Mismatch: " & to_hstring(imm) severity failure;
    assert opcode_out = "0100001" report "T2 opcode Mismatch: " & to_hstring(opcode_out) severity failure;


       
    assert false report "Tests done." severity note;
    wait;

  end process;
end tb;
