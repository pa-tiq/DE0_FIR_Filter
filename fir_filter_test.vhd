
LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_test is
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
		clk              	  : in  std_logic;
		reset                 : in  std_logic;
		i_pattern_sel         : in  std_logic;  -- '0'=> delta; '1'=> step
		i_start_generation    : in  std_logic;
		i_read_request        : in  std_logic;
		o_data_buffer         : out std_logic_vector( Wout-1 downto 0); -- to seven segment
		o_test_add            : out std_logic_vector( Win-1 downto 0)); -- test read address
end fir_filter_test;

architecture rtl of fir_filter_test is

	type T_COEFF_INPUT is array(0 to LFilter-1) of integer range RANGE_LOW to RANGE_HIGH;

	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--0,1,2,5,9,16,25,36,48,62,77,92,105,115,123,127,127,123,115,
	--105,92,77,62,48,36,25,16,9,5,2,1,0);

	--L=256
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

	-- L=512 RANGE -512 TO 511 (BLACKMAN) b=0.01
	constant COEFF_ARRAY : T_COEFF_INPUT := (
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-3,-3,-3,-3,-4,-4,-5,-5,-5,-6,-6,-7,-7,-8,-8,-9,-9,-10,-10,-11,-11,-12,-12,-13,-14,-14,-15,-16,-16,-17,-18,-18,-19,-20,-21,-21,-22,-23,-23,-24,-25,-25,-26,-27,-27,-28,-29,-29,-30,-30,-31,-31,-32,-32,-32,-33,-33,-33,-34,-34,-34,-34,-34,-34,-33,-33,-33,-33,-32,-32,-31,-30,-29,-29,-28,-27,-25,-24,-23,-21,-20,-18,-16,-14,-12,-10,-8,-6,-3,0,2,5,8,11,15,18,22,25,29,33,37,41,46,50,55,59,64,69,74,79,85,90,96,101,107,113,119,125,131,138,144,151,157,164,171,178,184,191,198,206,213,220,227,234,242,249,256,264,271,278,286,293,300,307,315,322,329,336,343,350,357,364,370,377,384,390,396,403,409,415,421,426,432,437,443,448,453,457,462,466,471,475,478,482,485,489,492,495,497,500,502,504,505,507,508,509,510,511,511,511,511,510,509,508,507,505,504,502,500,497,495,492,489,485,482,478,475,471,466,462,457,453,448,443,437,432,426,421,415,409,403,396,390,384,377,370,364,357,350,343,336,329,322,315,307,300,293,286,278,271,264,256,249,242,234,227,220,213,206,198,191,184,178,171,164,157,151,144,138,131,125,119,113,107,101,96,90,85,79,74,69,64,59,55,50,46,41,37,33,29,25,22,18,15,11,8,5,2,0,-3,-6,-8,-10,-12,-14,-16,-18,-20,-21,-23,-24,-25,-27,-28,-29,-29,-30,-31,-32,-32,-33,-33,-33,-33,-34,-34,-34,-34,-34,-34,-33,-33,-33,-32,-32,-32,-31,-31,-30,-30,-29,-29,-28,-27,-27,-26,-25,-25,-24,-23,-23,-22,-21,-21,-20,-19,-18,-18,-17,-16,-16,-15,-14,-14,-13,-12,-12,-11,-11,-10,-10,-9,-9,-8,-8,-7,-7,-6,-6,-5,-5,-5,-4,-4,-3,-3,-3,-3,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	);
	
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
		o_test_add              : out std_logic_vector( Win-1 downto 0)); -- test read address
	end component;

	signal w_write_enable  : std_logic;
	signal w_data_test     : std_logic_vector( Win-1 downto 0);	
	signal coeff           : ARRAY_COEFF(0 to Lfilter-1);
	--signal w_data_filter   : std_logic_vector( Wout-1 downto 0);
	--signal fir_output      : std_logic_vector( Wout-1 downto 0);

	type state_type is(ST_RESET, ST_LOAD_COEFF, ST_CONTINUE);
	signal state	   : state_type := ST_RESET;
	signal next_state  : state_type ;
	signal IsStartup : std_logic := '1';

begin

	--w_data_filter <= fir_output;

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
	--	o_data     	=> fir_output		);
		o_data     	=> o_data_buffer		);

	--u_fir_output_buffer : fir_output_buffer 
	--generic map( 
	--	Win 		 => Win				, -- Input bit width
	--	Wout 		 => Wout			,-- Output bit width
	--	BUTTON_HIGH  => BUTTON_HIGH		,
	--	PATTERN_SIZE => PATTERN_SIZE	,
	--	RANGE_LOW	 => RANGE_LOW		, 
	--	RANGE_HIGH 	 => RANGE_HIGH		,
	--	LFilter  	 => LFilter			) -- Filter length
	--port map(
	--	i_clk               => clk                ,
	--	i_rstb              => reset              ,
	--	i_write_enable      => w_write_enable     ,
	--	i_data              => fir_output         ,
	--	i_read_request      => i_read_request     ,
	--	o_data              => o_data_buffer      ,
	--	o_test_add          => o_test_add         );

end rtl;
