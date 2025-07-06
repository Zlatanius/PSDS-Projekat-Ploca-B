library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Obrada is
    Port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        enable        : in  std_logic;
        new_data      : in  std_logic;
        data_in       : in  std_logic_vector(7 downto 0);
        obrada_done   : out std_logic;
        prosjek       : out std_logic_vector(15 downto 0)
    );
end Obrada;

architecture rtl of Obrada is
    type ram_type is array(255 downto 0) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (others => (others => '0'));
    signal write_addr : integer range 0 to 255 := 0;
    signal read_addr  : integer range 0 to 255 := 0;
	 
    constant ALPHA : real := 0.2;
    signal weight         : real := 1.0;
    signal weighted_sum   : real := 0.0;
    signal sum_of_weights : real := 0.0;
    signal S_final        : real := 0.0;
    signal prosjek_reg    : std_logic_vector(15 downto 0) := (others => '0');

    type state_type is (IDLE, WRITE, INIT_OBRADA, READ, COMPUTE, DONE);
    signal state : state_type := IDLE;
    signal obrada_trigger : std_logic := '0';
    function to_real8(slv : std_logic_vector(7 downto 0)) return real is
    begin
        return real(to_integer(unsigned(slv)));
    end function;

begin

    process(clk, rst)
        variable temp_val : real;
    begin
        if rst = '1' then
            write_addr <= 0;
            read_addr <= 0;
            weight <= 1.0;
            weighted_sum <= 0.0;
            sum_of_weights <= 0.0;
            S_final <= 0.0;
            prosjek_reg <= (others => '0');
            obrada_done <= '0';
            state <= IDLE;
        elsif rising_edge(clk) then
            obrada_done <= '0';

            case state is
                when IDLE =>
                    if enable = '1' and new_data = '1' then
                        ram(write_addr) <= (31 downto 8 => '0') & data_in;
                        write_addr <= write_addr + 1;
                        obrada_trigger <= '1';
                        state <= INIT_OBRADA;
                    end if;

                when INIT_OBRADA =>
                    read_addr <= write_addr - 1;
                    weight <= 1.0;
                    weighted_sum <= 0.0;
                    sum_of_weights <= 0.0;
                    state <= READ;

                when READ =>
                    state <= COMPUTE;

                when COMPUTE =>
                    temp_val := to_real8(ram(read_addr)(7 downto 0));
                    weighted_sum <= weighted_sum + temp_val * weight;
                    sum_of_weights <= sum_of_weights + weight;
                    weight <= weight * (1.0 - ALPHA);

                    if read_addr = 0 then
                        state <= DONE;
                    else
                        read_addr <= read_addr - 1;
                        state <= READ;
                    end if;

                when DONE =>
                    if sum_of_weights /= 0.0 then
                        S_final <= weighted_sum / sum_of_weights;
                    else
                        S_final <= 0.0;
                    end if;

                    prosjek_reg <= std_logic_vector(to_unsigned(integer(S_final), 16));
                    obrada_done <= '1';
                    state <= IDLE;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    prosjek <= prosjek_reg;

end rtl;