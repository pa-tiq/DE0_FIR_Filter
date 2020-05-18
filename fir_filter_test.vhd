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
		clk                  	: in  std_logic;
		reset                   : in  std_logic;
		i_pattern_sel           : in  std_logic;  -- '0'=> delta; '1'=> step
		i_start_generation      : in  std_logic;
		i_read_request          : in  std_logic;
		o_data_buffer           : out std_logic_vector( Wout-1 downto 0); -- to seven segment
		o_test_add              : out std_logic_vector( 4 downto 0)); -- test read address
end fir_filter_test;

architecture rtl of fir_filter_test is

	type T_COEFF_INPUT is array(0 to LFilter-1) of integer range 0 to 127;

	constant COEFF_ARRAY : T_COEFF_INPUT := (
	0,1,2,5,9,16,25,36,48,62,77,92,105,115,123,127,127,123,115,105,92,
	77,62,48,36,25,16,9,5,2,1,0);
	
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

begin

	p_coeff : process (reset,clk)
		variable first_time : std_logic := '0';
	begin
		if(first_time='0' and reset /= BUTTON_HIGH) then
			if(rising_edge(clk)) then
				for k in 0 to Lfilter-1 loop
					coeff(k)  <=  std_logic_vector(to_signed(COEFF_ARRAY(k),Win));
				end loop;			
				first_time := '1';
			end if;
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
		o_data     	=> w_data_filter	);

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
