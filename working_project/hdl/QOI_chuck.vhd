library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    
use IEEE.NUMERIC_STD.ALL;

library work;
    use work.PKG_hwswcd.ALL;

entity QOI_chuck is
    Port ( 
        clock: in std_logic;
        reset: in std_logic;
        pixel_data: in STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
        result_out: out std_logic_vector(C_WIDTH-1 downto 0)
    );
end QOI_chuck;

architecture Behavioral of QOI_chuck is

    -- Signal Declarations
    signal r_cur, g_cur, b_cur : std_logic_vector(7 downto 0);  -- 8-bit RGB channels for the current pixel
    signal r_prev, g_prev, b_prev : std_logic_vector(7 downto 0);  -- 8-bit RGB channels for the previous pixel
    signal run : integer range 0 to 62 := 0;                       -- Counter for QOI_OP_RUN
    signal running_array : std_logic_vector(63 downto 0);           -- Array to hold previous pixels (up to 64 unique values)
    
    -- (DE-)LOCALISING IN/OUTPUTS
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal pixeldata : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal iface_a_i : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal iface_we_i : STD_LOGIC;
    signal iface_do_o : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    
    -- code logic
    signal make_current_previous: std_logic;
    signal first_pixel: std_logic := '1';
    signal dr_unsigned : unsigned(7 downto 0); -- Ga ervan uit dat je 8-bit unsigned waarden hebt
    signal dg_unsigned : unsigned(7 downto 0);
    signal db_unsigned : unsigned(7 downto 0);
    signal dr          : signed(7 downto 0);   -- Signed kan een bit groter zijn ivm potentiele overflow bij conversie
    signal dg          : signed(7 downto 0);
    signal db          : signed(7 downto 0);
    
    signal test: std_logic_vector(31 downto 0);
    signal part_1: std_logic_vector (7 downto 0);
    signal part_2: std_logic_vector (7 downto 0);
    signal part_3: std_logic_vector(7 downto 0);
    signal part_4: std_logic_vector(7 downto 0);
    signal dr_plus_2 : std_logic_vector(1 downto 0);
    signal dg_plus_2 : std_logic_vector(1 downto 0);
    signal db_plus_2 : std_logic_vector(1 downto 0);
    
    signal result: std_logic_vector (31 downto 0);
    
begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    clock_i <= clock;
    reset_i <= reset;
    pixeldata <= pixeldata;
    result_out <= result;
    
    process (clock_i)
    begin
        if rising_edge(clock_i) then
            if reset_i = '1' then
                make_current_previous <= '0';
                first_pixel <= '1';
                r_prev <= (others => '0');
                g_prev <= (others => '0');
                b_prev <= (others => '0');
            else
                -- Compute RGB diffs
                dr_unsigned <= unsigned(r_cur) - unsigned(r_prev);
                dg_unsigned <= unsigned(g_cur) - unsigned(g_prev);
                db_unsigned <= unsigned(b_cur) - unsigned(b_prev);
                dr <= signed(dr_unsigned);
                dg <= signed(dg_unsigned);
                db <= signed(db_unsigned);
    
                -- Main decision logic
                if (dr >= -2 and dr <= 1) and (dg >= -2 and dg <= 1) and (db >= -2 and db <= 1) then
                    result <= "00000000000000000000000000000001";
                    make_current_previous <= '1';
                elsif (dg >= -32 and dg <= 31) then
                    if ((dr - dg) >= -8 and (dr - dg) <= 7) and ((db - dg) >= -8 and (db - dg) <= 7) then
                        result <= "00000000000000000000000000000011";
                    else
                        result <= "00000000000000000000000000000010";
                    end if;
                    make_current_previous <= '1';
                else
                    result <= "00000000000000000000000000000100";
                    make_current_previous <= '1';
                end if;
    
                -- Store current as previous if needed
                if make_current_previous = '1' then
                    if first_pixel = '1' then
                        first_pixel <= '0';
                    end if;
                    r_prev <= r_cur;
                    g_prev <= g_cur;
                    b_prev <= b_cur;
                    make_current_previous <= '0';
                end if;
            end if;
        end if;
    end process;


end Behavioral;
