library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity aktivno_stanje_fsm is
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
        TimerStart    : out std_logic;
		  reset_uart 	 : out std_logic;
		  -- DEBUG
		  state_leds	 : out std_logic_vector(2 downto 0)
    );
end aktivno_stanje_fsm;

architecture Behavioral of aktivno_stanje_fsm is

    type StateType is (q0, q1, q2, disabled);
    signal current_state, next_state : StateType;

begin

    -- Proces za prelaz između stanja
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= q0;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- Proces za logiku prelaza između stanja
    process(current_state, Prosjek, ObradaDone, NoviPodatak)
    begin
		if enable = '1' then
			case current_state is
					when q0 =>
						reset_uart <= '0';
						if NoviPodatak = '1' then
							next_state <= q1;
						else
							next_state <= q0;
						end if;
	
					when q1 =>
						if Prosjek <= 20 and ObradaDone = '1' then
							next_state <= q2;
							reset_uart <= '1';
						elsif Prosjek > 20 and ObradaDone = '1' then
							next_state <= q0;
							reset_uart <= '1';
						else
							next_state <= q1;
						end if;
	
					when q2 =>
						if Timer_done = '1' then
							next_state <= q0;
						else
							next_state <= q2;
						end if;
	
					when others =>
						next_state <= q0;
			end case;
		 elsif enable = '0' then
			next_state <= disabled;
		 end if;
    end process;

    -- Proces za postavljanje izlaza na osnovu stanja
    process(current_state)
    begin
        case current_state is
            when q0 =>
                HEX_Enable    <= '1';
                Hex_Mode      <= "01"; -- Data
                RequestObrada <= '0';
                RampOpen      <= '0';
                ServoEnable   <= '1';
                TimerStart    <= '0';
					 
					 state_leds <= (others => '0');
					 state_leds(0) <= '1';
					 
            when q1 =>
                HEX_Enable    <= '1';
                Hex_Mode      <= "01"; -- Data
                RequestObrada <= '1';
                RampOpen      <= '0';
                ServoEnable   <= '1';
                TimerStart    <= '0';
					 
					 state_leds <= (others => '0');
					state_leds(1) <= '1';

            when q2 =>
                HEX_Enable    <= '1';
                Hex_Mode      <= "10"; -- Time
                RequestObrada <= '0';
                RampOpen      <= '1';
                ServoEnable   <= '1';
                TimerStart    <= '1';
					 
					 state_leds <= (others => '0');
					 state_leds(2) <= '1';

            when disabled =>
                HEX_Enable    <= '0';
                Hex_Mode      <= "00";
                RequestObrada <= '0';
                RampOpen      <= '0';
                ServoEnable   <= '0';
                TimerStart    <= '0';
					 
					 state_leds <= (others => '0');
				
				when others =>
                HEX_Enable    <= '0';
                Hex_Mode      <= "00";
                RequestObrada <= '0';
                RampOpen      <= '0';
                ServoEnable   <= '0';
                TimerStart    <= '0';
					 
					 state_leds <= (others => '0');
        end case;
    end process;

end Behavioral;
