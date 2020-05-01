library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_test_coeff_generator is
	generic(
		Win : INTEGER := 10; -- Input bit width
		Lfilter  : INTEGER := 513; -- Filter length (ALWAYS ODD: order+1)
		BUTTON_HIGH : STD_LOGIC := '0';
		RANGE_LOW : INTEGER := -512; --coeff range: power of 2
		RANGE_HIGH : INTEGER := 511);
	port (
		clock                   : in  std_logic;
		reset                   : in  std_logic;
		start_generation        : in  std_logic;
		coeff                   : out std_logic_vector( Win-1 downto 0); 
		write_enable            : out std_logic);
	end fir_test_data_generator;

architecture rtl of fir_test_coeff_generator is

	type COEFFICIENT_ARRAY is array(0 to Lfilter-1) of integer range RANGE_LOW to RANGE_HIGH

	constant COEFFICIENTS  : COEFFICIENT_ARRAY := (
	-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-381,-382,-382,-381,-382,-382,-381,-382,-383,-382,-381,-382,-382,-381,-382,-383,-382,-381,-383,-382,-381,-382,-383,-381,-382,-383,-382,-381,-383,-382,-381,-382,-383,-381,-381,-383,-382,-381,-383,-383,-381,-382,-383,-381,-381,-383,-382,-380,-382,-383,-381,-381,-384,-382,-380,-383,-383,-380,-382,-384,-381,-381,-384,-382,-380,-383,-384,-380,-381,-384,-382,-380,-383,-383,-380,-382,-384,-381,-380,-384,-382,-379,-383,-384,-380,-381,-385,-381,-380,-384,-383,-379,-382,-385,-380,-380,-385,-382,-379,-384,-384,-379,-382,-385,-380,-379,-385,-383,-378,-383,-385,-379,-380,-386,-381,-378,-385,-384,-378,-382,-386,-379,-379,-386,-383,-377,-384,-386,-377,-381,-387,-380,-377,-386,-384,-376,-383,-387,-378,-379,-388,-382,-376,-386,-386,-375,-381,-389,-379,-376,-389,-384,-374,-384,-389,-375,-378,-391,-380,-373,-388,-387,-372,-382,-392,-376,-375,-393,-384,-370,-387,-392,-371,-378,-396,-378,-369,-394,-389,-365,-385,-398,-369,-371,-402,-382,-360,-395,-398,-358,-378,-412,-369,-356,-413,-393,-338,-396,-427,-336,-354,-461,-368,-273,-487,-512,80,512,80,-512,-487,-273,-368,-461,-354,-336,-427,-396,-338,-393,-413,-356,-369,-412,-378,-358,-398,-395,-360,-382,-402,-371,-369,-398,-385,-365,-389,-394,-369,-378,-396,-378,-371,-392,-387,-370,-384,-393,-375,-376,-392,-382,-372,-387,-388,-373,-380,-391,-378,-375,-389,-384,-374,-384,-389,-376,-379,-389,-381,-375,-386,-386,-376,-382,-388,-379,-378,-387,-383,-376,-384,-386,-377,-380,-387,-381,-377,-386,-384,-377,-383,-386,-379,-379,-386,-382,-378,-384,-385,-378,-381,-386,-380,-379,-385,-383,-378,-383,-385,-379,-380,-385,-382,-379,-384,-384,-379,-382,-385,-380,-380,-385,-382,-379,-383,-384,-380,-381,-385,-381,-380,-384,-383,-379,-382,-384,-380,-381,-384,-382,-380,-383,-383,-380,-382,-384,-381,-380,-384,-383,-380,-382,-384,-381,-381,-384,-382,-380,-383,-383,-380,-382,-384,-381,-381,-383,-382,-380,-382,-383,-381,-381,-383,-382,-381,-383,-383,-381,-382,-383,-381,-381,-383,-382,-381,-382,-383,-381,-382,-383,-382,-381,-383,-382,-381,-382,-383,-381,-382,-383,-382,-381,-382,-382,-381,-382,-383,-382,-381,-382,-382,-381,-382,-382,-381,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382,-382);

	signal r_write_counter             : integer range 0 to Lfilter-1; 
	signal r_write_counter_ena         : std_logic;

begin

	p_write_counter : process (reset,clock)
	begin
		if(reset=BUTTON_HIGH) then
			r_write_counter             <= Lfilter;
			r_write_counter_ena         <= '0';
		elsif(rising_edge(clock)) then
			elsif(r_write_counter<Lfilter) then
				r_write_counter             <= r_write_counter + 1;
				r_write_counter_ena         <= '1';
			else
				r_write_counter_ena         <= '0';
			end if;
		end if;
	end process p_write_counter;

	p_output : process (reset,clock)
	begin
		if(reset=BUTTON_HIGH) then
			coeff          <= (others=>'0');
			write_enable  <= '0';
		elsif(rising_edge(clock)) then
			write_enable  <= r_write_counter_ena;
			coeff     <= std_logic_vector(to_signed(COEFFICIENTS(r_write_counter),Win));
			end if;		
		end if;
	end process p_output;

end rtl;
