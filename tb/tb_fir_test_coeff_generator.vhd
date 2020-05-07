library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fir_test_coeff_generator is
		generic(
		Win : INTEGER := 10; -- Input bit width
		Lfilter  : INTEGER := 513; -- Filter length (ALWAYS ODD: order+1)
		BUTTON_HIGH : STD_LOGIC := '0';
		RANGE_LOW : INTEGER := -512; --coeff range: power of 2
		RANGE_HIGH : INTEGER := 511);
end tb_fir_test_coeff_generator;

architecture behave of tb_fir_test_coeff_generator is

component fir_test_data_generator 
port (
	clock                   : in  std_logic			;
	reset                   : in  std_logic			;
	i_pattern_sel           : in  std_logic			;  -- '0'=> delta; '1'=> step
	start_generation      	: in  std_logic			;
	o_data                  : out std_logic_vector( 7 downto 0); -- to FIR 
	write_enable          	: out std_logic			);  -- to the output buffer
end component;

--component fir_test_coeff_generator 
--port (
--		clock                   : in  std_logic;
--		reset                   : in  std_logic;
--		start_generation        : in  std_logic;
--		coeff                   : out std_logic_vector( Win-1 downto 0); 
--		write_enable            : out std_logic);
--end component;

signal i_pattern_sel           : std_logic;  -- '0'=delta; '1'=step

--signal coeff                   : std_logic_vector( Win-1 downto 0);
signal clock                   : std_logic:='0';
signal reset                   : std_logic;
signal start_generation        : std_logic;
signal write_enable            : std_logic;

begin

	clock   <= not clock after 5 ns;
	reset  <= '0', '1' after 132 ns;

	u_fir_test_coeff_generator : fir_test_coeff_generator
	port map(
		clock                 => clock                 ,
		reset                 => reset                 ,
		start_generation      => start_generation      ,
		coeff                 => coeff            	   ,
		write_enable          => write_enable          );
		
	-- FIR delta input, step input

	p_input : process (reset,clock)
	begin
		if(reset=BUTTON_HIGH) then
			start_generation      <= '0';
		elsif(rising_edge(clock)) then
			start_generation      <= '1';
		end if;
	end process p_input;

end behave;
