library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        rx       : in  std_logic;
        data_out : out std_logic_vector(7 downto 0);
        ready    : out std_logic
    );
end uart_rx;

architecture Behavioral of uart_rx is
    constant CLK_FREQ   : integer := 28000000;
    constant BAUD_RATE  : integer := 115200;
    constant CLKS_PER_BIT : integer := CLK_FREQ / BAUD_RATE;

    type state_type is (IDLE, START, READ, STOP);
    signal state     : state_type := IDLE;
    signal clk_cnt   : integer := 0;
    signal bit_cnt   : integer := 0;
    signal data_reg  : std_logic_vector(7 downto 0) := (others => '0');
    signal ready_int : std_logic := '0';
begin
    data_out <= data_reg;
    ready <= ready_int;

    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            clk_cnt <= 0;
            bit_cnt <= 0;
            ready_int <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    ready_int <= '0';
                    if rx = '0' then  -- start bit
                        clk_cnt <= CLKS_PER_BIT / 2;
                        state <= START;
                    end if;

                when START =>
                    if clk_cnt = 0 then
                        clk_cnt <= CLKS_PER_BIT - 1;
                        bit_cnt <= 0;
                        state <= READ;
                    else
                        clk_cnt <= clk_cnt - 1;
                    end if;

                when READ =>
                    if clk_cnt = 0 then
                        data_reg(bit_cnt) <= rx;
                        if bit_cnt = 7 then
                            state <= STOP;
                        else
                            bit_cnt <= bit_cnt + 1;
                        end if;
                        clk_cnt <= CLKS_PER_BIT - 1;
                    else
                        clk_cnt <= clk_cnt - 1;
                    end if;

                when STOP =>
                    if clk_cnt = 0 then
                        ready_int <= '1';
                        state <= IDLE;
                    else
                        clk_cnt <= clk_cnt - 1;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;