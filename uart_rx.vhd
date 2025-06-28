library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    generic (
        CLK_FREQ  : integer := 50_000_000;
        BAUD_RATE : integer := 9600
    );
    port (
        i_clk      : in  std_logic;
        i_rst      : in  std_logic;
        i_uart_rx  : in  std_logic;
        o_rx_data  : out std_logic_vector(7 downto 0);
        o_rx_dv    : out std_logic -- 'Data Valid' signal, puls kada je podatak primljen
    );
end entity uart_rx;

architecture rtl of uart_rx is
    constant CLKS_PER_BIT : integer := CLK_FREQ / BAUD_RATE;

    type state_t is (s_idle, s_rx_start_bit, s_rx_data_bits, s_rx_stop_bit);
    signal r_state      : state_t := s_idle;
    
    signal r_clk_count  : integer range 0 to CLKS_PER_BIT - 1 := 0;
    signal r_bit_index  : integer range 0 to 7 := 0;
    signal r_rx_data    : std_logic_vector(7 downto 0) := (others => '0');
    signal r_rx_dv      : std_logic := '0';

begin
    o_rx_data <= r_rx_data;
    o_rx_dv   <= r_rx_dv;

    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            r_state     <= s_idle;
            r_clk_count <= 0;
            r_bit_index <= 0;
            r_rx_dv     <= '0';
        elsif rising_edge(i_clk) then
            -- Uvijek de-asertiraj Data Valid signal nakon jednog ciklusa
            r_rx_dv <= '0';

            case r_state is
                when s_idle =>
                    if i_uart_rx = '0' then -- Detektovan potencijalni start bit
                        r_clk_count <= 0;
                        r_state     <= s_rx_start_bit;
                    end if;

                when s_rx_start_bit =>
                    -- Čekaj pola bita da se uzorkuje u sredini
                    if r_clk_count < (CLKS_PER_BIT / 2) - 1 then
                        r_clk_count <= r_clk_count + 1;
                    else
                        if i_uart_rx = '0' then -- Potvrđen start bit
                            r_clk_count <= 0;
                            r_bit_index <= 0;
                            r_state <= s_rx_data_bits;
                        else -- Lažna uzbuna, vrati se u idle
                            r_state <= s_idle;
                        end if;
                    end if;

                when s_rx_data_bits =>
                    -- Čekaj cijeli bit
                    if r_clk_count < CLKS_PER_BIT - 1 then
                        r_clk_count <= r_clk_count + 1;
                    else
                        r_clk_count <= 0;
                        r_rx_data(r_bit_index) <= i_uart_rx;
                        if r_bit_index < 7 then
                            r_bit_index <= r_bit_index + 1;
                        else
                            r_state <= s_rx_stop_bit;
                        end if;
                    end if;

                when s_rx_stop_bit =>
                    if r_clk_count < CLKS_PER_BIT - 1 then
                        r_clk_count <= r_clk_count + 1;
                    else
                        r_clk_count <= 0;
                        -- Ako je stop bit ispravan ('1'), podatak je validan
                        if i_uart_rx = '1' then
                           r_rx_dv <= '1'; -- Signaliziraj da je novi podatak stigao
                        end if;
                        r_state <= s_idle;
                    end if;

            end case;
        end if;
    end process;
end architecture rtl;