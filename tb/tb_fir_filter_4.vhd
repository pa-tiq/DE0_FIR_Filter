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
	type T_COEFF_INPUT is array(0 to LFilter-1) of integer range -512 to 511;	
	type T_NOISY_INPUT is array(0 to noisy_size-1) of integer range -512 to 511;

	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--	0,1,2,5,9,16,25,36,48,62,77,92,105,115,123,127,127,123,115,105,92,
	--	77,62,48,36,25,16,9,5,2,1,0);

	constant COEFF_ARRAY : T_COEFF_INPUT := (
		0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-3,-3,-3,-4,-4,-4,-4,-5,-5,-5,-6,-6,-6,-7,
		-7,-7,-7,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-7,-7,-7,-6,-6,-5,-5,-4,-4,-3,-2,-2,
		-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20,22,23,24,25,26,27,28,29,29,30,31,32,
		32,33,33,33,34,34,34,34,34,34,34,33,33,32,31,31,30,29,27,26,25,23,22,20,18,16,14,12,10,8,
		5,3,0,-3,-5,-8,-11,-14,-17,-20,-23,-26,-29,-33,-36,-39,-42,-45,-48,-51,-54,-57,-60,-63,-66,
		-69,-71,-74,-76,-78,-80,-82,-84,-86,-87,-88,-89,-90,-91,-91,-91,-91,-91,-90,-90,-89,-87,-86,
		-84,-82,-79,-76,-73,-70,-66,-63,-58,-54,-49,-44,-39,-33,-27,-21,-14,-7,0,7,15,23,31,40,48,
		57,66,76,85,95,105,115,125,135,146,156,167,177,188,199,210,221,232,243,254,265,275,286,297,
		307,318,328,338,348,358,368,377,387,396,404,413,421,429,437,444,451,458,464,470,475,481,485,
		490,494,497,501,503,506,508,509,510,511,511,510,509,508,506,503,501,497,494,490,485,481,
		475,470,464,458,451,444,437,429,421,413,404,396,387,377,368,358,348,338,328,318,307,297,286,
		275,265,254,243,232,221,210,199,188,177,167,156,146,135,125,115,105,95,85,76,66,57,48,40,31,
		23,15,7,0,-7,-14,-21,-27,-33,-39,-44,-49,-54,-58,-63,-66,-70,-73,-76,-79,-82,-84,-86,-87,-89,
		-90,-90,-91,-91,-91,-91,-91,-90,-89,-88,-87,-86,-84,-82,-80,-78,-76,-74,-71,-69,-66,-63,-60,
		-57,-54,-51,-48,-45,-42,-39,-36,-33,-29,-26,-23,-20,-17,-14,-11,-8,-5,-3,0,3,5,8,10,12,14,16,
		18,20,22,23,25,26,27,29,30,31,31,32,33,33,34,34,34,34,34,34,34,33,33,33,32,32,31,30,29,29,28,
		27,26,25,24,23,22,20,19,18,17,16,15,13,12,11,10,9,8,7,6,5,4,3,2,1,0,-1,-2,-2,-3,-4,-4,-5,-5,
		-6,-6,-7,-7,-7,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-7,-7,-7,-7,-6,-6,-6,-5,-5,-5,-4,
		-4,-4,-4,-3,-3,-3,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0);
	
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
		--	if(control=10 and count = 0) then  -- delta
		--		i_data       <= ('0',others=>'1');
		--	elsif(control(10)='1' and count <1000 ) then  -- step
		--		i_data       <= ('0',others=>'1');
		--		count := count + 1;
		--	else
		--		i_data       <= (others=>'0');
		--	end if;
		--	control := control + 1;
		
		-- NOISY ANALOG SIGNAL
			if(count < noisy_size) then
				i_data <= NOISY(count);
				count := count + 1;
			else
				i_data <= (others=>'0');
			end if;
			
		end if;
	end process p_input;

end behave;
