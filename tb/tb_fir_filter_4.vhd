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

entity tb_fir_filter_4 is
	generic ( 
	Win 			: INTEGER 	:= 10		; -- Input bit width
	Wmult			: INTEGER 	:= 20		;-- Multiplier bit width 2*W1
	Wadd 			: INTEGER 	:= 26		;-- Adder width = Wmult+log2(L)-1
	Wout 			: INTEGER 	:= 12		;-- Output bit width
	BUTTON_HIGH 	: STD_LOGIC := '0'		;
	LFilter  		: INTEGER 	:= 512		); -- Filter length
end tb_fir_filter_4;

architecture behave of tb_fir_filter_4 is

	constant noisy_size : integer := 100;
	type T_COEFF_INPUT is array(0 to LFilter-1) of integer range -128 to 127;	
	type T_NOISY_INPUT is array(0 to noisy_size-1) of integer range -128 to 127;

	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--	0,1,2,5,9,16,25,36,48,62,77,92,105,115,123,127,127,123,115,105,92,
	--	77,62,48,36,25,16,9,5,2,1,0);

	constant COEFF_ARRAY : T_COEFF_INPUT := (
		0,-8,-12,-8,1,12,16,11,-4,-20,-28,-17,13,56,98,124,124,98,56,13,-17,
		-28,-20,-4,11,16,12,1,-8,-12,-8,0);

	constant NOISY_ARRAY : T_NOISY_INPUT := (
		-10,1,11,35,36,18,49,41,42,51,51,56,70,75,79,79,72,87,96,93,100,
		101,98,104,100,111,101,103,106,95,121,115,109,121,103,111,109,111,
		110,101,104,101,103,103,100,85,87,76,73,75,80,62,64,56,59,41,42,40,
		38,35,21,6,5,-3,11,-11,-9,-20,-19,-35,-44,-49,-43,-52,-58,-53,-64,
		-70,-66,-84,-80,-83,-93,-93,-105,-108,-103,-102,-94,-114,-111,-114,
		-126,-119,-127,-112,-122,-117,-120,-114);

	component fir_filter_4 
	port (
		clk     : IN  STD_LOGIC								;  -- System clock
		reset   : IN  STD_LOGIC								;
		i_coeff : in  ARRAY_COEFF(0 to Lfilter-1)			; 
		i_data  : IN  std_logic_vector( Win-1 	downto 0)	;-- System input
		o_data  : OUT std_logic_vector( Wout-1 	downto 0)	);-- System output 
	end component;

	signal clk      : std_logic:='0';
	signal reset    : std_logic:='0';
	signal i_coeff 	: ARRAY_COEFF(0 to Lfilter-1); 
	signal i_data   : std_logic_vector( Win-1  downto 0);
	signal o_data   : std_logic_vector( Wout-1 downto 0);
	signal NOISY	: ARRAY_COEFF(0 to noisy_size-1);

begin

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
		variable control  	: unsigned(10 downto 0):= (others=>'0');
		variable count 		: integer := 0;
		variable first_time : std_logic := '0';
	begin
		if(first_time='0') then
			for k in 0 to Lfilter-1 loop
				i_coeff(k)  <=  std_logic_vector(to_signed(COEFF_ARRAY(k),Win));
			end loop;			
			for k in 0 to noisy_size-1 loop
				NOISY(k)  <=  std_logic_vector(to_signed(NOISY_ARRAY(k),Win));
			end loop;
			first_time := '1';
		end if;
		
		if(reset=BUTTON_HIGH) then
			i_data       <= (others=>'0');
		elsif(rising_edge(clk)) then
			
		-- DELTA, STEP, STEP, STEP, .......
			if(control=10) then  -- delta
				i_data       <= ('0',others=>'1');
			elsif(control(7)='1') then  -- step
				i_data       <= ('0',others=>'1');
			else
				i_data       <= (others=>'0');
			end if;
			control := control + 1;
		
		-- NOISY ANALOG SIGNAL
		--	if(count < noisy_size) then
		--		i_data <= NOISY(count);
		--		count := count + 1;
		--	else
		--		i_data <= (others=>'0');
		--	end if;
			
		end if;
	end process p_input;

end behave;
