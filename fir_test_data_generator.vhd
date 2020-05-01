
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_test_data_generator is
	generic(
		Win : INTEGER := 10; -- Input bit width
		Wout : INTEGER := 12;-- Output bit width
		Lfilter  : INTEGER := 513; -- Filter length
		BUTTON_HIGH : STD_LOGIC := '0';
		PATTERN_SIZE: INTEGER := 32;
		RANGE_LOW : INTEGER := -512; --pattern range: power of 2
		RANGE_HIGH : INTEGER := 511); --must change pattern too
	port (
		i_clk                   : in  std_logic;
		i_rstb                  : in  std_logic;
		i_pattern_sel           : in  std_logic;  -- '0'=> delta; '1'=> step
		i_start_generation      : in  std_logic;
		o_data                  : out std_logic_vector( Win-1 downto 0); -- to FIR 
		o_write_enable          : out std_logic);  -- to the output buffer
end fir_test_data_generator;

architecture rtl of fir_test_data_generator is

type t_pattern_input is array(0 to PATTERN_SIZE-1) of integer range RANGE_LOW to RANGE_HIGH;

constant C_PATTERN_DELTA     : t_pattern_input := (
	   0  ,
	 511  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  );

constant C_PATTERN_STEP      : t_pattern_input := (
	   0  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	 511  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  ,
	   0  );

component edge_detector
port (
	i_clk                       : in  std_logic;
	i_rstb                      : in  std_logic;
	i_input                     : in  std_logic;
	o_pulse                     : out std_logic);
end component;

signal r_write_counter             : integer range 0 to PATTERN_SIZE-1; 
signal r_write_counter_ena         : std_logic;
signal w_start_pulse               : std_logic;

begin

u_edge_detector : edge_detector
port map(
	i_clk                       => i_clk                       ,
	i_rstb                      => i_rstb                      ,
	i_input                     => i_start_generation          ,
	o_pulse                     => w_start_pulse               );

p_write_counter : process (i_rstb,i_clk)
begin
	if(i_rstb=BUTTON_HIGH) then
		r_write_counter             <= PATTERN_SIZE-1;
		r_write_counter_ena         <= '0';
	elsif(rising_edge(i_clk)) then
		if(w_start_pulse='1') then
			r_write_counter             <= 0;
			r_write_counter_ena         <= '1';
		elsif(r_write_counter<PATTERN_SIZE-1) then
			r_write_counter             <= r_write_counter + 1;
			r_write_counter_ena         <= '1';
		else
			r_write_counter_ena         <= '0';
		end if;
	end if;
end process p_write_counter;

p_output : process (i_rstb,i_clk)
begin
	if(i_rstb=BUTTON_HIGH) then
		o_data          <= (others=>'0');
		o_write_enable  <= '0';
	elsif(rising_edge(i_clk)) then
		o_write_enable  <= r_write_counter_ena;
		if(i_pattern_sel='0') then
			o_data     <= std_logic_vector(to_signed(C_PATTERN_DELTA(r_write_counter),Win));
		else
			o_data     <= std_logic_vector(to_signed(C_PATTERN_STEP(r_write_counter),Win));
		end if;		
	end if;
end process p_output;

end rtl;
