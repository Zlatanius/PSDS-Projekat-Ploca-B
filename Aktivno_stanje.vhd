library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Aktivno_stanje is
	port(
	
--------------------------DEBUGGING--------------------------

		SW		: in	std_logic_vector(4 downto 0);
		RLED	: out std_logic_vector(16 downto 0);
		GLED 	: out std_logic_vector(4 downto 0);
		
-------------------------------------------------------------
	
		clk 			: in	std_logic;
		enable 		: in 	std_logic;
		rx_pin 		: in 	std_logic;
		HEX0 			: out std_logic_vector(6 	downto 0);	-- Hex za prikazivanje prosjecne brzine
		HEX1 			: out std_logic_vector(6 	downto 0);	-- Hex za prikazivanje prosjecne brzine
		HEX2 			: out std_logic_vector(6 	downto 0);	-- Hex za prikazivanje prosjecne brzine
		HEX3 			: out std_logic_vector(6 	downto 0);	-- Hex za prikazivanje prosjecne brzine
		HEX4 			: out std_logic_vector(6 	downto 0);	-- Hex za prikazivanje vrmena
		HEX5 			: out std_logic_vector(6 	downto 0);	-- Hex za prikazivanje vrmena
		servo_pin 	: out std_logic;
		active_led	: out std_logic
	);
end Aktivno_stanje;

architecture Beh of Aktivno_stanje is

-----------------------------KOMPONENTE-----------------------------
	component aktivno_stanje_fsm
		Port (	
			enable 		 	: in	 std_logic;
			clk           	: in  std_logic;
			reset         	: in  std_logic;
			Prosjek       	: in  unsigned(7 downto 0);
			ObradaDone    	: in  std_logic;
			NoviPodatak   	: in  std_logic;
			Timer_done	 	: in	 std_logic;
			HEX_Enable    	: out std_logic;
			Hex_Mode      	: out std_logic_vector(1 downto 0); -- "00" = nedefinisano, "01" = Data, "10" = Time
			RequestObrada 	: out std_logic;
			RampOpen      	: out std_logic;
			ServoEnable   	: out std_logic;
			TimerStart    	: out std_logic;
			--Debug leds
			state_leds	 	: out std_logic_vector(2 downto 0)
		);
	end component;
	 
	component uart_rx
		generic (
			CLK_FREQ  : integer := 50_000_000;
			BAUD_RATE : integer := 9600
		);
		port (
			i_clk      : in  std_logic;
			i_rst      : in  std_logic;
			i_uart_rx  : in  std_logic;
			o_rx_data  : out std_logic_vector(7 downto 0);
			o_rx_dv    : out std_logic -- 'Data Valid' signal, puls kada je podatak primljen
		);
	end component;
	
	component Servo_Controller
		port (
			clk          : in  std_logic;
			ramp_sig     : in  std_logic;
			servo_enable : in  std_logic;
			pwm_out      : out std_logic
		);
	end component;
	 
--------------------------------------------------------------------

------------------------------SIGNALI-------------------------------

	signal rec_data_buffer 	: std_logic_vector(7 downto 0);
	signal rec_data_ready	: std_logic := '0';

	-- Signali za simulaciju
	signal prosjek 	: unsigned(7 downto 0) := to_unsigned(0, 8);
	signal hex_mode	: std_logic_vector(1 downto 0);
	
	signal obrada_sig			: std_logic := '0';
	signal timer_done_sig	: std_logic := '0';
	signal hex_enable			: std_logic := '0';
	signal obrada_req			: std_logic := '0';
	signal ramp_sig			: std_logic := '0';
	signal servo_enable		: std_logic := '0';
	signal timer_start_sig	: std_logic := '0';

--------------------------------------------------------------------

begin
	fsm : aktivno_stanje_fsm
	port map(
		enable 		 	=> enable,
		clk          	=> clk,
		reset        	=> '0',
		Prosjek      	=> prosjek,
		ObradaDone   	=> obrada_sig,
		NoviPodatak  	=> rec_data_ready,
		Timer_done	 	=> timer_done_sig,
		HEX_Enable   	=> hex_enable,
		Hex_Mode     	=> hex_mode,
		RequestObrada	=> obrada_req,
		RampOpen     	=> ramp_sig,
		ServoEnable  	=> servo_enable,
		TimerStart   	=> timer_start_sig,
		state_leds		=> GLED(4 downto 2)
	);
	
	uart_module : uart_rx
	port map(
		i_clk    	=> clk,
		i_rst    	=> '0',
		i_uart_rx	=> rx_pin,
		o_rx_data	=>	rec_data_buffer,
		o_rx_dv  	=> open -- za testiranje ovo je open inace treba biti rec_data_ready
	);
	
	servo_module : Servo_Controller
		port map(
			clk         	=> clk,
			ramp_sig    	=> ramp_sig,
			servo_enable 	=> servo_enable,
			pwm_out     	=> servo_pin
		);

	active_led <= enable;
	
	
	
	
------------------------------- RUCNO TESTIRANJE -------------------------------
	
	-- FSM signali simulirani preko prekidaca. Kada se budu dodavale komponente
	-- uklanjat ce se simulirani signali.
	
	-- Ulazi
	prosjek <= 	to_unsigned(10, 8) 	when SW(0) = '1' else
					to_unsigned(100, 8);
	
	obrada_sig			<= SW(1);
	rec_data_ready		<= SW(2);
	timer_done_sig		<= SW(3);
	
	-- Izlazi
	RLED(0) <= hex_enable;
	
	RLED(1) <= '1' when HEX_mode = "01" else 	-- Data 
				  '0';									-- Time
	RLED(2) <= obrada_req;
	RLED(3) <= ramp_sig;
	RLED(4) <= servo_enable;
	RLED(5) <= timer_start_sig;
		
	RLED(16) <= '1' when HEX_mode = "00" and enable = '1' else
					'0';
	
end Beh;