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
    signal first_pixel: std_logic;
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
    first_pixel <= '1';
    result_out <= result;
    
    r_cur <= pixeldata(31 downto 24);
    g_cur <= pixeldata(23 downto 16);
    b_cur <= pixeldata(15 downto 8);
    
    dr_unsigned <= unsigned(r_cur) - unsigned (r_prev);
    dg_unsigned <= unsigned (g_cur) - unsigned (g_prev);
    db_unsigned <= unsigned (b_cur) - unsigned (b_prev);

    -- Conversie naar signed (type casting)
    dr <= signed(dr_unsigned);
    dg <= signed(dg_unsigned);
    db <= signed(db_unsigned);
    
    process (dr, dg, db, r_cur, g_cur, b_cur)
    begin
        if (dr >= -2 and dr <= 1) and (dg >= -2 and dg <= 1) and (db >= -2 and db <= 1) then
            result <= "00000000000000000000000000000001";
            make_current_previous <= '1';
--            part_1 <= "01000000";
--            case dr is
--                when "11111110" => dr_plus_2 <= "00"; -- -2 + 2 = 0
--                when "11111111" => dr_plus_2 <= "01"; -- -1 + 2 = 1
--                when "00000000" => dr_plus_2 <= "10"; --  0 + 2 = 2
--                when "00000001" => dr_plus_2 <= "11"; --  1 + 2 = 3
--                when others     => dr_plus_2 <= "00"; -- default/failsafe
--            end case;
--            part_2 <= dr_plus_2 & "0000";
--            case dg is
--                when "11111110" => dr_plus_2 <= "00"; -- -2 + 2 = 0
--                when "11111111" => dr_plus_2 <= "01"; -- -1 + 2 = 1
--                when "00000000" => dr_plus_2 <= "10"; --  0 + 2 = 2
--                when "00000001" => dr_plus_2 <= "11"; --  1 + 2 = 3
--                when others     => dr_plus_2 <= "00"; -- default/failsafe
--            end case;
--            part_3 <= dg_plus_2 & "00";
--            case db is
--                when "11111110" => dr_plus_2 <= "00"; -- -2 + 2 = 0
--                when "11111111" => dr_plus_2 <= "01"; -- -1 + 2 = 1
--                when "00000000" => dr_plus_2 <= "10"; --  0 + 2 = 2
--                when "00000001" => dr_plus_2 <= "11"; --  1 + 2 = 3
--                when others     => dr_plus_2 <= "00"; -- default/failsafe
--            end case;
--            part_4 <= db_plus_2;  
--            result <= part_1 or part_2 or part_3 or part_4;       
    elsif (dg >= -32 and dg <= 31) then
        
        if ((dr - dg) >= -8 and (dr - dg) <= 7) and ((db - dg) >= -8 and (db - dg) <= 7) then
        -- QOI OP LIMA
            result <= "00000000000000000000000000000011";
            make_current_previous <= '1';
        else
        -- QOI OP RGB
            result <= "00000000000000000000000000000010";
            make_current_previous <= '1';
        end if;
        
    else 
    -- QOI OP RGBA
        result <= "00000000000000000000000000000100";
        make_current_previous <= '1';
    end if;
    end process;
    
    process (make_current_previous)
    begin
      if make_current_previous = '1' and first_pixel = '0' then
        r_prev <= r_cur;
        g_prev <= g_cur;
        b_prev <= b_cur;
        make_current_previous <= '0';
      elsif make_current_previous = '1' and first_pixel = '1' then
        r_prev <= (others => '0');
        g_prev <= (others => '0');
        b_prev <= (others => '0');
        make_current_previous <= '0';
        first_pixel <= '0';
      end if;
    end process;

end Behavioral;
