library ieee;
use ieee.std_logic_1164.all;

entity Aktivno_stanje is
	port(
		clk 			: in	std_logic;
		enable 		: in 	std_logic;
		HEX0 			: out std_logic_vector(6 	downto 0);	-- Hex za prikazivanje prosjecne brzine
		HEX1 			: out std_logic_vector(6 	downto 0);	-- Hex za prikazivanje prosjecne brzine
		HEX2 			: out std_logic_vector(6 	downto 0);	-- Hex za prikazivanje prosjecne brzine
		HEX3 			: out std_logic_vector(6 	downto 0);	-- Hex za prikazivanje prosjecne brzine
		HEX4 			: out std_logic_vector(6 	downto 0);	-- Hex za prikazivanje vrmena
		HEX5 			: out std_logic_vector(6 	downto 0);	-- Hex za prikazivanje vrmena
		UART_RX 		: in 	std_logic;
		UART_TX 		: out std_logic;
		servo_pin 	: out std_logic;
		active_led	: out std_logic
	);
end Aktivno_stanje;

architecture Beh of Aktivno_stanje is
begin
	active_led <= enable;
end Beh;