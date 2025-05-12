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
        pixel_data_prev : in  std_logic_vector(C_WIDTH-1 downto 0);
        result_out: out std_logic_vector(C_WIDTH-1 downto 0)
    );
end QOI_chuck;

architecture Behavioral of QOI_chuck is
    
    -- (DE-)LOCALISING IN/OUTPUTS
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    
    signal dr          : signed(7 downto 0);   -- Signed kan een bit groter zijn ivm potentiele overflow bij conversie
    signal dg          : signed(7 downto 0);
    signal db          : signed(7 downto 0);
   
    signal result: std_logic_vector (31 downto 0);
    signal pixeldata_i, pixeldata_prev_i : std_logic_vector (31 downto 0);
    
    signal  QOI_DIFF, QOI_LUMA: STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    
    signal cur_pixeldata, prev_pixeldata: unsigned(C_WIDTH-1 downto 0);
    signal r_cur, g_cur, b_cur, r_prev, g_prev, b_prev: unsigned(7 downto 0);
    signal temp_dr, temp_dg, temp_db, temp_dgg, temp_drg, temp_dbg: signed(7 downto 0);
    signal drg, dbg: signed(7 downto 0); 

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    clock_i <= clock;
    reset_i <= reset;
    pixeldata_i <= pixel_data;
    pixeldata_prev_i <= pixel_data_prev;
    result_out <= result;
    
    cur_pixeldata <= unsigned(pixeldata_i);
    prev_pixeldata <= unsigned(pixeldata_prev_i);
    
    r_cur <= cur_pixeldata(31 downto 24);
    g_cur <= cur_pixeldata(23 downto 16);
    b_cur <= cur_pixeldata(15 downto 8);

    r_prev <= prev_pixeldata(31 downto 24);
    g_prev <= prev_pixeldata(23 downto 16);
    b_prev <= prev_pixeldata(15 downto 8);
    
    temp_dr <= dr + 2;
    temp_dg <= dg + 2;
    temp_db <= db + 2;
    
    QOI_DIFF(31 downto 8) <= (others => '0');
    QOI_DIFF(7 downto 6) <= b"01";
    QOI_DIFF(5 downto 4) <= std_logic_vector(temp_dr(1 downto 0));
    QOI_DIFF(3 downto 2) <= std_logic_vector(temp_dg(1 downto 0));
    QOI_DIFF(1 downto 0) <= std_logic_vector(temp_db(1 downto 0));
    
    drg <= dr - dg;
    dbg <= db - dg;
    
    temp_dgg <= dg + 32;
    temp_drg <= drg + 8;
    temp_dbg <= dbg + 8;
    
    QOI_LUMA(31 downto 16) <= (others => '0');
    QOI_LUMA(15 downto 14) <= b"10";
    QOI_LUMA(13 downto 8) <= std_logic_vector(temp_dgg(5 downto 0));
    QOI_LUMA(7 downto 4) <= std_logic_vector(temp_drg(3 downto 0));
    QOI_LUMA(3 downto 0) <= std_logic_vector(temp_dbg(3 downto 0));

    SELECT_QOI_CHUNK: process(r_cur, g_cur, b_cur, r_prev, g_prev, b_prev, dr, dg, db, drg, dbg, QOI_DIFF, QOI_LUMA)
    begin
        if r_cur > r_prev then
            dr <= signed(256 - (r_prev - r_cur));
        else
            dr <= signed(r_cur - r_prev);
        end if;
        
        if g_cur > g_prev then
            dg <= signed(256 - (g_prev - g_cur));
        else
            dg <= signed(g_cur - g_prev);
        end if;
        
        if b_cur > b_prev then
            db <= signed(256 - (b_prev - b_cur));
        else
            db <= signed(b_cur - b_prev);
        end if;  

        if (dr >= -2 and dr <= 1 and dg >= -2 and dg <= 1 and db >= -2 and db <= 1) then
            result <= QOI_DIFF;
        elsif (dg >= -32 and dg <= 31 and (dr - dg) >= -8 and (dr - dg) <= 7 and (db - dg) >= -8 and (db - dg) <= 7) then
            result <= QOI_LUMA;
        else
            result <= x"00000000";
        end if;
    end process;

end Behavioral;