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

    component two_k_bram_dmem is
        port(
            clock : in STD_LOGIC;
            init_data_in : in STD_LOGIC_VECTOR(31 downto 0);
            init_write_enable : in STD_LOGIC;
            init_address : in STD_LOGIC_VECTOR(10 downto 0);
            data_in : in STD_LOGIC_VECTOR(31 downto 0);
            write_enable : in STD_LOGIC;
            address : in STD_LOGIC_VECTOR(10 downto 0);
            data_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component two_k_bram_dmem;

    component two_k_bram_imem is
        port(
            clock : in STD_LOGIC;
            init_data_in : in STD_LOGIC_VECTOR(31 downto 0);
            init_write_enable : in STD_LOGIC;
            init_address : in STD_LOGIC_VECTOR(10 downto 0);
            data_in : in STD_LOGIC_VECTOR(31 downto 0);
            write_enable : in STD_LOGIC;
            address : in STD_LOGIC_VECTOR(10 downto 0);
            data_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component two_k_bram_imem;

    -- (DE-)LOCALISING IN/OUTPUTS
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal dmem_do_i : STD_LOGIC_VECTOR(31 downto 0);
    signal dmem_we_o : STD_LOGIC;
    signal dmem_a_o : STD_LOGIC_VECTOR(31 downto 0);
    signal dmem_di_o : STD_LOGIC_VECTOR(31 downto 0);
    signal instruction_i : STD_LOGIC_VECTOR(31 downto 0);
    signal PC_o : STD_LOGIC_VECTOR(31 downto 0);
    
    -- clock and reset 
    signal reset_ii: std_logic;
    signal clock_ii: std_logic;
    signal heartbeat_i: std_logic;
    signal ce, ce_d : STD_LOGIC;
    
    --two_k_bram
    signal dmem_a_o_1: std_logic_vector (10 downto 0);
    signal pc_ii: std_logic_vector(12 downto 2);

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
    
    dmem_a_o_1 <= dmem_a_o (10 downto 0);
    pc <= pc_ii;
    
    -------------------------------------------------------------------------------
    -- CLOCK AND RESET
    -------------------------------------------------------------------------------
    
    clock_and_reset_pynq_1: component clock_and_reset_pynq port map(
        sysclock => clock_i,
        sysreset => reset_i,
        sreset => reset_ii,
        clock => clock_ii,
        heartbeat => heartbeat_i
    );
    
    -------------------------------------------------------------------------------
    -- MEMORIES
    -------------------------------------------------------------------------------
    
    two_k_bram_imem_inst00: component two_k_bram_imem port map (
        clock => clock_ii,

        init_data_in => C_GND,
        init_write_enable => C_GND(0),
        init_address => C_GND(10 downto 0),

        data_in => C_GND,
        write_enable => C_GND(0),
        address => PC_o(12 downto 2),
        data_out => instruction_i
    );

        two_k_bram_dmem_inst00: component two_k_bram_dmem port map(
        clock => clock,
        init_data_in => C_GND,
        init_write_enable => C_GND(0),
        init_address => C_GND(10 downto 0),

        data_in => dmem_di_o,
        write_enable => dmem_we_o,
        address => dmem_a_o_1,
        data_out => dmem_do_i
    );
    
    -------------------------------------------------------------------------------
    -- MICROPROCESSOR
    -------------------------------------------------------------------------------
    riscv_inst00: component riscv port map(
        clock => clock_ii,
        reset => reset_ii,
        dmem_do => dmem_do_i,
        dmem_we => dmem_we_o,
        dmem_a => dmem_a_o,
        dmem_di => dmem_di_o,
        instruction => instruction_i,
        PC => PC_o
    );
  
end Behavioural;
