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
    signal result_1 : std_logic_vector(7 downto 0);

    
begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    clock_i <= clock;
    reset_i <= reset;
    pixeldata_i <= pixel_data;
    pixeldata_prev_i <= pixel_data_prev;
    result_out <= result;
    
    r_cur <= pixeldata_i(31 downto 24);
    g_cur <= pixeldata_i(23 downto 16);
    b_cur <= pixeldata_i(15 downto 8);
    
    r_prev <= pixeldata_prev_i(31 downto 24);
    g_prev <= pixeldata_prev_i(23 downto 16);
    b_prev <= pixeldata_prev_i(15 downto 8);
    
    dr_unsigned <= unsigned(r_cur) - unsigned (r_prev);
    dg_unsigned <= unsigned (g_cur) - unsigned (g_prev);
    db_unsigned <= unsigned (b_cur) - unsigned (b_prev);

    -- Conversie naar signed (type casting)
    dr <= signed(dr_unsigned);
    dg <= signed(dg_unsigned);
    db <= signed(db_unsigned);
    
    dr_dg <= dr - dg;
    db_dg <= db - dg;
    
    
    process (dr, dg, db)
    begin      
    if reset_i = '1' then
        result_1 <= (others => '0');
        result <= (others => '0');
        dr2 <= (others => '0');
        dg2 <= (others => '0');
        db2 <= (others => '0');
    else
            if (dr >= -2 and dr <= 1) and (dg >= -2 and dg <= 1) and (db >= -2 and db <= 1) then
                --&result <= "00000000000000000000000000000001";
                    -- Add 2 and convert to 2-bit vectors
                dr2 <= std_logic_vector(to_unsigned(to_integer(dr) + 2, 2));
                dg2 <= std_logic_vector(to_unsigned(to_integer(dg) + 2, 2));
                db2 <= std_logic_vector(to_unsigned(to_integer(db) + 2, 2));
                
            
                -- Combine bits: 01xxxxxx format
                result_1 <= "01" & dr2 & dg2 & db2;  -- 8 bits total
                
                -- Pack into final result, assuming LSB-aligned in 32-bit word
                result <= (31 downto 8 => '0') & result_1;
                      
        elsif (dg >= -32 and dg <= 31) then
            
            if ((dr - dg) >= -8 and (dr - dg) <= 7) and ((db - dg) >= -8 and (db - dg) <= 7) then
            -- QOI OP LIMA
                result <= "00000000000000000000000000000010";
                
--                result <= QOI_OP_LUMA or std_logic_vector(dg + to_signed(32, 8));
              
            else
            -- QOI OP RGB
                result <= "00000000000000000000000000000011";
               
            end if;
            
        else 
        -- QOI OP RGBA
            result <= "00000000000000000000000000000100";
          
        end if;
    end if;
    end process;
   

end Behavioral;