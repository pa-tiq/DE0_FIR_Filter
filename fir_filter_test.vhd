LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_test is
	generic(  
		Win 		: INTEGER 	:= 8	; -- Input bit width
		Wmult 		: INTEGER 	:= 16	;-- Multiplier bit width 2*W1
		Wadd 		: INTEGER 	:= 20	;-- Adder width = Wmult+log2(L)-1
		Wout 		: INTEGER 	:= 10	;-- Output bit width
		Lfilter 	: INTEGER 	:= 32	; --Filter Length
		RANGE_LOW 	: INTEGER 	:= -128 ; --coeff range: power of 2
		RANGE_HIGH 	: INTEGER 	:= 127  ;
		BUTTON_HIGH : STD_LOGIC := '0'	;
		PATTERN_SIZE: INTEGER   := 32 	);
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

	type T_COEFF_INPUT is array(0 to LFilter-1) of integer range -128 to 127;

	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--0,1,2,5,9,16,25,36,48,62,77,92,105,115,123,127,127,123,115,
	--105,92,77,62,48,36,25,16,9,5,2,1,0);

	--SINC FILTER:
	constant COEFF_ARRAY : T_COEFF_INPUT := (
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,-1,0,1,0,0,1,0,-1,0,0,-1,0,1,0,-1,1,0,-1,0,1,-1,0,1,0,-1,1,0,-1,0,1,-1,-1,1,0,-1,0,1,
	-1,0,1,0,-1,1,0,-1,0,1,-1,-1,1,0,-1,1,1,-1,0,1,-1,-1,1,0,-2,1,1,-1,-1,2,0,-2,1,1,-2,0,2,-1,-1,2,0,-2,1,2,-2,-1,2,-1,
	-2,2,1,-2,0,2,-2,-1,2,0,-3,2,2,-3,0,3,-1,-2,3,1,-3,1,3,-3,-1,3,-1,-3,2,2,-4,0,4,-2,-3,4,1,-4,2,3,-4,-1,5,-1,-4,4,2,-5,
	1,5,-4,-3,6,0,-6,3,4,-6,-1,7,-3,-6,6,2,-8,2,7,-7,-4,10,-2,-9,7,6,-11,0,12,-7,-9,14,2,-17,8,15,-18,-6,25,-8,-26,26,16,
	-45,8,63,-60,-74,265,512,265,-74,-60,63,8,-45,16,26,-26,-8,25,-6,-18,15,8,-17,2,14,-9,-7,12,0,-11,6,7,-9,-2,10,-4,-7,
	7,2,-8,2,6,-6,-3,7,-1,-6,4,3,-6,0,6,-3,-4,5,1,-5,2,4,-4,-1,5,-1,-4,3,2,-4,1,4,-3,-2,4,0,-4,2,2,-3,-1,3,-1,-3,3,1,-3,
	1,3,-2,-1,3,0,-3,2,2,-3,0,2,-1,-2,2,0,-2,1,2,-2,-1,2,-1,-2,2,1,-2,0,2,-1,-1,2,0,-2,1,1,-2,0,2,-1,-1,1,1,-2,0,1,-1,-1,
	1,0,-1,1,1,-1,0,1,-1,-1,1,0,-1,0,1,-1,0,1,0,-1,1,0,-1,0,1,-1,-1,1,0,-1,0,1,-1,0,1,0,-1,1,0,-1,0,1,-1,0,1,0,-1,0,0,-1,
	0,1,0,0,1,0,-1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

	
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
	signal fir_output    : std_logic_vector( Wout-1 downto 0);

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
