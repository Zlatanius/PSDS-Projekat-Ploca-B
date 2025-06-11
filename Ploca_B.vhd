library ieee;
use ieee.std_logic_1164.all;

entity Ploca_B is
	port(
		iCLK_50	: in 		std_logic;
		iSW		: in		std_logic_vector(1	downto 0);
		GPIO_1	: inout 	std_logic_vector(31 	downto 0);
		
		oHEX0_D	: out 	std_logic_vector(6 	downto 0);	-- Hex za prikazivanje prosjecne brzine
		oHEX1_D	: out 	std_logic_vector(6 	downto 0);	-- Hex za prikazivanje prosjecne brzine
		oHEX2_D	: out 	std_logic_vector(6 	downto 0);	-- Hex za prikazivanje prosjecne brzine
		oHEX3_D	: out 	std_logic_vector(6 	downto 0);	-- Hex za prikazivanje prosjecne brzine
		oHEX4_D	: out 	std_logic_vector(6 	downto 0);	-- Hex za prikazivanje vrmena
		oHEX5_D	: out 	std_logic_vector(6 	downto 0);	-- Hex za prikazivanje vrmena
		
		oLEDR		: out 	std_logic_vector(17 	downto 0);	-- Stavio sam sve ledice cisto da ih imamo ako bude trebalo za debugiranje
		oLEDG		: out 	std_logic_vector(7 	downto 0)
	);
end Ploca_B;

architecture Beh of Ploca_B is

	component Aktivno_stanje
		port(
			enable: in std_logic
		);
	end component;

	component Poluaktivno_stanje
		port(
		enable			: in 	std_logic;
		indicator_led 	: out std_logic
		);
	end component;
	
	component Neaktivno_stanje
		port(
			enable: in std_logic
		);
	end component;

	-- SW0: Aktivno stanje; SW1: Poluaktivno stanje; Sve ostalo: Neaktivno stanje
	alias SW0: std_logic is iSW(0);
	alias SW1: std_logic is iSW(1);
	
	signal aktivno_stanje_en 		: std_logic := '0';
	signal poluaktivno_stanje_en 	: std_logic := '0';
	signal neaktivno_stanje_en 	: std_logic := '0';

begin
	akt_st: Aktivno_stanje
		port map(
			enable => aktivno_stanje_en
		);
		
	pakt_st: Aktivno_stanje
		port map(
			enable 			=> poluaktivno_stanje_en,
			indicator_led 	=> oLEDR(17)
		);
		
	neakt_st: Aktivno_stanje
		port map(
			enable => neaktivno_stanje_en
		);
		
	aktivno_stanje_en 		<= '1' when SW0 = '1' and SW1 = '0' else '0';
	poluaktivno_stanje_en 	<= '1' when SW0 = '0' and SW1 = '1' else '0';
	
	neaktivno_stanje_en 		<= '1' when aktivno_stanje_en = '0' and poluaktivno_stanje_en = '0' else '0';
	
	oLEDG(0) <= aktivno_stanje_en;
	oLEDG(1) <= poluaktivno_stanje_en;
	oLEDG(2) <= neaktivno_stanje_en;
	
end Beh;