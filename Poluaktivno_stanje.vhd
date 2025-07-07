library ieee;
use ieee.std_logic_1164.all;

entity Poluaktivno_stanje is
	port(
		clk 				: in 	std_logic;
		enable			: in 	std_logic;
		servo_sw			: in 	std_logic;
		indicator_led 	: out std_logic;
		servo_pin		: out	std_logic;
		active_led		: out std_logic
	);
end Poluaktivno_stanje;



architecture Beh of Poluaktivno_stanje is

	component Servo_Controller
		port (
			clk          : in  std_logic;
			ramp_sig     : in  std_logic;
			servo_enable : in  std_logic;
			pwm_out      : out std_logic
		);
	end component;

begin
	indicator_led 	<= enable;
	active_led 		<= enable;
	
		servo_module : Servo_Controller
			port map(
				clk         	=> clk,
				ramp_sig    	=> servo_sw,
				servo_enable 	=> enable,
				pwm_out     	=> servo_pin
			);
end Beh;