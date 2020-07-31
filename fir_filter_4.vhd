--UNCOMMENT IF TESTING THIS MODULE EXCLUSIVELY
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--PACKAGE n_bit_int IS
--	SUBTYPE COEFF_TYPE IS STD_LOGIC_VECTOR(9 DOWNTO 0)	; --Win-1
--	TYPE ARRAY_COEFF IS ARRAY (NATURAL RANGE <>) OF COEFF_TYPE; --LFilter-1
--END n_bit_int;
------------------------------------------

LIBRARY work;
USE work.n_bit_int.ALL;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 2^5 = 32 -> log2(32) = 5
-- 2*8 = 16 -> 16 + 5 - 1 = 20

entity fir_filter_4 is
generic ( 
	Win 			: INTEGER 	:= 10		; -- Input bit width
	Wmult			: INTEGER 	:= 20		;-- Multiplier bit width 2*W1
	Wadd 			: INTEGER 	:= 26		;-- Adder width = Wmult+log2(L)-1
	Wout 			: INTEGER 	:= 12		;-- Output bit width
	BUTTON_HIGH 	: STD_LOGIC := '0'		;
	LFilter  		: INTEGER 	:= 512		); -- Filter length
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
type t_add_st0 is array (0 to (LFilter/2)-1) of signed(Wadd-1  downto 0);

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
			for k in 0 to (LFilter/2)-1 loop
				add_st0(k) <= resize(mult(2*k),Wadd)  + resize(mult(2*k+1),Wadd);
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
			for k in 0 to (LFilter/2)-1 loop
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
			o_data  <= std_logic_vector(add_st1(Wadd downto (Wadd-Win-1)));
			--divide by 128 = shift right 7 bits (2^7=128)			
		end if;
	end process p_output;

end rtl;