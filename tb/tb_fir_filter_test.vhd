library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

PACKAGE n_bit_int IS
	SUBTYPE COEFF_TYPE IS STD_LOGIC_VECTOR(9 DOWNTO 0);
	TYPE ARRAY_COEFF IS ARRAY (NATURAL RANGE <>) OF COEFF_TYPE;
END n_bit_int;

LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fir_filter_test is
	generic( 
		Win 			: INTEGER 	:= 10		;-- Input bit width
		Wmult			: INTEGER 	:= 20    	;-- Multiplier bit width 2*Win
		Wadd 			: INTEGER 	:= 28		;-- Adder width = Wmult+log2(L)-1
		Wout 			: INTEGER 	:= 28		;-- Output bit width: between Win and Wadd
		BUTTON_HIGH 	: STD_LOGIC := '0'		;
		PATTERN_SIZE	: INTEGER 	:= 256		;
		RANGE_LOW 		: INTEGER 	:= -512		; --pattern range: power of 2
		RANGE_HIGH 		: INTEGER 	:= 511		; --must change pattern too
		LFilter  		: INTEGER 	:= 512		); -- Filter length
end tb_fir_filter_test;

architecture behave of tb_fir_filter_test is

component fir_filter_test
generic( 
	Win 			: INTEGER 	; -- Input bit width
	Wmult			: INTEGER 	;-- Multiplier bit width 2*W1
	Wadd 			: INTEGER 	;-- Adder width = Wmult+log2(L)-1
	Wout 			: INTEGER 	;-- Output bit width
	BUTTON_HIGH 	: STD_LOGIC ;
	PATTERN_SIZE	: INTEGER 	;
	RANGE_LOW 		: INTEGER 	; --pattern range: power of 2
	RANGE_HIGH 		: INTEGER 	; --must change pattern too
	LFilter  		: INTEGER 	); -- Filter length
port (
	clk                   	: in  std_logic;
	reset                  	: in  std_logic;
	i_pattern_sel           : in  std_logic;  -- '0'=> delta; '1'=> step
	i_start_generation      : in  std_logic;
	i_read_request          : in  std_logic;
	o_data_buffer           : out std_logic_vector( Wout-1 downto 0); -- to seven segment
	o_test_add              : out std_logic_vector( 4 downto 0)); -- test read address
end component;

signal clk                     : std_logic:='0';
signal reset                   : std_logic;
signal i_pattern_sel           : std_logic:='1';  -- '0'=> delta; '1'=> step
signal i_start_generation      : std_logic;
signal i_read_request          : std_logic;
signal o_data_buffer           : std_logic_vector( Wout-1 downto 0); -- to seven segment
signal o_test_add              : std_logic_vector( 4 downto 0); -- test read address

begin

clk   <= not clk after 5 ns;
reset  <= '0', '1' after 132 ns;

u_fir_filter_test : fir_filter_test
generic map( 
	Win 	   	 => Win			 ,
	Wmult 	   	 => Wmult		 ,
	Wadd 	   	 => Wadd		 ,
	Wout 	  	 => Wout		 ,
	LFilter 	 => LFilter		 ,
	RANGE_LOW 	 => RANGE_LOW	 ,
	RANGE_HIGH 	 => RANGE_HIGH	 ,
	BUTTON_HIGH  => BUTTON_HIGH	 ,
	PATTERN_SIZE => PATTERN_SIZE )
port map(
	clk              	 => clk                  ,
	reset                => reset                ,
	i_pattern_sel        => i_pattern_sel        ,
	i_start_generation   => i_start_generation   ,
	i_read_request       => i_read_request       ,
	o_data_buffer        => o_data_buffer        ,
	o_test_add           => o_test_add           );	

p_input : process (reset,clk)
variable control : unsigned(9 downto 0):= (others=>'0');
begin
	if(reset='0') then
		i_start_generation           <= '0';
	elsif(rising_edge(clk)) then
		if(control=10) then 
			i_start_generation       <= '1';
		else
			i_start_generation       <= '0';
		end if;
		control := control + 1;
		
		if(control>100)then
			i_read_request           <= control(3);
		else
			i_read_request           <= '0';
		end if;
	end if;
end process p_input;

end behave;

