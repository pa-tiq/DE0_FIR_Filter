LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_test is
	generic( 
		Win 			: INTEGER 	:= 9		; -- Input bit width
		Wmult			: INTEGER 	:= 18		;-- Multiplier bit width 2*W1
		Wadd 			: INTEGER 	:= 25		;-- Adder width = Wmult+log2(L)-1
		Wout 			: INTEGER 	:= 11		;-- Output bit width
		BUTTON_HIGH 	: STD_LOGIC := '0'		;
		PATTERN_SIZE	: INTEGER 	:= 32		;
		RANGE_LOW 		: INTEGER 	:= -512		; --pattern range: power of 2
		RANGE_HIGH 		: INTEGER 	:= 511		; --must change pattern too
		LFilter  		: INTEGER 	:= 256		); -- Filter length
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

	type T_COEFF_INPUT is array(0 to LFilter-1) of integer range RANGE_LOW to RANGE_HIGH;

	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--0,1,2,5,9,16,25,36,48,62,77,92,105,115,123,127,127,123,115,
	--105,92,77,62,48,36,25,16,9,5,2,1,0);


	-- L=256 RANGE -256 TO 255
	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--	0,0,0,0,0,0,-1,-1,-1,-1,-1,-2,-2,-2,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,
	--	-2,-2,-1,0,1,2,3,4,5,6,7,8,10,11,12,13,14,15,15,16,17,17,17,17,17,16,16,15,14,12,
	--	11,9,7,5,3,0,-3,-6,-9,-12,-15,-18,-21,-24,-27,-30,-33,-35,-38,-40,-42,-43,-45,-45,
	--	-46,-45,-45,-44,-42,-39,-37,-33,-29,-24,-19,-13,-7,0,8,16,24,33,42,52,62,73,83,94,
	--	105,116,127,137,148,159,169,179,188,197,206,214,221,228,234,240,244,248,251,253,255,
	--	255,253,251,248,244,240,234,228,221,214,206,197,188,179,169,159,148,137,127,116,105,
	--	94,83,73,62,52,42,33,24,16,8,0,-7,-13,-19,-24,-29,-33,-37,-39,-42,-44,-45,-45,-46,-45,
	--	-45,-43,-42,-40,-38,-35,-33,-30,-27,-24,-21,-18,-15,-12,-9,-6,-3,0,3,5,7,9,11,12,14,
	--	15,16,16,17,17,17,17,17,16,15,15,14,13,12,11,10,8,7,6,5,4,3,2,1,0,-1,-2,-2,-3,-3,-4,
	--	-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,-3,-2,-2,-2,-1,-1,-1,-1,-1,0,0,0,0,0,0);

	-- L=256 RANGE -512 TO 511
	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--	0,0,0,0,0,-1,-1,-1,-2,-2,-3,-4,-4,-5,-5,-6,-7,-7,-8,-8,-8,-8,-8,-8,-8,-8,-7,-6,-5,-4,-3,
	--	-2,0,2,4,6,8,10,12,15,17,19,22,24,26,28,29,31,32,33,34,34,34,34,33,31,30,27,25,22,18,14,
	--	10,5,0,-5,-11,-17,-23,-29,-36,-42,-48,-54,-60,-66,-71,-76,-80,-84,-87,-89,-91,-91,-91,
	--	-90,-87,-84,-79,-74,-67,-58,-49,-39,-27,-14,0,15,31,48,66,85,105,125,146,167,189,210,232,
	--	254,276,298,319,339,359,378,396,414,430,445,459,471,482,491,498,504,509,511,511,509,504,
	--	498,491,482,471,459,445,430,414,396,378,359,339,319,298,276,254,232,210,189,167,146,125,
	--	105,85,66,48,31,15,0,-14,-27,-39,-49,-58,-67,-74,-79,-84,-87,-90,-91,-91,-91,-89,-87,-84,
	--	-80,-76,-71,-66,-60,-54,-48,-42,-36,-29,-23,-17,-11,-5,0,5,10,14,18,22,25,27,30,31,33,34,
	--	34,34,34,33,32,31,29,28,26,24,22,19,17,15,12,10,8,6,4,2,0,-2,-3,-4,-5,-6,-7,-8,-8,-8,-8,
	--	-8,-8,-8,-8,-7,-7,-6,-5,-5,-4,-4,-3,-2,-2,-1,-1,-1,0,0,0,0,0);

	-- L=256 RANGE -512 TO 511
	constant COEFF_ARRAY : T_COEFF_INPUT := (
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,-1,0,0,1,0,-1,0,1,1,0,-1,-1,1,1,0,-1,-1,1,1,0,-1,-1,1,
		2,0,-2,-1,1,2,0,-2,-1,1,3,0,-3,-2,2,3,0,-3,-2,2,4,0,-4,-3,3,4,0,-5,-3,3,5,0,-6,-4,4,6,0,-7,-4,4,7,0,
		-8,-5,5,9,0,-10,-6,6,11,0,-12,-8,8,14,0,-15,-10,10,17,0,-19,-13,14,23,0,-27,-18,20,35,0,-43,-30,34,
		64,0,-97,-80,119,387,511,511,387,119,-80,-97,0,64,34,-30,-43,0,35,20,-18,-27,0,23,14,-13,-19,0,17,10,
		-10,-15,0,14,8,-8,-12,0,11,6,-6,-10,0,9,5,-5,-8,0,7,4,-4,-7,0,6,4,-4,-6,0,5,3,-3,-5,0,4,3,-3,-4,0,4,2,
		-2,-3,0,3,2,-2,-3,0,3,1,-1,-2,0,2,1,-1,-2,0,2,1,-1,-1,0,1,1,-1,-1,0,1,1,-1,-1,0,1,1,0,-1,0,1,0,0,-1,0,
		1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
	
	-- L=512 RANGE 256 TO 255
	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--	0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,-3,
	--	-3,-3,-3,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,
	--	-4,-3,-3,-3,-3,-2,-2,-2,-2,-1,-1,0,0,0,1,1,2,2,3,3,4,4,5,6,6,7,7,8,8,9,10,
	--	10,11,11,12,12,13,13,14,14,15,15,15,16,16,16,17,17,17,17,17,17,17,17,17,17,
	--	16,16,16,15,15,14,14,13,12,12,11,10,9,8,7,6,5,4,3,1,0,-1,-3,-4,-6,-7,-9,-10,
	--	-12,-13,-15,-16,-18,-19,-21,-23,-24,-26,-27,-29,-30,-31,-33,-34,-35,-37,-38,
	--	-39,-40,-41,-42,-43,-43,-44,-45,-45,-45,-45,-46,-46,-45,-45,-45,-44,-44,-43,
	--	-42,-41,-40,-38,-37,-35,-33,-31,-29,-27,-24,-22,-19,-16,-13,-10,-7,-4,0,4,8,
	--	11,16,20,24,28,33,38,42,47,52,57,62,67,73,78,83,89,94,99,105,110,116,121,127,
	--	132,137,143,148,153,159,164,169,174,179,184,188,193,197,202,206,210,214,218,
	--	222,225,228,231,234,237,240,242,244,246,248,250,251,252,253,254,255,255,255,
	--	255,254,253,252,251,250,248,246,244,242,240,237,234,231,228,225,222,218,214,
	--	210,206,202,197,193,188,184,179,174,169,164,159,153,148,143,137,132,127,121,
	--	116,110,105,99,94,89,83,78,73,67,62,57,52,47,42,38,33,28,24,20,16,11,8,4,0,
	--	-4,-7,-10,-13,-16,-19,-22,-24,-27,-29,-31,-33,-35,-37,-38,-40,-41,-42,-43,-44,
	--	-44,-45,-45,-45,-46,-46,-45,-45,-45,-45,-44,-43,-43,-42,-41,-40,-39,-38,-37,
	--	-35,-34,-33,-31,-30,-29,-27,-26,-24,-23,-21,-19,-18,-16,-15,-13,-12,-10,-9,-7,
	--	-6,-4,-3,-1,0,1,3,4,5,6,7,8,9,10,11,12,12,13,14,14,15,15,16,16,16,17,17,17,17,
	--	17,17,17,17,17,17,16,16,16,15,15,15,14,14,13,13,12,12,11,11,10,10,9,8,8,7,7,6,
	--	6,5,4,4,3,3,2,2,1,1,0,0,0,-1,-1,-2,-2,-2,-2,-3,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,
	--	-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,-3,-3,-3,-3,-3,-2,-2,-2,-2,-2,-2,-1,-1,
	--	-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0);
	


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
	
	component fir_filter 
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
	
	u_fir_filter : fir_filter
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
