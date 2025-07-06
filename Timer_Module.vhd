library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Timer_Module is
    port (
        clk         : in  std_logic;
        time_start  : in  std_logic;
        time_out    : out std_logic_vector(7 downto 0);
        timer_done  : out std_logic
    );
end entity;


architecture Behavioral of Timer_Module is
    constant CLK_FREQ     : integer := 50_000_000;
    constant SEC_COUNT    : integer := CLK_FREQ; -- 50M cycles for 1 second

    signal second_counter : integer range 0 to SEC_COUNT - 1 := 0;
    signal time_counter   : integer range 0 to 60 := 0;
    signal running        : std_logic := '0';
    signal done_pulse     : std_logic := '0';
begin

    time_out   <= std_logic_vector(to_unsigned(time_counter, 8));
    timer_done <= done_pulse;

    process(clk)
    begin
        if rising_edge(clk) then
            done_pulse <= '0'; -- puls traje jedan ciklus

            if time_start = '1' and running = '0' then
                running        <= '1';
                time_counter   <= 0;
                second_counter <= 0;
            elsif running = '1' then
                if second_counter < SEC_COUNT - 1 then
                    second_counter <= second_counter + 1;
                else
                    second_counter <= 0;
                    if time_counter < 60 then
                        time_counter <= time_counter + 1;
                        if time_counter = 9 then
                            done_pulse <= '1'; -- pulse on 60th second
                            running    <= '0'; -- stop timer
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture;
