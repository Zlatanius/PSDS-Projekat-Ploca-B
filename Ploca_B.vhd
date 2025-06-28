library ieee;
use ieee.std_logic_1164.all;

entity Ploca_B is
	port(
		iCLK_50	: in 		std_logic;
		iSW		: in		std_logic_vector(6	downto 0);
		GPIO_1	: inout 	std_logic_vector(31 	downto 0);	-- GPIO_1, a ne 0 jer je sa desne strane ploce
		
		oHEX0_D	: out 	std_logic_vector(6 	downto 0);	
		oHEX1_D	: out 	std_logic_vector(6 	downto 0);	
		oHEX2_D	: out 	std_logic_vector(6 	downto 0);	
		
		oHEX3_D	: out 	std_logic_vector(6 	downto 0) := (others => '1');	
		oHEX4_D	: out 	std_logic_vector(6 	downto 0) := (others => '1');	
		oHEX5_D	: out 	std_logic_vector(6 	downto 0) := (others => '1');	
		oHEX6_D	: out 	std_logic_vector(6 	downto 0) := (others => '1');	
		oHEX7_D	: out 	std_logic_vector(6 	downto 0) := (others => '1');	
		
		oHEX0_DP : out 	std_logic := '1';
		oHEX1_DP : out 	std_logic := '1';
		oHEX2_DP : out 	std_logic := '1';
		oHEX3_DP : out 	std_logic := '1';
		oHEX4_DP : out 	std_logic := '1';
		oHEX5_DP : out 	std_logic := '1';
		oHEX6_DP : out 	std_logic := '1';
		oHEX7_DP : out 	std_logic := '1';
		
		oLEDR		: out 	std_logic_vector(17 	downto 0);	-- Stavio sam sve ledice cisto da ih imamo ako bude trebalo za debugiranje
		oLEDG		: out 	std_logic_vector(7 	downto 0)
	);
end Ploca_B;

architecture Beh of Ploca_B is

	component Aktivno_stanje
		port(
		
			--------------------------DEBUGGING--------------------------
			SW		: in	std_logic_vector(4 downto 0);
			RLED	: out std_logic_vector(16 downto 0);
			GLED 	: out std_logic_vector(4 downto 0);
			-------------------------------------------------------------
		
			clk			: in	std_logic;
			enable 		: in 	std_logic;
			rx_pin 		: in 	std_logic;
			HEX0 			: out std_logic_vector(6 	downto 0);
			HEX1 			: out std_logic_vector(6 	downto 0);
			HEX2 			: out std_logic_vector(6 	downto 0);
			servo_pin 	: out std_logic;
			active_led	: out std_logic
		);
	end component;

	component Poluaktivno_stanje
		port(
		enable			: in 	std_logic;
		indicator_led 	: out std_logic;
		active_led	: out std_logic
		);
	end component;
	
	component Neaktivno_stanje
		port(
			enable		: in 	std_logic;
			active_led	: out std_logic
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
		-- Konkretni pinovi nisu jos definisani
		
			------------DEBUGING------------
			SW 	=> iSW(6 downto 2),
			RLED 	=> oLEDR(16 downto 0),
			GLED	=> oLEDG(7 downto 3),
			--------------------------------
		
			clk			=> iCLK_50,
			enable 		=> aktivno_stanje_en,
			rx_pin 		=>	GPIO_1(0),
			HEX0 			=>	oHEX0_D,
			HEX1 			=> oHEX1_D,
			HEX2 			=> oHEX2_D,
			servo_pin	=> GPIO_1(2),
			active_led	=> oLEDG(0)
		);
		
	pakt_st: Poluaktivno_stanje
		port map(
			enable 			=> poluaktivno_stanje_en,
			indicator_led 	=> oLEDR(17),
			active_led		=> oLEDG(1)
		);
		
	neakt_st: Neaktivno_stanje
		port map(
			enable 		=> neaktivno_stanje_en,
			active_led	=> oLEDG(2)
		);
		
	aktivno_stanje_en 		<= '1' when SW0 = '1' and SW1 = '0' else '0';
	poluaktivno_stanje_en 	<= '1' when SW0 = '0' and SW1 = '1' else '0';
	
	neaktivno_stanje_en 		<= '1' when aktivno_stanje_en = '0' and poluaktivno_stanje_en = '0' else '0';
	
end Beh;