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
        sys_clock : in STD_LOGIC;
        sys_reset : in STD_LOGIC;
        irq : in STD_LOGIC_VECTOR(31 downto 0);
        gpio_leds : out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity riscv_microcontroller;

architecture Behavioural of riscv_microcontroller is


    -- (DE-)LOCALISING IN/OUTPUTS
    signal sys_clock_i : STD_LOGIC;
    signal sys_reset_i : STD_LOGIC;
    signal irq_i : STD_LOGIC_VECTOR(31 downto 0);
    signal gpio_leds_o : STD_LOGIC_VECTOR(3 downto 0);

    -- dmem
    signal dmem_do : STD_LOGIC_VECTOR(31 downto 0);
    signal dmem_do_dmem : STD_LOGIC_VECTOR(31 downto 0);
    signal dmem_we : STD_LOGIC;
    signal dmem_a : STD_LOGIC_VECTOR(31 downto 0);
    signal dmem_di : STD_LOGIC_VECTOR(31 downto 0);
    
    --imem
    signal instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal PC : STD_LOGIC_VECTOR(31 downto 0);
    
    -- CLOCK AND RESET
    signal clock : STD_LOGIC;
    signal reset : STD_LOGIC;
    
    signal ce : STD_LOGIC_VECTOR(2 downto 0);
    
    signal dmem_do_tcnt : STD_LOGIC_VECTOR(31 downto 0);
    signal leds : STD_LOGIC_VECTOR(31 downto 0);

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    sys_clock_i <= sys_clock;
    sys_reset_i <= sys_reset;
    irq_i <= irq;
    gpio_leds <= gpio_leds_o;



    gpio_leds_o <= leds(3 downto 0);

    -------------------------------------------------------------------------------
    -- MICROPROCESSOR
    -------------------------------------------------------------------------------
    riscv_inst00: component riscv port map(
        clock => clock,
        reset => reset,
        ce => ce(0),
        irq => irq_i,
        dmem_do => dmem_do,
        dmem_we => dmem_we,
        dmem_a => dmem_a,
        dmem_di => dmem_di,
        instruction => instruction,
        PC => PC
    );

    PREG_CPU_CTRL: process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then 
                ce <= (0 => '1', others => '0');
            else
                ce <= ce(0) & ce(ce'high downto 1);
            end if;
        end if;
    end process;


    -------------------------------------------------------------------------------
    -- MUXING
    -------------------------------------------------------------------------------
    PMUX_bus: process(dmem_a, dmem_do_tcnt, dmem_do_dmem)
    begin
        case dmem_a(dmem_a'high downto 12) is
            when C_TIMER_BASE_ADDRESS_MASK => dmem_do <= dmem_do_tcnt;
            when others => dmem_do <= dmem_do_dmem;
        end case;
    end process;

    -------------------------------------------------------------------------------
    -- MEMORIES
    -------------------------------------------------------------------------------
    two_k_bram_dmem_inst00: component two_k_bram_dmem port map(
        clock => clock,
        init_data_in => C_GND,
        init_write_enable => C_GND(0),
        init_address => C_GND(10 downto 0),
        data_in => dmem_di,
        write_enable => dmem_we,
        address => dmem_a(10 downto 0),
        data_out  => dmem_do_dmem
    );


    two_k_bram_imem_inst00: component two_k_bram_imem port map(
        clock => clock,
        init_data_in => C_GND,
        init_write_enable => C_GND(0),
        init_address => C_GND(10 downto 0),
        data_in => C_GND,
        write_enable => C_GND(0),
        address => PC(12 downto 2),
        data_out => instruction
    );

    -------------------------------------------------------------------------------
    -- PERIPHERALS
    -------------------------------------------------------------------------------
    PREG_LEDS: process(clock)
    begin
        if rising_edge(clock) then 
            if reset = '1' then 
                leds <= C_GND;
            else
                if dmem_we = '1' and dmem_a = x"80000000" then 
                    leds <= dmem_di;
                end if;
            end if;
        end if;
    end process;

    wrapped_timer_inst00: component wrapped_timer generic map(G_WIDTH => C_WIDTH) port map (
        clock => clock,
        reset => reset,
        iface_di => dmem_di,
        iface_a => dmem_a,
        iface_we => dmem_we,
        iface_do => dmem_do_tcnt
    );


    -------------------------------------------------------------------------------
    -- CLOCK AND RESET
    -------------------------------------------------------------------------------
    clock_and_reset_pynq_inst00: component clock_and_reset_pynq port map(
        sysclock => sys_clock_i,
        sysreset => sys_reset_i,
        sreset => reset,
        clock => clock,
        heartbeat => open
    );

end Behavioural;
