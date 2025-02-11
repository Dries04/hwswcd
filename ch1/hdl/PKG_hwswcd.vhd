--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC - Emerging technologies, Systems & Security
--------------------------------------------------------------------------------
-- Package Name:    PKG_hwswcd
-- Project Name:    HWSWCD
-- Description:     Package for the HWSWCD code
--
-- Revision     Date       Author     Comments
-- v0.1         20241126   VlJo       Initial version
--
--------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
--    use IEEE.NUMERIC_STD.ALL;

package PKG_hwswcd is

    -------------------------------------------------------------------------------
    -- CONSTANTS
    -------------------------------------------------------------------------------
    constant C_REGCOUNT : natural := 32;
    constant C_REGCOUNT_LOG2 : natural := 5;
    constant C_WIDTH : natural := 32;
    constant C_GND : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0) := (others => '0');
    constant C_VCC : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0) := (others => '1');
    constant C_FOUR : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0) := (2 => '1', others => '0');

    -- constant C_PERIPHERAL_MASK_PADDING : STD_LOGIC_VECTOR()

    -- Peripherals are all assigned a BASE ADDRESS.
    -- From this address 256 positions are reserved.
    -- This comes down to 64 32-bit words.
    -- A peripheral can hence have 64 memory-mapped registers
    constant C_TIMER_BASE_ADDRESS_MASK : STD_LOGIC_VECTOR(C_WIDTH-1 downto 8) := x"800001";

    constant C_MRO_xF11_MVENDORID : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0) := x"01234568";
    constant C_MRO_xF14_MHARTID : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0) := x"CAFEBABE";

    -------------------------------------------------------------------------------
    -- TYPES
    -------------------------------------------------------------------------------
    type T_regfile is array (0 to C_REGCOUNT-1) of STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    type T_imem is array(0 to 255) of STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    type T_dmem is array(0 to 255) of STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);


    -------------------------------------------------------------------------------
    -- DECLARATIONS
    -------------------------------------------------------------------------------
    component reg_file is
        port(
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            we : in std_logic;
            src1 : in std_logic_vector(C_REGCOUNT_LOG2-1 downto 0);
            src2 : in std_logic_vector(C_REGCOUNT_LOG2-1 downto 0);
            dest : in std_logic_vector(C_REGCOUNT_LOG2-1 downto 0);
            data : in std_logic_vector(C_WIDTH-1 downto 0);
            data1 : out std_logic_vector(C_WIDTH-1 downto 0);
            data2 : out std_logic_vector(C_WIDTH-1 downto 0)
        );
    end component reg_file;

    component alu is
        port(
            operator1 : in std_logic_vector(C_WIDTH-1 downto 0);
            operator2 : in std_logic_vector(C_WIDTH-1 downto 0);
            ALUOp : in std_logic_vector(2 downto 0);
            arith_logic_b : in STD_LOGIC;
            signed_unsigned_b : in STD_LOGIC;
            result : out std_logic_vector(C_WIDTH-1 downto 0);
            zero : out std_logic;
            equal : out std_logic;
            carryOut : out std_logic;
            x_lt_y_u : out std_logic;
            x_lt_y_s : out std_logic
        );
    end component alu;

    component immediate_gen is
        port(
            instruction : in STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
            immediate : out STD_LOGIC_VECTOR(C_WIDTH-1 downto 0)
        );
    end component immediate_gen;

    component control is
        port(
            opcode : in std_logic_vector(6 downto 0);
            funct3 : in std_logic_vector(2 downto 0);
            funct7 : in std_logic_vector(6 downto 0);
            ToRegister : out std_logic_vector(2 downto 0);
            mem_we : out std_logic;
            Branch : out std_logic_vector(3 downto 0);
            ALUOp : out std_logic_vector(2 downto 0);
            StoreSel : out std_logic_vector(1 downto 0);
            ALUSrc : out std_logic;
            regfile_we : out std_logic;
            arith_logic_b : out STD_LOGIC;
            signed_unsigned_b : out STD_LOGIC;
            result_filter : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component control;

    component riscv is
        port(
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            dmem_do : in STD_LOGIC_VECTOR(31 downto 0);
            dmem_we : out STD_LOGIC;
            dmem_a : out STD_LOGIC_VECTOR(31 downto 0);
            dmem_di : out STD_LOGIC_VECTOR(31 downto 0);
            instruction : in STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
            PC : out STD_LOGIC_VECTOR(C_WIDTH-1 downto 0)
        );
    end component riscv;

    component riscv_microcontroller is
        port(
            clock : in STD_LOGIC;
            reset : in STD_LOGIC;
            dmem_do : in STD_LOGIC_VECTOR(31 downto 0);
            dmem_we : out STD_LOGIC;
            dmem_a : out STD_LOGIC_VECTOR(31 downto 0);
            dmem_di : out STD_LOGIC_VECTOR(31 downto 0);
            instruction : in STD_LOGIC_VECTOR(31 downto 0);
            PC : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component riscv_microcontroller;

    component dmem_model is
        generic (
            G_DATA_WIDTH : integer := 32;
            G_DEPTH_LOG2 : integer := 10;
            FNAME_INIT_FILE : string := "data.dat"
        );
        port (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            di : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            ad : IN STD_LOGIC_VECTOR(G_DEPTH_LOG2-1 downto 0);
            we : IN STD_LOGIC;
            do : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0)
        );
    end component dmem_model;

    component imem_model is
        generic (
            G_DATA_WIDTH : integer := 32;
            G_DEPTH_LOG2 : integer := 10;
            FNAME_INIT_FILE : string := "data.dat"
        );
        port (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            ad : IN STD_LOGIC_VECTOR(G_DEPTH_LOG2-1 downto 0);
            do : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0)
        );
    end component imem_model;
    
    component basicIO_model is
        generic (
            G_DATA_WIDTH : integer := 32;
            FNAME_OUT_FILE : string := "data.dat"
        );
        port (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            di : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            ad : IN STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            we : IN STD_LOGIC;
            do : OUT STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0);
            writing_out_flag : OUT STD_LOGIC
        );
    end component basicIO_model;

end package;

package body PKG_hwswcd is

end package body;