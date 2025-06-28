library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SS8BitDec is
    generic (
        NUM_DISPLAYS : integer := 3  -- Number of displays to use (1 to 3)
    );
    port(
        input  : in  std_logic_vector(7 downto 0);
        HEX0   : out std_logic_vector(6 downto 0);
        HEX1   : out std_logic_vector(6 downto 0);
        HEX2   : out std_logic_vector(6 downto 0)
    );
end SS8BitDec;

architecture Behavioral of SS8BitDec is

    component SS4Bit
        port(
            input   : in  std_logic_vector(3 downto 0);
            HexOut  : out std_logic_vector(6 downto 0)
        );
    end component;

    signal bin_value   : unsigned(7 downto 0);
    signal hundreds    : std_logic_vector(3 downto 0);
    signal tens        : std_logic_vector(3 downto 0);
    signal ones       : std_logic_vector(3 downto 0);

    constant BLANK     : std_logic_vector(6 downto 0) := "1111111";  -- All segments off (optional)

begin

    bin_value <= unsigned(input);

    process(bin_value)
        variable temp : integer;
    begin
        temp := to_integer(bin_value);
        hundreds <= std_logic_vector(to_unsigned(temp / 100, 4));
        tens     <= std_logic_vector(to_unsigned((temp mod 100) / 10, 4));
        ones    <= std_logic_vector(to_unsigned(temp mod 10, 4));
    end process;

    -- Display logic
    DisplayUnits : if NUM_DISPLAYS >= 1 generate
        U0: SS4Bit port map(input => ones, HexOut => HEX0);
    end generate;
    BlankUnits : if NUM_DISPLAYS < 1 generate
        HEX0 <= BLANK;
    end generate;

    DisplayTens : if NUM_DISPLAYS >= 2 generate
        U1: SS4Bit port map(input => tens, HexOut => HEX1);
    end generate;
    BlankTens : if NUM_DISPLAYS < 2 generate
        HEX1 <= BLANK;
    end generate;

    DisplayHundreds : if NUM_DISPLAYS >= 3 generate
        U2: SS4Bit port map(input => hundreds, HexOut => HEX2);
    end generate;
    BlankHundreds : if NUM_DISPLAYS < 3 generate
        HEX2 <= BLANK;
    end generate;

end Behavioral;
