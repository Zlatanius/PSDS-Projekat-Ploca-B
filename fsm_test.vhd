library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_test is
	port(
		iCLK_50		: in 	std_logic;
		iSW			: in 	std_logic_vector(5 downto 0);		-- 0: enable
		                                                   -- 1: reset
		                                                   -- 2: prosjek_u20		0: > 20;	1: < 20
																			-- 3: ObradaDone
																			-- 4: NoviPodatak
		                                                   -- 5: Timer_done
																			
		oLEDR			: out std_logic_vector(17 downto 0);	-- 0: HEX_Enable
		                                                   -- 1: HEX_mode			0: Time; 1: Data
		                                                   -- 2: RequestObrada
																			-- 3: RampOpen
																			-- 4: ServoEnable
		                                                   -- 5: TimerStart
		oLEDG			: out std_logic_vector(2 downto 0)
	);
end fsm_test;

architecture Beh of fsm_test is
	component aktivno_stanje_fsm
		port (
		  enable 		 : in	 std_logic;
        clk           : in  std_logic;
        reset         : in  std_logic;
        Prosjek       : in  unsigned(7 downto 0);
        ObradaDone    : in  std_logic;
        NoviPodatak   : in  std_logic;
		  Timer_done	 : in	 std_logic;
        HEX_Enable    : out std_logic;
        Hex_Mode      : out std_logic_vector(1 downto 0); 	-- "00" = nedefinisano, "01" = Data, "10" = Time
        RequestObrada : out std_logic;
        RampOpen      : out std_logic;
        ServoEnable   : out std_logic;
        TimerStart    : out std_logic;
		  state_leds	 : out std_logic_vector(2 downto 0)	
    );
	end component;

	signal prosjek_u20 	: unsigned(7 downto 0) := to_unsigned(0, 8);
	signal HEX_mode 		: std_logic_vector(1 downto 0);
	
begin
	fsm : aktivno_stanje_fsm
		port map(
			enable 			=> iSW(0),
			clk          	=> iCLK_50,
			reset        	=>	iSW(1),
			Prosjek      	=>	prosjek_u20,
			ObradaDone   	=>	iSW(3),
			NoviPodatak  	=>	iSW(4),
			Timer_done		=> iSW(5),
			HEX_Enable   	=>	oLEDR(0),
			Hex_Mode     	=>	HEX_mode,
			RequestObrada	=>	oLEDR(2),
			RampOpen     	=>	oLEDR(3),
			ServoEnable  	=>	oLEDR(4),
			TimerStart   	=>	oLEDR(5),
			state_leds		=>	oLEDG
		);
		
	prosjek_u20 <= to_unsigned(10, 8) 	when iSW(2) = '1' else
						to_unsigned(100, 8);
						
	oLEDR(1) 	<= '1' when HEX_mode = "01" else -- Data 
						'0';									-- Time
					
	oLEDR(17) 	<= '1' when HEX_mode = "00" else
						'0';
						
	oLEDR(14 downto 7) <= std_logic_vector(Prosjek_u20);
end Beh;