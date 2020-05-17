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

entity tb_fir_filter_4 is
	generic( 
		Win 			: INTEGER 	:= 8		; -- Input bit width
		Wmult			: INTEGER 	:= 16		;-- Multiplier bit width 2*W1
		Wadd 			: INTEGER 	:= 17		;-- Adder width = Wmult+log2(L)-1
		Wout 			: INTEGER 	:= 10		;-- Output bit width
		BUTTON_HIGH 	: STD_LOGIC := '0'		;
		LFilter  		: INTEGER 	:= 4		;-- Filter length
		LfilterHalf		: INTEGER 	:= 2		); 
end tb_fir_filter_4;

architecture behave of tb_fir_filter_4 is

	component fir_filter_4 
	port (
		clk     : IN  STD_LOGIC								;  -- System clock
		reset   : IN  STD_LOGIC								;
		i_coeff : in  ARRAY_COEFF							; 
		i_data  : IN  std_logic_vector( Win-1 	downto 0)	;-- System input
		o_data  : OUT std_logic_vector( Wout-1 	downto 0)	);-- System output 
	end component;

	signal clk          : std_logic:='0';
	signal reset        : std_logic:='0';
	signal i_coeff 		: ARRAY_COEFF	; 

	signal i_data       : std_logic_vector( Win-1  downto 0) 	 ;
	signal o_data       : std_logic_vector( Wout-1 downto 0) 	 ;

begin

	i_coeff(0)   <= std_logic_vector(to_signed(-10,Win));
	i_coeff(1)   <= std_logic_vector(to_signed(110,Win));
	i_coeff(2)   <= std_logic_vector(to_signed(127,Win));
	i_coeff(3)   <= std_logic_vector(to_signed(-20,Win));

	clk   <= not clk after 5 ns;
	reset  <= '0', '1' after 132 ns;

	u_fir_filter_4 : fir_filter_4 
	port map(
		clk         => clk        ,
		reset       => reset      ,
		i_coeff 	=> i_coeff	  ,
		i_data      => i_data     ,
		o_data      => o_data     );

	p_input : process (reset,clk)
	variable control  : unsigned(10 downto 0):= (others=>'0');
	begin
		if(reset=BUTTON_HIGH) then
			i_data       <= (others=>'0');
		elsif(rising_edge(clk)) then
			if(control=10) then  -- delta
				i_data       <= ('0',others=>'1');
			elsif(control(7)='1') then  -- step
				i_data       <= ('0',others=>'1');
			else
				i_data       <= (others=>'0');
			end if;
			control := control + 1;
		end if;
	end process p_input;

end behave;
