library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Obrada is
    Port (
        clk: in  std_logic;
		  reset: in  std_logic;
        new_data: in  std_logic;
        data_in: in  std_logic_vector(7 downto 0);
        request_obrada: in  std_logic;
        obrada_done: out std_logic;
        prosjek: out std_logic_vector(15 downto 0)
    );
end Obrada;

architecture rtl of Obrada is

    type ram_type is array(255 downto 0) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (others => (others => '0'));

    type state_type is (IDLE, WRITE, WAIT_FOR_OBRADA, READ_NEXT, COMPUTE, DONE);
    signal state : state_type := IDLE;

    signal write_addr : integer range 0 to 255 := 0;
    signal read_addr  : integer range 0 to 255 := 0;
    signal ram_data   : std_logic_vector(31 downto 0);

    constant ALPHA: real := 0.2;
    signal weight: real := 1.0;
    signal weighted_sum: real := 0.0;
    signal sum_of_weights: real := 0.0;
    signal index: integer range 0 to 255 := 0;

    signal count: integer := 0;
    signal data_ready    : boolean := false;
    signal compute_start : boolean := false;

    function to_real8(slv : std_logic_vector(31 downto 0)) return real is
    begin
        return real(to_integer(unsigned(slv(7 downto 0))));
    end function;

begin

    process(clk)
    begin
        if reset = '1' then
            state <= IDLE;
            write_addr <= 0;
            read_addr <= 0;
            count <= 0;
            obrada_done <= '0';
            prosjek <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    obrada_done <= '0';
                    if new_data = '1' then
                        ram(write_addr) <= (31 downto 8 => '0') & data_in;
                        write_addr <= write_addr + 1;
                        count <= count + 1;
                    end if;
                    if count = 16 then
                        data_ready <= true;
                        state <= WAIT_FOR_OBRADA;
                    end if;
                when WAIT_FOR_OBRADA =>
                    if request_obrada = '1' and data_ready = true then
                        read_addr <= 15;
                        index <= 15;
                        weighted_sum <= 0.0;
                        sum_of_weights <= 0.0;
                        weight <= 1.0;
                        state <= READ_NEXT;
                    end if;
                when READ_NEXT =>
                    ram_data <= ram(read_addr);
                    state <= COMPUTE;
                when COMPUTE =>
                    weighted_sum <= weighted_sum + to_real8(ram_data) * weight;
                    sum_of_weights <= sum_of_weights + weight;
                    weight <= weight * (1.0 - ALPHA);
                    if index = 0 then
                        state <= DONE;
                    else
                        index <= index - 1;
                        read_addr <= read_addr - 1;
                        state <= READ_NEXT;
                    end if;
                when DONE =>
                    prosjek <= std_logic_vector(to_unsigned(integer(weighted_sum / sum_of_weights), 16));
                    obrada_done <= '1';
                    write_addr <= 0;
                    count <= 0;
                    data_ready <= false;
                    state <= IDLE;
                when others =>
                    state <= IDLE;

            end case;
        end if;
    end process;

end rtl;