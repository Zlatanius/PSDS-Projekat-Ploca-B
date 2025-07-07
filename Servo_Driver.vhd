library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Servo_Driver is
	port(
		clock    : in  std_logic;
		setpoint : in  unsigned(7 downto 0); -- degrees
		pwm_out  : out std_logic
	);
end entity;

architecture Beh of Servo_Driver is
	constant cycles_per_deg       : unsigned(15 downto 0) 	:= to_unsigned(156, 16);     -- (1ms * 28MHz) / 180deg ~= 155.55
    constant zero_deg_cycles      : unsigned(19 downto 0) 	:= to_unsigned(28000, 20);   -- 1ms pulse width @ 28 MHz
    constant cycles_per_pwm_frame : unsigned(19 downto 0) 	:= to_unsigned(560000, 20);  -- 20ms frame @ 28 MHz

	signal period_counter     : unsigned(19 downto 0) := (others => '0');
	signal duty_cycle_counter : unsigned(19 downto 0) := (others => '0');
	signal pwm                : std_logic := '1';
begin

	process(clock)
		variable duty_limit : unsigned(19 downto 0);
	begin
		if rising_edge(clock) then
			duty_limit := zero_deg_cycles + resize(setpoint * cycles_per_deg, 20);
			
			if duty_cycle_counter + 1 = cycles_per_pwm_frame then
				duty_cycle_counter <= (others => '0');
				period_counter     <= (others => '0');
				pwm                <= '1';
			else
				duty_cycle_counter <= duty_cycle_counter + 1;

				if period_counter < duty_limit then
					pwm <= '1';
				else
					pwm <= '0';
				end if;

				period_counter <= period_counter + 1;
			end if;
		end if;
	end process;

	pwm_out <= pwm;
end Beh;
