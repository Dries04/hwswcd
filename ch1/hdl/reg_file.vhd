--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC - Emerging technologies, Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     reg_file - Behavioural
-- Project Name:    HWSWCD
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20241126   VlJo       Initial version
--
--------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

library work;
    use work.PKG_hwswcd.ALL;

entity reg_file is
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
end entity reg_file;

architecture Behavioural of reg_file is

    -- (DE-)LOCALISING IN/OUTPUTS
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal we_i : std_logic;
    signal src1_i : std_logic_vector(C_REGCOUNT_LOG2-1 downto 0);
    signal src2_i : std_logic_vector(C_REGCOUNT_LOG2-1 downto 0);
    signal dest_i : std_logic_vector(C_REGCOUNT_LOG2-1 downto 0);
    signal data_i : std_logic_vector(C_WIDTH-1 downto 0);
    signal data1_o : std_logic_vector(C_WIDTH-1 downto 0);
    signal data2_o : std_logic_vector(C_WIDTH-1 downto 0); 

    signal src1_int : natural range 0 to C_REGCOUNT-1;
    signal src2_int : natural range 0 to C_REGCOUNT-1;
    signal dest_int : natural range 0 to C_REGCOUNT-1;

    signal rf : T_regfile;
begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    clock_i <= clock;
    reset_i <= reset;
    we_i <= we;
    src1_i <= src1;
    src2_i <= src2;
    dest_i <= dest;
    data_i <= data;
    data1 <= data1_o;
    data2 <= data2_o;


    -------------------------------------------------------------------------------
    -- COMBINATORIAL
    -------------------------------------------------------------------------------
    src1_int <= to_integer(unsigned(src1_i));
    src2_int <= to_integer(unsigned(src2_i));
    dest_int <= to_integer(unsigned(dest_i));


    -------------------------------------------------------------------------------
    -- REGISTER
    -------------------------------------------------------------------------------
    PREG: process(clock_i)
    begin
        if rising_edge(clock_i) then
            if reset_i = '1' then 
                rf <= (others => (others => '0'));
            else
                if we_i = '1' and dest_int /= 0 then 
                    rf(dest_int) <= data_i;
                end if;
            end if;
        end if;
    end process;

    data1_o <= rf(src1_int);
    data2_o <= rf(src2_int);

end Behavioural;
