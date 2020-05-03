library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_test is
	generic(
		Win : INTEGER := 10; -- Input bit width
		Wout : INTEGER := 12;-- Output bit width
		Lfilter : INTEGER := 513; --Filter Length
		RANGE_LOW : INTEGER := -512; --coeff range: power of 2
		RANGE_HIGH : INTEGER := 511);
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
	port (
		i_clk                   : in  std_logic;
		i_rstb                  : in  std_logic;
		i_pattern_sel           : in  std_logic;  -- '0'=> delta; '1'=> step
		i_start_generation      : in  std_logic;
		o_data                  : out std_logic_vector( Win-1 downto 0); -- to FIR 
		o_write_enable          : out std_logic);  -- to the output buffer
	end component;
	
	component fir_test_coeff_generator is
	port (
		clock                   : in  std_logic;
		reset                   : in  std_logic;
		start_generation        : in  std_logic;
		coeff                   : out std_logic_vector( Win-1 downto 0); 
		write_enable            : out std_logic);
	end component;

	component fir_filter_4 
	port (
		clock       : in  std_logic;
		reset       : in  std_logic;
		Load_x      : in  std_logic;  -- Load/run switch
		x_in        : in  std_logic_vector( Win-1 downto 0);
		c_in        : in  std_logic_vector( Win-1 downto 0);
		y_out       : out std_logic_vector( Wout-1 downto 0));
	end component;

	component fir_output_buffer 
	port (
		i_clk                   : in  std_logic;
		i_rstb                  : in  std_logic;
		i_write_enable          : in  std_logic;
		i_data                  : in  std_logic_vector( Wout-1 downto 0); -- from FIR 
		i_read_request          : in  std_logic;
		o_data                  : out std_logic_vector( Wout-1 downto 0); -- to seven segment
		o_test_add              : out std_logic_vector( 4 downto 0)); -- test read address
	end component;

	signal w_write_enable          : std_logic;
	signal w_data_test             : std_logic_vector( Win-1 downto 0);
	signal coeff           	       : std_logic_vector( Win-1 downto 0);
	signal w_data_filter           : std_logic_vector( Wout-1 downto 0);

begin

	u_fir_test_data_generator : fir_test_data_generator
	port map(
		i_clk                   => i_clk                   ,
		i_rstb                  => i_rstb                  ,
		i_pattern_sel           => i_pattern_sel           ,
		i_start_generation      => i_start_generation      ,
		o_data                  => w_data_test             ,
		o_write_enable          => w_write_enable          );	
		
	u_fir_test_coeff_generator : fir_test_coeff_generator
	port map(
		clock                 => i_clk                   ,
		reset                 => i_rstb                  ,
		coeff                 => coeff            		 ,
		write_enable          => w_write_enable          );	

	u_fir_filter_4 : fir_filter_4 
	port map(
		clk         => i_clk       		,
		reset       => i_rstb      	 	,
		Load_x		=> w_write_enable	,
		x_in        => w_data_test 		,
		c_in        => coeff 			,
		y_out       => w_data_filter	);

	u_fir_output_buffer : fir_output_buffer 
	port map(
		i_clk                   => i_clk                   ,
		i_rstb                  => i_rstb                  ,
		i_write_enable          => w_write_enable          ,
		i_data                  => w_data_filter           ,
		i_read_request          => i_read_request          ,
		o_data                  => o_data_buffer           ,
		o_test_add              => o_test_add              );

end rtl;
