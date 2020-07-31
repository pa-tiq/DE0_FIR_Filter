library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

PACKAGE n_bit_int IS
	SUBTYPE COEFF_TYPE IS STD_LOGIC_VECTOR(8 DOWNTO 0);
	TYPE ARRAY_COEFF IS ARRAY (NATURAL RANGE <>) OF COEFF_TYPE;
END n_bit_int;

LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fir_filter is
	generic ( 
		Win 			: INTEGER 	:= 9		; -- Input bit width
		Wmult			: INTEGER 	:= 18		;-- Multiplier bit width 2*W1
		Wadd 			: INTEGER 	:= 25		;-- Adder width = Wmult+log2(L)-1
		Wout 			: INTEGER 	:= 11		;-- Output bit width
		BUTTON_HIGH 	: STD_LOGIC := '0'		;
		LFilter  		: INTEGER 	:= 256		); -- Filter length
end tb_fir_filter;

architecture behave of tb_fir_filter is

	constant noisy_size : integer := 100;
	type T_COEFF_INPUT is array(0 to LFilter-1) of integer range -256 to 255;	
	type T_NOISY_INPUT is array(0 to noisy_size-1) of integer range -256 to 255;

	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--	0,1,2,5,9,16,25,36,48,62,77,92,105,115,123,127,127,123,115,105,92,
	--	77,62,48,36,25,16,9,5,2,1,0);

	constant COEFF_ARRAY : T_COEFF_INPUT := (
		0,0,0,0,0,0,-1,-1,-1,-1,-1,-2,-2,-2,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,
		-2,-2,-1,0,1,2,3,4,5,6,7,8,10,11,12,13,14,15,15,16,17,17,17,17,17,16,16,15,14,12,
		11,9,7,5,3,0,-3,-6,-9,-12,-15,-18,-21,-24,-27,-30,-33,-35,-38,-40,-42,-43,-45,-45,
		-46,-45,-45,-44,-42,-39,-37,-33,-29,-24,-19,-13,-7,0,8,16,24,33,42,52,62,73,83,94,
		105,116,127,137,148,159,169,179,188,197,206,214,221,228,234,240,244,248,251,253,255,
		255,253,251,248,244,240,234,228,221,214,206,197,188,179,169,159,148,137,127,116,105,
		94,83,73,62,52,42,33,24,16,8,0,-7,-13,-19,-24,-29,-33,-37,-39,-42,-44,-45,-45,-46,-45,
		-45,-43,-42,-40,-38,-35,-33,-30,-27,-24,-21,-18,-15,-12,-9,-6,-3,0,3,5,7,9,11,12,14,
		15,16,16,17,17,17,17,17,16,15,15,14,13,12,11,10,8,7,6,5,4,3,2,1,0,-1,-2,-2,-3,-3,-4,
		-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,-3,-2,-2,-2,-1,-1,-1,-1,-1,0,0,0,0,0,0);
	
	constant NOISY_ARRAY : T_NOISY_INPUT := (
		-10,1,11,35,36,18,49,41,42,51,51,56,70,75,79,79,72,87,96,93,100,
		101,98,104,100,111,101,103,106,95,121,115,109,121,103,111,109,111,
		110,101,104,101,103,103,100,85,87,76,73,75,80,62,64,56,59,41,42,40,
		38,35,21,6,5,-3,11,-11,-9,-20,-19,-35,-44,-49,-43,-52,-58,-53,-64,
		-70,-66,-84,-80,-83,-93,-93,-105,-108,-103,-102,-94,-114,-111,-114,
		-126,-119,-127,-112,-122,-117,-120,-114);

	component fir_filter 
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

	u_fir_filter : fir_filter 
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
			
		-- DELTA, STEP ...........
		--	if(control=10 and count = 0) then  -- delta
		--		i_data       <= ('0',others=>'1');
		--	elsif(control(10)='1' and count <1000 ) then  -- step
		--		i_data       <= ('0',others=>'1');
		--		count := count + 1;
		--	else
		--		i_data       <= (others=>'0');
		--	end if;
		--	control := control + 1;
		------------------------------------------------

		-- DELTA, STEP, STEP, STEP, .......
		--	if(control=10) then  -- delta
		--		i_data       <= ('0',others=>'1');
		--	elsif(control(7)='1') then  -- step
		--		i_data       <= ('0',others=>'1');
		--	else
		--		i_data       <= (others=>'0');
		--	end if;
		--	control := control + 1;
		-------------------------------------------------
		
		-- NOISY ANALOG SIGNAL
			if(count < noisy_size) then
				i_data <= NOISY(count);
				count := count + 1;
			else
				i_data <= (others=>'0');
			end if;
		-------------------------------------------------

		end if;
	end process p_input;

end behave;
