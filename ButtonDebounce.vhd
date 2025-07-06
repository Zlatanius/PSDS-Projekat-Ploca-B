library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ButtonDebounce is
	port(
		button_in  : in  std_logic;
		clock      : in  std_logic;
		button_out : out std_logic
	);
end entity;

architecture Beh of ButtonDebounce is
	constant STABLE_COUNT : integer := 50000; -- adjust for debounce time
	signal counter        : integer := 0;
	signal button_sync    : std_logic := '0';
	signal button_last    : std_logic := '0';
	signal pulse          : std_logic := '0';
begin

	process(clock)
	begin
		if rising_edge(clock) then
			button_sync <= button_in;

			if button_sync = button_last then
				if counter < STABLE_COUNT then
					counter <= counter + 1;
				end if;
			else
				counter <= 0;
			end if;

			if counter = STABLE_COUNT then
				if button_sync = '1' and button_last = '0' then
					pulse <= '1'; -- one-cycle pulse
				else
					pulse <= '0';
				end if;
				button_last <= button_sync;
			else
				pulse <= '0';
			end if;
		end if;
	end process;

	button_out <= pulse;

end architecture;
