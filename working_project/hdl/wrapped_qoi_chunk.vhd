library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
    use work.PKG_hwswcd.ALL;

entity wrapped_qoi_chunk is
    Port ( 
        clock: in std_logic;
        reset: in std_logic;
        iface_di : in STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
        iface_a : in STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
        iface_we : in STD_LOGIC;
        iface_do : out STD_LOGIC_VECTOR(C_WIDTH-1 downto 0)
    );
end wrapped_qoi_chunk;


architecture Behavioral of wrapped_qoi_chunk is

    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal iface_di_i : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal iface_a_i : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal iface_we_i : STD_LOGIC;
    signal iface_do_o : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    
    signal reg0, reg1, reg2, reg3: STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal address_within_range, address_for_sensor : STD_LOGIC;
    signal targeted_register : STD_LOGIC_VECTOR(17 downto 0);
    signal qoi_result: std_logic_vector (C_WIDTH-1 downto 0);
    
    component QOI_chuck is
        port(
            clock: in std_logic;
            reset: in std_logic;
            pixel_data: in STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
            result_out: out std_logic_vector(C_WIDTH-1 downto 0)
        );
    end component; 

begin
    
    clock_i <= clock;
    reset_i <= reset;
    iface_di_i <= iface_di;
    iface_a_i <= iface_a;
    iface_we_i <= iface_we;
    iface_do <= iface_do_o;
    
    address_for_sensor <= '1' when iface_a_i = x"82000000" else '0';
    address_within_range <= '1' when iface_a_i(C_WIDTH-1 downto C_PERIPHERAL_MASK_LOWINDEX) = C_CHUNK_BASE_ADDRESS_MASK else '0';
    targeted_register <= iface_a_i(19 downto 2);
    
    reg1 <= qoi_result;
    
    PREG: process(clock_i)
    begin
        if rising_edge(clock_i) then
            if reset_i = '1' then 
                reg0 <= (others => '0');
            else
                if address_for_sensor = '1' then  
                    reg0 <= iface_di_i;
                end if;
            end if;
        end if;
    end process;
    
    PMUX: process(address_within_range, iface_we_i, targeted_register, reg0, reg1, reg2, reg3)
    begin
        iface_do_o <= C_GND;
        if address_within_range = '1' and iface_we_i = '0' then 
            case targeted_register is
                when "000000000000000000" => iface_do_o <= reg0;
                when "000000000000000001" => iface_do_o <= reg1;
                when "000000000000000010" => iface_do_o <= reg2;
                when "000000000000000011" => iface_do_o <= reg3;
                when others  => iface_do_o <= C_GND;
            end case;
        end if;
    end process;


QOI_chuck_1: component QOI_chuck port map(
        clock => clock_i,
        reset => reset_i,
        pixel_data => reg0,
        result_out => qoi_result 
);

end Behavioral;
