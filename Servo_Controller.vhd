library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Servo_Controller is
    port (
        clk          : in  std_logic;
        ramp_sig     : in  std_logic;
        servo_enable : in  std_logic;
        pwm_out      : out std_logic
    );
end entity;

architecture Behavioral of Servo_Controller is

    signal setpoint : unsigned(7 downto 0) := (others => '0');

    -- Instanca servo drivera
    component Servo_Driver is
        port (
            clock    : in  std_logic;
            setpoint : in  unsigned(7 downto 0);
            pwm_out  : out std_logic
        );
    end component;

begin

    -- Upravljanje setpointom
    process(clk)
    begin
        if rising_edge(clk) then
            if servo_enable = '1' then
                if ramp_sig = '1' then
                    setpoint <= to_unsigned(0, 8);    -- 0 stepeni
                else
                    setpoint <= to_unsigned(90, 8);   -- 90 stepeni
                end if;
            else
                setpoint <= to_unsigned(0, 8); -- ili drži zadnje stanje ako želiš
            end if;
        end if;
    end process;

    -- Instanciranje servo drivera
    u_servo_driver : Servo_Driver
        port map (
            clock    => clk,
            setpoint => setpoint,
            pwm_out  => pwm_out
        );

end architecture;
