library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fir_filter_test is
	generic( 
		Win 			: INTEGER 	:= 9		; -- Input bit width
		Wmult			: INTEGER 	:= 18		;-- Multiplier bit width 2*W1
		Wadd 			: INTEGER 	:= 25		;-- Adder width = Wmult+log2(L)-1
		Wout 			: INTEGER 	:= 11		;-- Output bit width
		BUTTON_HIGH 	: STD_LOGIC := '0'		;
		PATTERN_SIZE	: INTEGER 	:= 32		;
		RANGE_LOW 		: INTEGER 	:= -256		; --pattern range: power of 2
		RANGE_HIGH 		: INTEGER 	:= 255		; --must change pattern too
		LFilter  		: INTEGER 	:= 256		); -- Filter length
end tb_fir_filter_test;

architecture behave of tb_fir_filter_test is

component fir_filter_test 
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
	clk                   	: in  std_logic;
	reset                  	: in  std_logic;
	i_pattern_sel           : in  std_logic;  -- '0'=> delta; '1'=> step
	i_start_generation      : in  std_logic;
	i_read_request          : in  std_logic;
	o_data_buffer           : out std_logic_vector( Wout-1 downto 0); -- to seven segment
	o_test_add              : out std_logic_vector( 4 downto 0)); -- test read address
end component;

signal clk                     : std_logic:='0';
signal reset                   : std_logic;
signal i_pattern_sel           : std_logic:='1';  -- '0'=> delta; '1'=> step
signal i_start_generation      : std_logic;
signal i_read_request          : std_logic;
signal o_data_buffer           : std_logic_vector( Wout-1 downto 0); -- to seven segment
signal o_test_add              : std_logic_vector( 4 downto 0); -- test read address

begin

clk   <= not clk after 5 ns;
reset  <= '0', '1' after 132 ns;

u_fir_filter_test : fir_filter_test
generic map( 
	Win 	   	 => Win			 ,
	Wmult 	   	 => Wmult		 ,
	Wadd 	   	 => Wadd		 ,
	Wout 	  	 => Wout		 ,
	LFilter 	 => LFilter		 ,
	RANGE_LOW 	 => RANGE_LOW	 ,
	RANGE_HIGH 	 => RANGE_HIGH	 ,
	BUTTON_HIGH  => BUTTON_HIGH	 ,
	PATTERN_SIZE => PATTERN_SIZE )
port map(
	clk              	 => clk                  ,
	reset                => reset                ,
	i_pattern_sel        => i_pattern_sel        ,
	i_start_generation   => i_start_generation   ,
	i_read_request       => i_read_request       ,
	o_data_buffer        => o_data_buffer        ,
	o_test_add           => o_test_add           );	

p_input : process (reset,clk)
variable control : unsigned(9 downto 0):= (others=>'0');
begin
	if(reset='0') then
		i_start_generation           <= '0';
	elsif(rising_edge(clk)) then
		if(control=10) then 
			i_start_generation       <= '1';
		else
			i_start_generation       <= '0';
		end if;
		control := control + 1;
		
		if(control>100)then
			i_read_request           <= control(3);
		else
			i_read_request           <= '0';
		end if;
	end if;
end process p_input;

end behave;

