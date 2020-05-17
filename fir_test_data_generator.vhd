LIBRARY work;
USE work.n_bit_int.ALL;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_test_data_generator is
	generic( 
		Win 		: INTEGER	; -- Input bit width
		Wout 		: INTEGER	;-- Output bit width
		BUTTON_HIGH : STD_LOGIC	;
		PATTERN_SIZE: INTEGER	;
		RANGE_LOW	: INTEGER 	; 
		RANGE_HIGH 	: INTEGER 	;
		LFilter  	: INTEGER	); -- Filter length
	port (
		i_clk                   : in  std_logic;
		i_rstb                  : in  std_logic;
		i_pattern_sel           : in  std_logic;  -- '0'=> delta; '1'=> step
		i_start_generation      : in  std_logic;
		o_data                  : out std_logic_vector( Win-1 downto 0); -- to FIR
		--o_data 					: out S8i;
		o_write_enable          : out std_logic);  -- to the output buffer
end fir_test_data_generator;

architecture rtl of fir_test_data_generator is

type t_pattern_input is array(0 to 31) of integer range -128 to 127;

constant C_PATTERN_DELTA     : t_pattern_input := (
	   0  ,
	 127  ,
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
	 127  ,
	 127  ,
	 127  ,
	 127  ,
	 127  ,
	 127  ,
	 127  ,
	 127  ,
	 127  ,
	 127  ,
	 127  ,
	 127  ,
	 127  ,
	 127  ,
	 127  ,
	 127  ,
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
			--o_data <= 0;
			o_write_enable  <= '0';
		elsif(rising_edge(i_clk)) then
			o_write_enable  <= r_write_counter_ena;
			if(i_pattern_sel='0') then
				o_data     <= std_logic_vector(to_signed(C_PATTERN_DELTA(r_write_counter),Win));
			--	o_data <= C_PATTERN_DELTA(r_write_counter);
			else
				o_data     <= std_logic_vector(to_signed(C_PATTERN_STEP(r_write_counter),Win));
			--	o_data <= C_PATTERN_STEP(r_write_counter);
			end if;		
		end if;
	end process p_output;

end rtl;
