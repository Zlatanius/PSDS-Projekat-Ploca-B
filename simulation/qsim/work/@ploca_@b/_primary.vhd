library verilog;
use verilog.vl_types.all;
entity Ploca_B is
    port(
        iCLK_50         : in     vl_logic;
        iSW             : in     vl_logic_vector(6 downto 0);
        GPIO_1          : inout  vl_logic_vector(31 downto 0);
        oHEX0_D         : out    vl_logic_vector(6 downto 0);
        oHEX1_D         : out    vl_logic_vector(6 downto 0);
        oHEX2_D         : out    vl_logic_vector(6 downto 0);
        oHEX3_D         : out    vl_logic_vector(6 downto 0);
        oHEX4_D         : out    vl_logic_vector(6 downto 0);
        oHEX5_D         : out    vl_logic_vector(6 downto 0);
        oHEX6_D         : out    vl_logic_vector(6 downto 0);
        oHEX7_D         : out    vl_logic_vector(6 downto 0);
        oHEX0_DP        : out    vl_logic;
        oHEX1_DP        : out    vl_logic;
        oHEX2_DP        : out    vl_logic;
        oHEX3_DP        : out    vl_logic;
        oHEX4_DP        : out    vl_logic;
        oHEX5_DP        : out    vl_logic;
        oHEX6_DP        : out    vl_logic;
        oHEX7_DP        : out    vl_logic;
        oLEDR           : out    vl_logic_vector(17 downto 0);
        oLEDG           : out    vl_logic_vector(7 downto 0)
    );
end Ploca_B;
