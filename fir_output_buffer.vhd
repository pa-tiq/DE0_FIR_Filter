--UNCOMMENT IF TESTING FILE INDEPENDENTLY
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

PACKAGE n_bit_int IS
	SUBTYPE COEFF_TYPE IS STD_LOGIC_VECTOR(7 DOWNTO 0)	; --Win-1
	TYPE ARRAY_COEFF IS ARRAY (NATURAL RANGE <>) OF COEFF_TYPE; --LFilter-1
END n_bit_int;
-- ------------------------------------------

LIBRARY work;
USE work.n_bit_int.ALL;

library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
use ieee.numeric_std.all;

entity fir_output_buffer is
	generic( 
		Win 		: INTEGER	:= 8	; -- Input bit width
		Wout 		: INTEGER	:= 10	;-- Output bit width
		BUTTON_HIGH : STD_LOGIC	:= '0'	;
		PATTERN_SIZE: INTEGER	:= 32	;
		RANGE_LOW	: INTEGER 	:= -128 ; 
		RANGE_HIGH 	: INTEGER 	:= 127	;
		LFilter  	: INTEGER	:= 32	); -- Filter length
	port (
		i_clk                   : in  std_logic;
		i_rstb                  : in  std_logic;
		i_write_enable          : in  std_logic;
		i_data                  : in  std_logic_vector( Wout-1 downto 0); -- from FIR
		i_read_request          : in  std_logic;
		o_data                  : out std_logic_vector( Wout-1 downto 0); -- to seven segment
		o_test_add              : out std_logic_vector( 4 downto 0)); -- test read address
end fir_output_buffer;

architecture rtl of fir_output_buffer is

	type t_output_buffer_mem is array(0 to PATTERN_SIZE-1) of std_logic_vector( Wout-1 downto 0);

	component edge_detector
	port (
		i_clk                       : in  std_logic;
		i_rstb                      : in  std_logic;
		i_input                     : in  std_logic;
		o_pulse                     : out std_logic);
	end component;

	signal output_buffer_mem           : t_output_buffer_mem ;
	signal r_write_add                 : integer range 0 to PATTERN_SIZE-1;
	signal r_read_add                  : integer range 0 to PATTERN_SIZE-1;
	signal w_read_pulse                : std_logic;

	begin

	u_edge_detector : edge_detector
	port map(
		i_clk      => i_clk             ,
		i_rstb     => i_rstb            ,
		i_input    => i_read_request    ,
		o_pulse    => w_read_pulse      );

	p_write_counter : process (i_rstb,i_clk)
		begin
			if(i_rstb=BUTTON_HIGH) then
				r_write_add <= 0;
			elsif(rising_edge(i_clk)) then
				if(i_write_enable='1') then
					if(r_write_add<PATTERN_SIZE-1) then
						r_write_add   <= r_write_add + 1;
					end if;
				else
					r_write_add <= 0;
				end if;
			end if;
	end process p_write_counter;

	p_read_counter : process (i_rstb,i_clk)
		begin
			if(i_rstb=BUTTON_HIGH) then
				r_read_add  <= 0;
			elsif(rising_edge(i_clk)) then
				if(w_read_pulse='1') then
					if(r_read_add<PATTERN_SIZE-1) then
						r_read_add <= r_read_add + 1;
					else
						r_read_add <= 0;
					end if;
				end if;
			end if;
	end process p_read_counter;

	p_memory : process (i_clk)
		begin
			if(rising_edge(i_clk)) then
				if(i_write_enable='1') then
					output_buffer_mem(r_write_add) <= i_data;
				end if;
				o_data <= output_buffer_mem(r_read_add);
			end if;
	end process p_memory;

	o_test_add  <= std_logic_vector(to_unsigned(r_read_add,5));

end rtl;
