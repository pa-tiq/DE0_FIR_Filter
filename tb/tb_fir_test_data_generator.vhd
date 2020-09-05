LIBRARY work;
USE work.n_bit_int.ALL;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fir_test_data_generator is
	generic( 
		Win 			: INTEGER 	:= 10		;-- Input bit width
		Wmult			: INTEGER 	:= 20    	;-- Multiplier bit width 2*Win
		Wadd 			: INTEGER 	:= 28		;-- Adder width = Wmult+log2(L)-1
		Wout 			: INTEGER 	:= 28		;-- Output bit width: between Win and Wadd
		BUTTON_HIGH 	: STD_LOGIC := '0'		;
		PATTERN_SIZE	: INTEGER 	:= 256		;
		RANGE_LOW 		: INTEGER 	:= -512		; --pattern range: power of 2
		RANGE_HIGH 		: INTEGER 	:= 511		; --must change pattern too
		LFilter  		: INTEGER 	:= 512		); -- Filter length
	end tb_fir_test_data_generator;

architecture behave of tb_fir_test_data_generator is

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


signal i_clk                   : std_logic:='0';
signal i_rstb                  : std_logic;
-- coefficient
signal i_pattern_sel           : std_logic;  -- '0'=> delta; '1'=> step
signal i_start_generation      : std_logic;
-- data input
signal o_data                  : std_logic_vector( Win-1 downto 0); -- to FIR 
-- filtered data 
signal o_write_enable          : std_logic;  -- to the output buffer

begin

	i_clk   <= not i_clk after 5 ns;
	i_rstb  <= '0', '1' after 132 ns;

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
		o_data                  => o_data                  ,
		o_write_enable          => o_write_enable          );

	------------------------------------------------------------------------------------------------------------------------
	-- FIR delta input, step input
	------------------------------------------------------------------------------------------------------------------------

	p_input : process (i_rstb,i_clk)
	variable control   : unsigned(8 downto 0):= (others=>'0');
	begin
		if(i_rstb='0') then
			i_pattern_sel           <= '0';
			i_start_generation      <= '0';
		elsif(rising_edge(i_clk)) then
			if(control=10) then  -- step
				i_pattern_sel           <= '1';
				i_start_generation      <= '1';
			elsif(control=100) then  -- delta
				i_pattern_sel           <= '0';
				i_start_generation      <= '1';
			else
				i_start_generation      <= '0';
			end if;
			control := control + 1;
		end if;
	end process p_input;

end behave;
