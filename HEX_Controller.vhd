library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HEX_Controller is
    port (
        data_in  : in  std_logic_vector(7 downto 0);
        time_in  : in  std_logic_vector(7 downto 0);
        mode     : in  std_logic_vector(1 downto 0);
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0)
    );
end entity;

architecture Structural of HEX_Controller is

    -- Komponenta za prikaz broja na HEX ekranima
    component SS8BitDec
        generic (
            NUM_DISPLAYS : integer := 3
        );
        port (
            input  : in  std_logic_vector(7 downto 0);
            HEX0   : out std_logic_vector(6 downto 0);
            HEX1   : out std_logic_vector(6 downto 0);
            HEX2   : out std_logic_vector(6 downto 0)
        );
    end component;

    signal selected_input : std_logic_vector(7 downto 0);

begin

    -- Logika za izbor ulaza na osnovu mode signala
    selected_input <= data_in when mode = "01" else
                      time_in when mode = "10" else
                      (others => '0');  -- default

    -- Instanca dekodera za prikaz na HEX
    u_hex_disp : SS8BitDec
        generic map (
            NUM_DISPLAYS => 3
        )
        port map (
            input => selected_input,
            HEX0  => HEX0,
            HEX1  => HEX1,
            HEX2  => HEX2
        );

end architecture;
