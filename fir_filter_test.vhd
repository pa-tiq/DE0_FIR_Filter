library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--PACKAGE n_bit_int IS    -- User defined types
--	SUBTYPE S8i IS INTEGER RANGE -128 TO 127;
--	SUBTYPE S8o IS INTEGER RANGE -512 TO 511;
--	TYPE AS8 IS ARRAY (0 TO 3) OF S8;
--	TYPE AS8_32 IS ARRAY (0 TO 31) OF S8;
--END n_bit_int;

PACKAGE n_bit_int IS
	SUBTYPE COEFF_TYPE IS STD_LOGIC_VECTOR(7 DOWNTO 0)	; --Win-1
	TYPE ARRAY_COEFF IS ARRAY (0 TO 3) OF COEFF_TYPE; --LFilter-1
END n_bit_int;

LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_test is
	generic(
		Win 		: INTEGER	; -- Input bit width
		Wmult 		: INTEGER	;-- Multiplier bit width 2*W1
		Wadd 		: INTEGER	;-- Adder width = Wmult+log2(L)-1
		Wout 		: INTEGER	;-- Output bit width
		Lfilter 	: INTEGER	; --Filter Length
		RANGE_LOW 	: INTEGER	; --coeff range: power of 2
		RANGE_HIGH 	: INTEGER	;
		BUTTON_HIGH : STD_LOGIC ;
		PATTERN_SIZE: INTEGER   );
	port (
		i_clk                   : in  std_logic;
		i_rstb                  : in  std_logic;
		i_pattern_sel           : in  std_logic;  -- '0'=> delta; '1'=> step
		i_start_generation      : in  std_logic;
		i_read_request          : in  std_logic;
		o_data_buffer           : out std_logic_vector( Wout-1 downto 0); -- to seven segment
		o_test_add              : out std_logic_vector( 4 downto 0)); -- test read address
end fir_filter_test;

architecture rtl of fir_filter_test is	
	
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
		--o_data                  : out std_logic_vector( Win-1 downto 0); -- to FIR 
		o_data 					: out integer range RANGE_LOW to RANGE_HIGH;
		o_write_enable          : out std_logic);  -- to the output buffer
	end component;
	
--	component fir_test_coeff_generator is
--	generic(
--		Win 		: INTEGER 	 ; -- Input bit width
--		BUTTON_HIGH : STD_LOGIC  ;
--		Lfilter  	: INTEGER 	 ; -- Filter length (ALWAYS ODD: order+1)
--		RANGE_LOW 	: INTEGER 	 ; --coeff range: power of 2
--		RANGE_HIGH 	: INTEGER 	 );
--	port (
--		clock                   : in  std_logic;
--		reset                   : in  std_logic;
--		start_generation        : in  std_logic;
--		coeff                   : out std_logic_vector( Win-1 downto 0); 
--		write_enable            : out std_logic);
--	end component;

--	component fir_filter_4 
--	generic( 
--		Win 		: INTEGER	; -- Input bit width
--		Wmult 		: INTEGER	;-- Multiplier bit width 2*W1
--		Wadd 		: INTEGER	;-- Adder width = Wmult+log2(L)-1
--		Wout 		: INTEGER	;-- Output bit width
--		BUTTON_HIGH : STD_LOGIC	;
--		LFilter  	: INTEGER	); -- Filter length
--	port (
--		clock       : in  std_logic;
--		reset       : in  std_logic;
--		Load_x      : in  std_logic;  -- Load/run switch
--		x_in        : in  std_logic_vector( Win-1 downto 0);
--		c_in        : in  std_logic_vector( Win-1 downto 0);
--		y_out       : out std_logic_vector( Wout-1 downto 0));
--	end component;
	
	component fir_filter_4 
	generic( 
--		Win 		: INTEGER	; -- Input bit width
--		Wmult 		: INTEGER	;-- Multiplier bit width 2*W1
--		Wadd 		: INTEGER	;-- Adder width = Wmult+log2(L)-1
--		Wout 		: INTEGER	;-- Output bit width
--		LFilter  	: INTEGER	;--Filter Length
		BUTTON_HIGH : STD_LOGIC	);
	port (
		clk       	: in  std_logic;
		reset       : in  std_logic;
		x       	: IN  S8i;
		y       	: OUT S8o);
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
		i_clk                   : in  std_logic;
		i_rstb                  : in  std_logic;
		i_write_enable          : in  std_logic;
		i_data                  : in  S8o; -- from FIR 
		i_read_request          : in  std_logic;
		--o_data                  : out std_logic_vector( Wout-1 downto 0); -- to seven segment
		o_data                  : out std_logic_vector( Wout-1 downto 0); -- to seven segment
		o_test_add              : out std_logic_vector( 4 downto 0)); -- test read address
	end component;

	--signal w_data_test             : std_logic_vector( Win-1 downto 0);	
	--signal coeff           	     : std_logic_vector( Win-1 downto 0);
	--signal w_data_filter           : std_logic_vector( Wout-1 downto 0);

	signal w_write_enable          : std_logic;
	signal w_data_test             : S8i;
	signal w_data_filter           : S8o;

begin

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
		i_clk                   => i_clk                   ,
		i_rstb                  => i_rstb                  ,
		i_pattern_sel           => i_pattern_sel           ,
		i_start_generation      => i_start_generation      ,
		o_data                  => w_data_test             ,
		o_write_enable          => w_write_enable          );	
		
--	u_fir_test_coeff_generator : fir_test_coeff_generator
--	generic map(
--		Win 		 =>  Win 		  	;
--		BUTTON_HIGH  =>	 BUTTON_HIGH 	;
--		LFilter  	 =>	 LFilter  		;
--		RANGE_LOW  	 =>	 RANGE_LOW  	;
--		RANGE_HIGH   =>	 RANGE_HIGH  	);
--	port map(
--		clock                 => i_clk                   ,
--		reset                 => i_rstb                  ,
--		coeff                 => coeff            		 ,
--		write_enable          => w_write_enable          );	

--	u_fir_filter_4 : fir_filter_4
--	generic map(
--		Win 		 =>  Win 		  	;
--		Wmult 		 =>	 Wmult 			;
--		Wadd 		 =>	 Wadd 			;
--		Wout 		 =>	 Wout 			;
--		BUTTON_HIGH  =>	 BUTTON_HIGH 	;
--		LFilter  	 =>	 LFilter  		);
--	port map(
--		clk         => i_clk       		,
--		reset       => i_rstb      	 	,
--		Load_x		=> w_write_enable	,
--		x_in        => w_data_test 		,
--		c_in        => coeff 			,
--		y_out       => w_data_filter	);

	u_fir_filter_4 : fir_filter_4
	generic map(
		BUTTON_HIGH  =>	 BUTTON_HIGH)
	port map(
		clk         => i_clk       		,
		reset       => i_rstb      	 	,
		x      		=> w_data_test 		,
		y       	=> w_data_filter	);

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
		i_clk                   => i_clk                   ,
		i_rstb                  => i_rstb                  ,
		i_write_enable          => w_write_enable          ,
		i_data                  => w_data_filter           ,
		i_read_request          => i_read_request          ,
		o_data                  => o_data_buffer           ,
		o_test_add              => o_test_add              );

end rtl;
