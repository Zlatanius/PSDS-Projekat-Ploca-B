library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Obrada is
    Port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        data_in       : in  std_logic_vector(7 downto 0);
        request_obrada: in  std_logic;
        obrada_done   : out std_logic;
        prosjek       : out std_logic_vector(15 downto 0)
    );
end Obrada;

architecture rtl of Obrada is
    type ram_type is array(255 downto 0) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (others => (others => '0'));
    
    type state_type is (IDLE, READ_NEXT, COMPUTE, DONE);
    signal state : state_type := IDLE;

    signal write_addr : integer range 0 to 255 := 0;
    signal read_addr  : integer range 0 to 255 := 0;
    signal ram_data   : std_logic_vector(31 downto 0);

    constant SCALE_FACTOR   : unsigned(31 downto 0) := to_unsigned(65536, 32);
    constant ALPHA_SCALED   : unsigned(31 downto 0) := to_unsigned(13107, 32);
    constant ONE_SCALED     : unsigned(31 downto 0) := to_unsigned(65536, 32);

    signal weight_scaled         : unsigned(31 downto 0) := ONE_SCALED;
    signal weighted_sum_scaled   : unsigned(31 downto 0) := to_unsigned(0, 32);
    signal sum_of_weights_scaled : unsigned(31 downto 0) := to_unsigned(0, 32);
	 signal tmp_div			 		: unsigned(31 downto 0) := to_unsigned(0, 32);

    ATTRIBUTE keep : BOOLEAN;
    ATTRIBUTE keep OF state : SIGNAL IS true;

begin

    process(clk)
        variable temp_data_value       : unsigned(31 downto 0);
        variable new_weighted_sum      : unsigned(31 downto 0);
        variable new_sum_of_weights    : unsigned(31 downto 0);
        variable new_weight_scaled     : unsigned(31 downto 0);
        variable temp_weight_mult      : unsigned(31 downto 0);
    begin
        if reset = '1' then
            state                   <= IDLE;
            write_addr              <= 0;
            read_addr               <= 0;
            obrada_done             <= '0';
            prosjek                 <= (others => '0');
            weight_scaled           <= ONE_SCALED;
            weighted_sum_scaled     <= to_unsigned(0, 32);
            sum_of_weights_scaled   <= to_unsigned(0, 32);

        elsif rising_edge(clk) then
            case state is

                when IDLE =>
                    obrada_done <= '0';

                    if request_obrada = '1' then
                        ram(write_addr)        <= (31 downto 8 => '0') & data_in;
                        read_addr              <= write_addr;
                        write_addr             <= write_addr + 1;
                        weighted_sum_scaled    <= to_unsigned(0, 32);
                        sum_of_weights_scaled  <= to_unsigned(0, 32);
                        weight_scaled          <= ONE_SCALED;
                        state                  <= READ_NEXT;
                    end if;

                when READ_NEXT =>
                    ram_data <= ram(read_addr);
                    state    <= COMPUTE;

                when COMPUTE =>
                    -- Use variable to immediately capture data
                    temp_data_value    := (23 downto 0 => '0') & unsigned(ram_data(7 downto 0));
                    new_weighted_sum   := weighted_sum_scaled + unsigned(temp_data_value * weight_scaled)(31 downto 0);
                    new_sum_of_weights := sum_of_weights_scaled + weight_scaled;

                    temp_weight_mult   := ONE_SCALED - ALPHA_SCALED;
                    new_weight_scaled  := unsigned(weight_scaled * temp_weight_mult)(31 downto 0) / SCALE_FACTOR;

                    tmp_div <= new_weighted_sum / new_sum_of_weights;
						  
						  -- Now update signals
                    weighted_sum_scaled     <= new_weighted_sum;
                    sum_of_weights_scaled   <= new_sum_of_weights;
                    weight_scaled           <= new_weight_scaled;
						  
                    if read_addr = 0 then
                        state <= DONE;
                    else
                        read_addr <= read_addr - 1;
                        state     <= READ_NEXT;
                    end if;

                when DONE =>
                    if sum_of_weights_scaled > 0 then
                        prosjek <= std_logic_vector(tmp_div(15 downto 0));
						  else
                        prosjek <= (others 	=> '0');
                    end if;

                    obrada_done <= '1';
                    state       <= IDLE;

                when others =>
                    state <= IDLE;

            end case;
        end if;
    end process;

end rtl;
