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
        result_out: out std_logic_vector(C_WIDTH-1 downto 0);
        result_1: out std_logic_vector(C_WIDTH-1 downto 0);
        result_2: out std_logic_vector(C_WIDTH-1 downto 0)
    );
end QOI_chuck;

architecture Behavioral of QOI_chuck is

    -- Signal Declarations
    signal r_cur, g_cur, b_cur : std_logic_vector(7 downto 0);  -- 8-bit RGB channels for the current pixel
    signal r_prev, g_prev, b_prev : std_logic_vector(7 downto 0);  -- 8-bit RGB channels for the previous pixel
    
    -- (DE-)LOCALISING IN/OUTPUTS
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal pixeldata : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal iface_a_i : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal iface_we_i : STD_LOGIC;
    signal iface_do_o : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    
    -- code logic
    signal dr_unsigned : unsigned(7 downto 0); -- Ga ervan uit dat je 8-bit unsigned waarden hebt
    signal dg_unsigned : unsigned(7 downto 0);
    signal db_unsigned : unsigned(7 downto 0);
    signal dr          : signed(7 downto 0);   -- Signed kan een bit groter zijn ivm potentiele overflow bij conversie
    signal dg          : signed(7 downto 0);
    signal db          : signed(7 downto 0);
   

    
    signal result: std_logic_vector (31 downto 0);
    signal pixeldata_i, pixeldata_prev_i : std_logic_vector (31 downto 0);
    
    signal dr_dg, db_dg       : signed(7 downto 0);
    constant QOI_OP_LUMA  : std_logic_vector(7 downto 0) := x"80";
    
    signal dr2, dg2, db2 : std_logic_vector(1 downto 0);
    signal result_1, result_2 : std_logic_vector(7 downto 0);
    
    signal dg_plus_32 : unsigned(7 downto 0);
    signal luma_result : std_logic_vector(7 downto 0);

    signal drdg_add8, dbdg_add8 : unsigned(3 downto 0);
    signal led_result : std_logic_vector(7 downto 0);
    
    
    
    -----
    -----
    signal reg0, reg1, reg2, reg3, diff_pixel, diff_pixel_luma, diff_pixel_luma_1, diff_pixel_luma_2: STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    
    signal cur_pixel, buff_prev_pixel: unsigned(C_WIDTH-1 downto 0);
    signal cr, cg, cb, ca, pr, pg, pb, pa: unsigned(7 downto 0);
    signal temp_dr, temp_dg, temp_db, temp_dgg, temp_drg, temp_dbg: signed(7 downto 0);
    signal drg, dbg: signed(7 downto 0); 
    
    signal address_within_range : STD_LOGIC;
    signal targeted_register : STD_LOGIC_VECTOR(17 downto 0);



    signal sensor_re : STD_LOGIC;
    signal sensor_pixeldata : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal sensor_first : STD_LOGIC;


begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    clock_i <= clock;
    reset_i <= reset;
    pixeldata_i <= pixel_data;
    pixeldata_prev_i <= pixel_data_prev;
    result_out <= result;
    
--    r_cur <= pixeldata_i(31 downto 24);
--    g_cur <= pixeldata_i(23 downto 16);
--    b_cur <= pixeldata_i(15 downto 8);
    
--    r_prev <= pixeldata_prev_i(31 downto 24);
--    g_prev <= pixeldata_prev_i(23 downto 16);
--    b_prev <= pixeldata_prev_i(15 downto 8);
    
--    dr_unsigned <= unsigned(r_cur) - unsigned (r_prev);
--    dg_unsigned <= unsigned (g_cur) - unsigned (g_prev);
--    db_unsigned <= unsigned (b_cur) - unsigned (b_prev);

--    -- Conversie naar signed (type casting)
--    dr <= signed(dr_unsigned);
--    dg <= signed(dg_unsigned);
--    db <= signed(db_unsigned);
    
--    dr_dg <= dr - dg;
--    db_dg <= db - dg;
    
    sensor_re <= reg0(0);
    cur_pixel <= unsigned(pixeldata_i);
    buff_prev_pixel <= unsigned(pixel_data_prev);
    -- reg2 <= (0 => sensor_first, others => '0');
    -- reg2 <= x"00" & x"08" & x"08" & "0000000" & sensor_first;
    reg2 <= x"00" & x"4B" & x"32" & "0000000" & sensor_first;
    
    cr <= cur_pixel(31 downto 24);
    cg <= cur_pixel(23 downto 16);
    cb <= cur_pixel(15 downto 8);
    ca <= cur_pixel(7 downto 0);

    pr <= buff_prev_pixel(31 downto 24);
    pg <= buff_prev_pixel(23 downto 16);
    pb <= buff_prev_pixel(15 downto 8);
    pa <= buff_prev_pixel(7 downto 0);
    
    temp_dr <= dr + 2;
    temp_dg <= dg + 2;
    temp_db <= db + 2;
    
    diff_pixel(31 downto 8) <= (others => '0');
    diff_pixel(7 downto 6) <= b"01";
    diff_pixel(5 downto 4) <= std_logic_vector(temp_dr(1 downto 0));
    diff_pixel(3 downto 2) <= std_logic_vector(temp_dg(1 downto 0));
    diff_pixel(1 downto 0) <= std_logic_vector(temp_db(1 downto 0));
    
    
    drg <= dr - dg;
    dbg <= db - dg;
    
    temp_dgg <= dg + 32;
    temp_drg <= drg + 8;
    temp_dbg <= dbg + 8;
    
