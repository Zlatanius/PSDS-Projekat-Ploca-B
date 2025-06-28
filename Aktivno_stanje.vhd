library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

	component aktivno_stanje_fsm
		Port (
		  enable 		 : in	 std_logic;
        clk           : in  std_logic;
        reset         : in  std_logic;
        Prosjek       : in  unsigned(7 downto 0);
        ObradaDone    : in  std_logic;
        NoviPodatak   : in  std_logic;
		  Timer_done	 : in	 std_logic;
        HEX_Enable    : out std_logic;
        Hex_Mode      : out std_logic_vector(1 downto 0); -- "00" = nedefinisano, "01" = Data, "10" = Time
        RequestObrada : out std_logic;
        RampOpen      : out std_logic;
        ServoEnable   : out std_logic;
        TimerStart    : out std_logic
		);
	 end component;

	signal prosjek 	: unsigned(7 downto 0) := to_unsigned(0, 8);
	signal hex_mode	: std_logic_vector(1 downto 0);
	
	signal obrada_sig			: std_logic := '0';
	signal new_data_sig		: std_logic := '0';
	signal timer_done_sig	: std_logic := '0';
	signal hex_enable			: std_logic := '0';
	signal obrada_req			: std_logic := '0';
	signal ramp_sig			: std_logic := '0';
	signal servo_enable		: std_logic := '0';
	signal timer_start_sig	: std_logic := '0';

begin
		fsm : aktivno_stanje_fsm
		port map(
			enable 		 	=> enable,
			clk          	=> clk,
			reset        	=> '0',
			Prosjek      	=> prosjek,
			ObradaDone   	=> obrada_sig,
			NoviPodatak  	=> new_data_sig,
			Timer_done	 	=> timer_done_sig,
			HEX_Enable   	=> hex_enable,
			Hex_Mode     	=> hex_mode,
			RequestObrada	=> obrada_req,
			RampOpen     	=> ramp_sig,
			ServoEnable  	=> servo_enable,
			TimerStart   	=> timer_start_sig
		);

	active_led <= enable;
end Beh;