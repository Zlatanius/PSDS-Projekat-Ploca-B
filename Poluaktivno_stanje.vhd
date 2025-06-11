library ieee;
use ieee.std_logic_1164.all;

entity Poluaktivno_stanje is
	port(
		enable			: in 	std_logic;
		indicator_led 	: out std_logic;
		active_led		: out std_logic
	);
end Poluaktivno_stanje;

architecture Beh of Poluaktivno_stanje is
begin
	indicator_led 	<= enable;
	active_led 		<= enable;
end Beh;