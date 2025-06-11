library ieee;
use ieee.std_logic_1164.all;

entity Neaktivno_stanje is
	port(
		enable		: in 	std_logic;
		active_led	: out std_logic
	);
end Neaktivno_stanje;

architecture Beh of Neaktivno_stanje is
begin
	active_led	<= enable;
end Beh;