library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

PACKAGE n_bit_int IS
	SUBTYPE COEFF_TYPE IS STD_LOGIC_VECTOR(7 DOWNTO 0)	; 
	TYPE ARRAY_COEFF IS ARRAY (0 TO 3) OF COEFF_TYPE;
END n_bit_int;

LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_4 is
generic( 
	Win 			: INTEGER 	:= 8		; -- Input bit width
	Wmult			: INTEGER 	:= 16		;-- Multiplier bit width 2*W1
	Wadd 			: INTEGER 	:= 17		;-- Adder width = Wmult+log2(L)-1
	Wout 			: INTEGER 	:= 10		;-- Output bit width
	BUTTON_HIGH 	: STD_LOGIC := '0'		;
	LFilter  		: INTEGER 	:= 4		;-- Filter length
	LFilterHalf		: INTEGER 	:= 2		); 
port (
	clk      : in  std_logic							;
	reset    : in  std_logic							;
	i_coeff  : in  ARRAY_COEFF							;
	i_data   : in  std_logic_vector( Win-1 	downto 0)	;
	o_data   : out std_logic_vector( Wout-1 downto 0)   );
end fir_filter_4;

architecture rtl of fir_filter_4 is 

type t_data    is array (0 to Lfilter-1) 	 of signed(Win-1   downto 0);
type t_mult    is array (0 to Lfilter-1) 	 of signed(Wmult-1 downto 0);
type t_add_st0 is array (0 to LFilterHalf-1) of signed(Wadd-1  downto 0);

signal coeff     : t_data				;
signal data      : t_data				;
signal mult      : t_mult				;
signal add_st0   : t_add_st0			;
signal add_st1   : signed(Wadd downto 0);

begin
		
	p_input : process (reset,clk)
	begin
		if(reset=BUTTON_HIGH) then
			data   <= (others=>(others=>'0'));
			coeff  <= (others=>(others=>'0'));
		elsif(rising_edge(clk)) then
			data <= signed(i_data)&data(0 to data'length-2);
			for k in 0 to Lfilter-1 loop
				coeff(k)  <= signed(i_coeff(k));
			end loop;				  
			--output = to_signed(input, output'length);
			--coeff(0)  <= to_signed(-10,Win);
			--coeff(1)  <= to_signed(110,Win);
			--coeff(2)  <= to_signed(127,Win);
			--coeff(3)  <= to_signed(-20,Win);
		end if;
	end process p_input;

	p_mult : process (reset,clk)
	begin
		if(reset=BUTTON_HIGH) then
			mult <= (others=>(others=>'0'));
		elsif(rising_edge(clk)) then
			for k in 0 to Lfilter-1 loop
				mult(k) <= data(k) * coeff(k);
			end loop;
		end if;
	end process p_mult;

	p_add_st0 : process (reset,clk)
	begin
		if(reset=BUTTON_HIGH) then
			add_st0 <= (others=>(others=>'0'));
		elsif(rising_edge(clk)) then
			for k in 0 to LFilterHalf-1 loop
				add_st0(k) <= resize(mult(2*k),Wadd)  + resize(mult(2*k+1),Wadd);
				-- add0(0) <= mult(0) + mult(1)
				-- add0(1) <= mult(2) + mult(3)
				-- ...
			end loop;
		end if;
	end process p_add_st0;

	p_add_st1 : process (reset,clk)
		variable add_temp  : signed(Wadd downto 0);
	begin
		add_temp := (others=>'0');
		if(reset=BUTTON_HIGH) then
			add_st1  <= (others=>'0');
		elsif(rising_edge(clk)) then			
			for k in 0 to LFilterHalf-1 loop
				add_temp := resize(add_st0(k),Wadd+1) + add_temp;
			end loop;
			add_st1 <= add_temp;					
		end if;
	end process p_add_st1;

	p_output : process (reset,clk)
	begin
		if(reset=BUTTON_HIGH) then
			o_data  <= (others=>'0');
		elsif(rising_edge(clk)) then
			o_data  <= std_logic_vector(add_st1(Wadd downto (Wadd-9))); --divide by 128, i.e. shift right 7 bits			
		end if;
	end process p_output;

end rtl;

--    0.0028
--	  0.0084
--   -0.0079
--   -0.0044
--    0.0111
--   -0.0017
--   -0.0109
--    0.0083
--    0.0070
--   -0.0131
--    0.0001
--    0.0144
--   -0.0086
--   -0.0108
--    0.0160
--    0.0026
--   -0.0196
--    0.0089
--    0.0170
--   -0.0206
--   -0.0074
--    0.0289
--   -0.0090
--   -0.0297
--    0.0301
--    0.0188
--   -0.0525
--    0.0091
--    0.0723
--   -0.0695
--   -0.0860
--    0.3054
--    0.5908
--    0.3054
--   -0.0860
--   -0.0695
--    0.0723
--    0.0091
--   -0.0525
--    0.0188
--    0.0301
--   -0.0297
--   -0.0090
--    0.0289
--   -0.0074
--   -0.0206
--    0.0170
--    0.0089
--   -0.0196
--    0.0026
--    0.0160
--   -0.0108
--   -0.0086
--    0.0144
--    0.0001
--   -0.0131
--    0.0070
--    0.0083
--   -0.0109
--   -0.0017
--    0.0111
--   -0.0044
--   -0.0079
--    0.0084
--    0.0028
		
		
		
		
		
		
		
		
		
		
		
		
		
		