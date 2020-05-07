library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fir_filter_test is
	generic(
	Win : INTEGER := 8; -- Input bit width
	Wout : INTEGER := 9;-- Output bit width
	Lfilter : INTEGER := 513; --Filter Length
	BUTTON_HIGH : STD_LOGIC = '0';
	RANGE_LOW : INTEGER := -128; --coeff range: power of 2
	RANGE_HIGH : INTEGER := 127);
end tb_fir_filter_test;

architecture behave of tb_fir_filter_test is

component fir_filter_test 
port (
	i_clk                   : in  std_logic;
	i_rstb                  : in  std_logic;
	i_pattern_sel           : in  std_logic;  -- '0'=> delta; '1'=> step
	i_start_generation      : in  std_logic;
	i_read_request          : in  std_logic;
	o_data_buffer           : out std_logic_vector( Wout-1 downto 0); -- to seven segment
	o_test_add              : out std_logic_vector( 4 downto 0)); -- test read address
end component;

signal i_clk                   : std_logic:='0';
signal i_rstb                  : std_logic;
signal i_pattern_sel           : std_logic:='0';  -- '0'=> delta; '1'=> step
signal i_start_generation      : std_logic;
signal i_read_request          : std_logic;
signal o_data_buffer           : std_logic_vector( Wout-1 downto 0); -- to seven segment
signal o_test_add              : std_logic_vector( 4 downto 0); -- test read address

begin

i_clk   <= not i_clk after 5 ns;
i_rstb  <= '0', '1' after 132 ns;

u_fir_filter_test : fir_filter_test 
port map(
	i_clk                   => i_clk                   ,
	i_rstb                  => i_rstb                  ,
	i_pattern_sel           => i_pattern_sel           ,
	i_start_generation      => i_start_generation      ,
	i_read_request          => i_read_request          ,
	o_data_buffer           => o_data_buffer           ,
	o_test_add              => o_test_add              );
	
------------------------------------------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------------------------------------------

p_input : process (i_rstb,i_clk)
variable control            : unsigned(Win+1 downto 0):= (others=>'0');
--variable controlCoeff : unsigned(Win+1 downto 0):= (others=>'0');
begin
	if(i_rstb=BUTTON_HIGH) then
		i_start_generation           <= '0';
	elsif(rising_edge(i_clk)) then
--		if(controlCoeff =Lfilter) then
			if(control=10) then 
				i_start_generation       <= '1';
			else
				i_start_generation       <= '0';
			end if;
			control := control + 1;
			
			if(control>100)then
				i_read_request  <= control(3);
			else
				i_read_request           <= '0';
			end if;
--		else
--			controlCoeff := controlCoeff+1;
	end if;
end process p_input;

end behave;
