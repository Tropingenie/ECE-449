-----------------------------------------------------------
--
-- Register Arbitrator
--
-- Plug in module to arbitrate register file access. Allows
-- writing when one or fewer instructions are used, and
-- sends a "pause" signal to stop the pipeline for two
-- register instructions.
--
-- Ben Lyne, Kai Herrero
--
-----------------------------------------------------------

entity RegisterArbitrator is
port(
    opcode_in   : in std_logic_vector(6 downto 0); -- opcode of the "current" instruction
    opcode_back : in std_logic_vector(6 downto 0); -- opcode of the "writing back" instruction
    AR          : in std_logic_vector(15 downto 0); -- Arithmetic result (data) from the "wiring back" instruction
    ra          : in std_logic_vector(2 downto 0); -- writeback register of the "writing back" instruction
    rd_2        : in std_logic_vector(2 downto 0); -- Second register from "current" instruction
);
end RegisterArbitrator;