--    diff_pixel_luma(31 downto 16) <= (others => '0');
--    diff_pixel_luma(15 downto 14) <= b"10";
--    diff_pixel_luma(13 downto 8) <= std_logic_vector(temp_dgg(5 downto 0));
--    diff_pixel_luma(7 downto 4) <= std_logic_vector(temp_drg(3 downto 0));
--    diff_pixel_luma(3 downto 0) <= std_logic_vector(temp_dbg(3 downto 0));

      diff_pixel_luma_1(8 downto 7) <= b"01";
      diff_pixel_luma_1(7 downto 0) <= std_logic_vector(temp_dr(1 downto 0));
      diff_pixel_luma_2(7 downto 4) <= std_logic_vector(temp_dg(1 downto 0));
      diff_pixel_luma_2(3 downto 0) <= std_logic_vector(temp_db(1 downto 0));
    
--    dr <= signed(cr) - signed(pr);
--    dg <= signed(cg) - signed(pg);
--    db <= signed(cb) - signed(pb);
    
    CLOSE_DIFF: process(cr, pr, cg, pg, cb, pb)
    begin
        if cr > pr then
            dr <= signed(256 - (pr - cr));
        else
            dr <= signed(cr - pr);
        end if;
        
        if cg > pg then
            dg <= signed(256 - (pg - cg));
        else
            dg <= signed(cg - pg);
        end if;
        
        if cb > pb then
            db <= signed(256 - (pb - cb));
        else
            db <= signed(cb - pb);
        end if;
    end process;
        
    COMPUTE: process(dr, dg, db, ca, drg, dbg, diff_pixel, diff_pixel_luma)
    begin
        if diff_pixel = x"5a" then
            result <= diff_pixel;
        end if;
        if (dr >= -2 and dr <= 1 and dg >= -2 and dg <= 1 and db >= -2 and db <= 1) then
            result <= diff_pixel;
        elsif (dg >= -32 and dg <= 31 and (dr - dg) >= -8 and (dr - dg) <= 7 and (db - dg) >= -8 and (db - dg) <= 7 and ca = pa) then
            result <= diff_pixel_luma;
            result <= x"fff";
            result_1 <= diff_pixel_luma_1;
            result_2 <= diff_pixel_luma_2;
        else
            result <= x"00000000";
        end if;
    end process;


    
    
    
--    process (dr, dg, db)
--    begin      
--    if reset_i = '1' then
--        result_1 <= (others => '0');
--        result <= (others => '0');
--        dr2 <= (others => '0');
--        dg2 <= (others => '0');
--        db2 <= (others => '0');
--    else
--            if (dr >= -2 and dr <= 1 and dg >= -2 and dg <= 1 and db >= -2 and db <= 1 then
--                result <= "00000000000000000000000000001001";
--                    -- Add 2 and convert to 2-bit vectors
----                dr2 <= std_logic_vector(to_unsigned(to_integer(dr) + 2, 2));
----                dg2 <= std_logic_vector(to_unsigned(to_integer(dg) + 2, 2));
----                db2 <= std_logic_vector(to_unsigned(to_integer(db) + 2, 2));
                
            
----                -- Combine bits: 01xxxxxx format
----                result_1 <= "01" & dr2 & dg2 & db2;  -- 8 bits total
                
----                -- Pack into final result, assuming LSB-aligned in 32-bit word
----                result <= (31 downto 8 => '0') & result_1;
                      
--        elsif (dg >= -32 and dg <= 31) then
            
--            if ((dr - dg) >= -8 and (dr - dg) <= 7) and ((db - dg) >= -8 and (db - dg) <= 7) then
--            -- QOI OP LIMA
--                --result <= "00000000000000000000000000000010";
                
----                result <= QOI_OP_LUMA or std_logic_vector(dg + to_signed(32, 8));
                
--                -- Alleen binnen het if-statement voor QOI_OP_LUMA
----                dg_plus_32 <= unsigned(dg) + to_unsigned(32, 8);
----                luma_result <= QOI_OP_LUMA or std_logic_vector(dg_plus_32);
----                result <= (31 downto 8 => '0') & luma_result;


--            else
--            -- QOI OP RGB
--                result <= "00000000000000000000000000000011";
               
--            end if;
            
--        else 
--        -- QOI OP RGBA
--            result <= "00000000000000000000000000000100";
          
--        end if;
--    end if;
--    end process;
   

end Behavioral;