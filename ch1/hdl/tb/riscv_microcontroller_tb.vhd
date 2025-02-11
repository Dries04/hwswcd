--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC - Emerging technologies, Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     riscv_microcontroller_tb - Behavioural
-- Project Name:    Testbench for RISC-V microcontroller
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20241128   VlJo       Initial version
--
--------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

library work;
    use work.PKG_hwswcd.ALL;

entity riscv_microcontroller_tb is
    generic (
        G_DATA_WIDTH : integer := 32;
        G_DEPTH_LOG2 : integer := 11;

        FNAME_IMEM_INIT_FILE : string := "/home/jvliegen/Desktop/temp/ch1/firmware/course_example_2/firmware_imem.hex";
        FNAME_DMEM_INIT_FILE : string := "/home/jvliegen/Desktop/temp/ch1/firmware/course_example_2/firmware_dmem.hex";
        FNAME_OUT_FILE :       string := "/home/jvliegen/Desktop/temp/ch1/firmware/course_example_2/simulation_output.txt"
    );
end entity riscv_microcontroller_tb;

architecture Behavioural of riscv_microcontroller_tb is

    -- clock and reset
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;

    --imem
    signal imem_ad : STD_LOGIC_VECTOR(G_DEPTH_LOG2-1 downto 0);
    signal imem_do : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);

    --dmem
    signal dmem_di : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal dmem_ad : STD_LOGIC_VECTOR(G_DEPTH_LOG2-1 downto 0);
    signal dmem_we : STD_LOGIC;
    signal dmem_do : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    
    --other
    signal dmem_address : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
    signal program_counter : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);

    -- constants
    constant C_ZEROES: STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0) := (others => '0');
    constant clock_period : time := 10 ns;

begin

    -------------------------------------------------------------------------------
    -- STIMULI
    -------------------------------------------------------------------------------
    PSTIM: process(reset_i, program_counter)
    begin
        
        if reset_i = '0' then 
            if program_counter(G_DATA_WIDTH-1 downto G_DEPTH_LOG2+2) /= C_zeroes(G_DATA_WIDTH-1 downto G_DEPTH_LOG2+2) then
                report "ERROR: IMEM OUT OF RANGE" severity error;
            end if;
        end if;
    end process;


    -------------------------------------------------------------------------------
    -- DUT
    -------------------------------------------------------------------------------
    DUT: component riscv_microcontroller port map(
        clock => clock_i,
        reset => reset_i,
        dmem_do => dmem_do,
        dmem_we => dmem_we,
        dmem_a => dmem_address,
        dmem_di => dmem_di,
        instruction => imem_do,
        PC => program_counter
    );

    dmem_ad <= dmem_address(G_DEPTH_LOG2-1 downto 0);
    imem_ad <= program_counter(G_DEPTH_LOG2-1+2 downto 0+2);


    -------------------------------------------------------------------------------
    -- IMEM
    -------------------------------------------------------------------------------
    IMEM: component imem_model generic map(
        G_DATA_WIDTH => G_DATA_WIDTH,
        G_DEPTH_LOG2 => G_DEPTH_LOG2,
        FNAME_INIT_FILE => FNAME_IMEM_INIT_FILE
    ) port map(
        clock => clock_i,
        reset => reset_i,
        ad => imem_ad,
        do => imem_do
    );


    -------------------------------------------------------------------------------
    -- DMEM
    -------------------------------------------------------------------------------
    DMEM: component dmem_model generic map(
        G_DATA_WIDTH => G_DATA_WIDTH,
        G_DEPTH_LOG2 => G_DEPTH_LOG2,
        FNAME_INIT_FILE => FNAME_DMEM_INIT_FILE
    ) port map(
        clock => clock_i,
        reset => reset_i,
        di => dmem_di,
        ad => dmem_ad,
        we => dmem_we,
        do => dmem_do
    );
   
    -------------------------------------------------------------------------------
    -- Basic IO
    -------------------------------------------------------------------------------
    basicIO_model_inst00: component basicIO_model generic map(
        G_DATA_WIDTH => G_DATA_WIDTH,
        FNAME_OUT_FILE => FNAME_OUT_FILE
    ) port map(
        clock => clock_i,
        reset => reset_i,
        di => dmem_di,
        ad => dmem_address,
        we => dmem_we,
        do => open
    );

    -------------------------------------------------------------------------------
    -- CLOCK
    -------------------------------------------------------------------------------
    PCLK: process
    begin
        clock_i <= '1';
        wait for clock_period/2;
        clock_i <= '0';
        wait for clock_period/2;
    end process PCLK;


    -------------------------------------------------------------------------------
    -- RESET
    -------------------------------------------------------------------------------
    PRST: process
    begin
        reset_i <= '1';
        wait for clock_period*9;
        wait for clock_period/2;
        reset_i <= '0';
        wait;
    end process PRST;

end Behavioural;