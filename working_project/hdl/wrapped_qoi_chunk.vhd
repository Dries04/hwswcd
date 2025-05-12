library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- For unsigned comparisons

library work;
use work.PKG_hwswcd.ALL;

entity wrapped_qoi_chunk is
    Port ( 
        clock       : in  std_logic;
        reset       : in  std_logic;
        iface_di    : in  std_logic_vector(C_WIDTH-1 downto 0);
        iface_a     : in  std_logic_vector(C_WIDTH-1 downto 0);
        iface_we    : in  std_logic;
        iface_do    : out std_logic_vector(C_WIDTH-1 downto 0)
    );
end wrapped_qoi_chunk;

architecture Behavioral of wrapped_qoi_chunk is

    -- Internal signals
    signal reg0, reg0_prev, reg1, reg2, reg3 : std_logic_vector(C_WIDTH-1 downto 0);
    signal qoi_result             : std_logic_vector(C_WIDTH-1 downto 0);
    signal targeted_register      : std_logic_vector(17 downto 0);
    signal iface_do_o             : std_logic_vector(C_WIDTH-1 downto 0);
    signal iface_a_unsigned       : unsigned(C_WIDTH-1 downto 0);
    signal iface_we_delay: std_logic;

    -- QOI Chunk Component
    component QOI_chuck is
        port (
            clock      : in  std_logic;
            reset      : in  std_logic;
            pixel_data : in  std_logic_vector(C_WIDTH-1 downto 0);
            pixel_data_prev : in  std_logic_vector(C_WIDTH-1 downto 0);
            result_out : out std_logic_vector(C_WIDTH-1 downto 0)
        );
    end component;

begin

    -- Address conversion
    iface_a_unsigned <= unsigned(iface_a);

    -- reg1 always reflects the result from QOI
    reg1 <= qoi_result;

    process (clock)
        begin
            if rising_edge(clock) then
                if reset = '1' then
                    reg0 <= (others => '0');
                    reg0_prev <= (others => '0');
                else
                    reg0_prev <= reg0;
                    if iface_a = x"82000004" then
                        reg0 <= iface_di;
                        reg0_prev <= reg0;
                    end if;
                end if;
                
            end if;
    end process;

    -- Output data selection (read logic)
    targeted_register <= iface_a(19 downto 2);  -- Assuming 4-byte aligned addresses

    process(iface_we, targeted_register, reg0, reg1, reg2, reg3)
    begin
        iface_do_o <= (others => '0');  -- Default
        if iface_we = '0' then
            case targeted_register is
                when "000000000000000000" => iface_do_o <= reg0;
                when "000000000000000001" => iface_do_o <= reg1;
                when "000000000000000010" => iface_do_o <= reg2;
                when "000000000000000011" => iface_do_o <= reg3;
                when others               => iface_do_o <= (others => '0');
            end case;
        end if;
    end process;

    -- Assign to output
    iface_do <= iface_do_o;

    -- QOI Chunk instance
    QOI_chuck_1: QOI_chuck
        port map (
            clock      => clock,
            reset      => reset,
            pixel_data => reg0,
            pixel_data_prev => reg0_prev,
            result_out => qoi_result
        );

end Behavioral;

