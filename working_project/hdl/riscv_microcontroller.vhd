--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC - Emerging technologies, Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     riscv_microcontroller - Behavioural
-- Project Name:    riscv_microcontroller
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20241210   VlJo       Initial version
--
--------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.NUMERIC_STD.ALL;

library work;
    use work.PKG_hwswcd.ALL;

entity riscv_microcontroller is
    port(
        clock : in STD_LOGIC;
        reset : in STD_LOGIC;

        -- dmem
        dmem_do : in STD_LOGIC_VECTOR(31 downto 0);
        dmem_we : out STD_LOGIC;
        dmem_a : out STD_LOGIC_VECTOR(31 downto 0);
        dmem_di : out STD_LOGIC_VECTOR(31 downto 0);

        -- imem
        instruction : in STD_LOGIC_VECTOR(31 downto 0);
        PC : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity riscv_microcontroller;

architecture Behavioural of riscv_microcontroller is

    -- (DE-)LOCALISING IN/OUTPUTS
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal dmem_do_i : STD_LOGIC_VECTOR(31 downto 0);
    signal dmem_we_o : STD_LOGIC;
    signal dmem_a_o : STD_LOGIC_VECTOR(31 downto 0);
    signal dmem_di_o : STD_LOGIC_VECTOR(31 downto 0);
    signal instruction_i : STD_LOGIC_VECTOR(31 downto 0);
    signal PC_o : STD_LOGIC_VECTOR(31 downto 0);

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    clock_i <= clock;
    reset_i <= reset;
    dmem_do_i <= dmem_do;
    dmem_we <= dmem_we_o;
    dmem_a <= dmem_a_o;
    dmem_di <= dmem_di_o;
    instruction_i <= instruction;
    PC <= PC_o;


    -------------------------------------------------------------------------------
    -- MICROPROCESSOR
    -------------------------------------------------------------------------------
    riscv_inst00: component riscv port map(
        clock => clock_i,
        reset => reset_i,
        dmem_do => dmem_do_i,
        dmem_we => dmem_we_o,
        dmem_a => dmem_a_o,
        dmem_di => dmem_di_o,
        instruction => instruction_i,
        PC => PC_o
    );

end Behavioural;
