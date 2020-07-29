LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_test is
	generic( 
		Win 			: INTEGER 	:= 10		; -- Input bit width
		Wmult			: INTEGER 	:= 20		;-- Multiplier bit width 2*W1
		Wadd 			: INTEGER 	:= 26		;-- Adder width = Wmult+log2(L)-1
		Wout 			: INTEGER 	:= 12		;-- Output bit width
		BUTTON_HIGH 	: STD_LOGIC := '0'		;
		PATTERN_SIZE	: INTEGER 	:= 512		;
		RANGE_LOW 		: INTEGER 	:= -512		; --pattern range: power of 2
		RANGE_HIGH 		: INTEGER 	:= 511		; --must change pattern too
		LFilter  		: INTEGER 	:= 512		); -- Filter length
	port (
		clk              	  : in  std_logic;
		reset                 : in  std_logic;
		i_pattern_sel         : in  std_logic;  -- '0'=> delta; '1'=> step
		i_start_generation    : in  std_logic;
		i_read_request        : in  std_logic;
		o_data_buffer         : out std_logic_vector( Wout-1 downto 0); -- to seven segment
		o_test_add            : out std_logic_vector( 4 downto 0)); -- test read address
end fir_filter_test;

architecture rtl of fir_filter_test is

	type T_COEFF_INPUT is array(0 to LFilter-1) of integer range -512 to 511;

	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--0,1,2,5,9,16,25,36,48,62,77,92,105,115,123,127,127,123,115,
	--105,92,77,62,48,36,25,16,9,5,2,1,0);

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
	
	component fir_test_data_generator
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
		o_write_enable          : out std_logic);  -- to the output buffer
	end component;
	
	component fir_filter_4 
	generic( 
		Win 		: INTEGER	; -- Input bit width
		Wmult 		: INTEGER	;-- Multiplier bit width 2*W1
		Wadd 		: INTEGER	;-- Adder width = Wmult+log2(L)-1
		Wout 		: INTEGER	;-- Output bit width
		BUTTON_HIGH : STD_LOGIC ;
		LFilter  	: INTEGER	);--Filter Length
	port (
		clk      : in  std_logic	;
		reset    : in  std_logic	;
		i_coeff  : in  ARRAY_COEFF	;
		i_data   : in  std_logic_vector( Win-1 	downto 0)	;
		o_data   : out std_logic_vector( Wout-1 downto 0)   );
	end component;

	component fir_output_buffer 
	generic( 
		Win 		: INTEGER	; -- Input bit width
		Wout 		: INTEGER	; -- Output bit width
		BUTTON_HIGH : STD_LOGIC	;
		PATTERN_SIZE: INTEGER	;
		RANGE_LOW	: INTEGER 	; 
		RANGE_HIGH 	: INTEGER 	;
		LFilter  	: INTEGER	);
	port (
		i_clk              	    : in  std_logic;
		i_rstb             	    : in  std_logic;
		i_write_enable          : in  std_logic;
		i_data                  : in  std_logic_vector( Wout-1 downto 0); -- from FIR 
		i_read_request          : in  std_logic;
		o_data                  : out std_logic_vector( Wout-1 downto 0); -- to seven segment
		o_test_add              : out std_logic_vector( 4 downto 0)); -- test read address
	end component;

	signal w_write_enable  : std_logic;
	signal w_data_test     : std_logic_vector( Win-1 downto 0);	
	signal coeff           : ARRAY_COEFF(0 to Lfilter-1);
	signal w_data_filter   : std_logic_vector( Wout-1 downto 0);
	signal fir_output      : std_logic_vector( Wout-1 downto 0);

	type state_type is(ST_RESET, ST_LOAD_COEFF, ST_CONTINUE);
	signal state, next_state	: state_type;
	signal IsStartup : std_logic := '1';

begin

	w_data_filter <= fir_output;

	smachine_1: process (reset,clk)
	begin
		if rising_edge(clk) then
			if (reset = BUTTON_HIGH) then
				state <= ST_RESET;
			else
				state <= next_state;
			end if;
		end if;
	end process smachine_1;

	smachine_2: process(state, IsStartup)
	begin
		next_state <= state;
		case state is
			when ST_RESET =>
				if (IsStartup = '1') then
					next_state <= ST_LOAD_COEFF;
				else
					next_state <= ST_CONTINUE;
				end if;
			when ST_LOAD_COEFF =>
				if (IsStartup = '0') then
					next_state <= ST_CONTINUE;
				end if;
			when others => null;					
		end case;
	end process smachine_2;

	--p_coeff : process (reset,clk)
	--	variable first_time : std_logic := '0';
	--begin
	--	if(first_time='0' and reset /= BUTTON_HIGH) then
	--		if(rising_edge(clk)) then
	--			for k in 0 to Lfilter-1 loop
	--				coeff(k)  <=  std_logic_vector(to_signed(COEFF_ARRAY(k),Win));
	--			end loop;			
	--			first_time := '1';
	--		end if;
	--	end if;
	--end process p_coeff;	
	
	p_coeff : process (state)
	begin
		if(state = ST_LOAD_COEFF) then
			for k in 0 to Lfilter-1 loop
				coeff(k)  <=  std_logic_vector(to_signed(COEFF_ARRAY(k),Win));
			end loop;
			IsStartup <='0';
		end if;
	end process p_coeff;

	u_fir_test_data_generator : fir_test_data_generator
	generic map( 
		Win 		 => Win				, -- Input bit width
		Wout 		 => Wout			,-- Output bit width
		BUTTON_HIGH  => BUTTON_HIGH		,
		PATTERN_SIZE => PATTERN_SIZE	,
		RANGE_LOW	 => RANGE_LOW		, 
		RANGE_HIGH 	 => RANGE_HIGH		,
		LFilter  	 => LFilter			) -- Filter length	
	port map(
		i_clk              		=> clk                     ,
		i_rstb             	    => reset                   ,
		i_pattern_sel           => i_pattern_sel           ,
		i_start_generation      => i_start_generation      ,
		o_data                  => w_data_test             ,
		o_write_enable          => w_write_enable          );	
	
	u_fir_filter_4 : fir_filter_4
	generic map( 
		Win 		 => Win				, -- Input bit width
		Wmult		 => Wmult			,
		Wadd		 => Wadd			,
		Wout 		 => Wout			,-- Output bit width
		BUTTON_HIGH  => BUTTON_HIGH		,
		LFilter  	 => LFilter			) -- Filter length	
	port map(
		clk         => clk       		,
		reset       => reset      	 	,
		i_coeff     => coeff 			,
		i_data      => w_data_test 		,
		o_data     	=> fir_output		);

	u_fir_output_buffer : fir_output_buffer 
	generic map( 
		Win 		 => Win				, -- Input bit width
		Wout 		 => Wout			,-- Output bit width
		BUTTON_HIGH  => BUTTON_HIGH		,
		PATTERN_SIZE => PATTERN_SIZE	,
		RANGE_LOW	 => RANGE_LOW		, 
		RANGE_HIGH 	 => RANGE_HIGH		,
		LFilter  	 => LFilter			) -- Filter length
	port map(
		i_clk               => clk                ,
		i_rstb              => reset              ,
		i_write_enable      => w_write_enable     ,
		i_data              => w_data_filter      ,
		i_read_request      => i_read_request     ,
		o_data              => o_data_buffer      ,
		o_test_add          => o_test_add         );

end rtl;
