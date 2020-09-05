LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter is
	generic ( 
		Win 			: INTEGER 	;-- Input bit width
		Wmult			: INTEGER 	;-- Multiplier bit width 2*Win
		Wadd 			: INTEGER 	;-- Adder width = Wmult+log2(L)-1
		Wout 			: INTEGER 	;-- Output bit width: between Win and Wadd
		BUTTON_HIGH 	: STD_LOGIC ;
		LFilter  		: INTEGER 	); -- Filter length
port (
	clk      : in  std_logic							;
	reset    : in  std_logic							;
--	i_coeff  : in  ARRAY_COEFF							;
	i_data   : in  std_logic_vector( Win-1 	downto 0)	;
	o_data   : out std_logic_vector( Wout-1 downto 0)   );
end fir_filter;

architecture rtl of fir_filter is

component ram_fir 
	PORT
	(
		address	: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock	: IN  STD_LOGIC ;
		data	: IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
		wren	: IN  STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
end component;

signal address_sig  : STD_LOGIC_VECTOR (7 DOWNTO 0);
signal data_sig		: STD_LOGIC_VECTOR (9 DOWNTO 0) := (others => '0');
signal wren_sig		: STD_LOGIC := '0';
signal q_sig		: STD_LOGIC_VECTOR (9 DOWNTO 0);

type t_data    is array (0 to Lfilter-1) 	 of signed(Win-1   downto 0);
type t_mult    is array (0 to Lfilter-1) 	 of signed(Wmult-1 downto 0);
type t_add_st0 is array (0 to (LFilter/2)-1) of signed(Wadd-1  downto 0);

--signal coeff     : t_data				;
signal data      : t_data				;
signal mult      : t_mult				;
signal add_st0   : t_add_st0			;
signal add_st1   : signed(Wadd downto 0);

begin

	ram_fir_inst : ram_fir PORT MAP (
		address	 => address_sig,
		clock	 => clk,
		data	 => data_sig,
		wren	 => wren_sig,
		q		 => q_sig
	);
		
	p_input : process (reset,clk)
		--variable control  	: unsigned(7 downto 0):= (others=>'0');
	begin
		if(reset=BUTTON_HIGH) then
			data   		<= (others=>(others=>'0'));
			--coeff  		<= (others=>(others=>'0'));			
			--data_sig	<= (others=>'0');
			--control 	:= (others=>'0');
		elsif(rising_edge(clk)) then
			data <= signed(i_data)&data(0 to data'length-2);
			--for k in 0 to Lfilter-1 loop
			--	coeff(k)  <= signed(q_sig);
			--	control := control + 1;
			--	address_sig <= std_logic_vector(control);
			--end loop;				  
		end if;
	end process p_input;

	p_mult : process (reset,clk)
	begin
		if(reset=BUTTON_HIGH) then
			mult <= (others=>(others=>'0'));
			address_sig <= (others=>'0');
		elsif(rising_edge(clk)) then
			for k in 0 to Lfilter-1 loop
				address_sig <= std_logic_vector(to_unsigned(k, address_sig'length));
				mult(k) <= data(k) * signed(q_sig);
			end loop;
		end if;
	end process p_mult;

	p_add_st0 : process (reset,clk)
	begin
		if(reset=BUTTON_HIGH) then
			add_st0 <= (others=>(others=>'0'));
		elsif(rising_edge(clk)) then
			for k in 0 to (LFilter/2)-1 loop
				add_st0(k) <= resize(mult(2*k),Wadd)  + resize(mult(2*k+1),Wadd);
			end loop;
		end if;
	end process p_add_st0;

	p_add_st1 : process (reset,clk)
		variable add_temp  : signed(Wadd downto 0);
	begin
		add_temp := (others=>'0');
		if(reset=BUTTON_HIGH) then
			add_st1  <= (others=>'0');
		elsif(rising_edge(clk)) then			
			for k in 0 to (LFilter/2)-1 loop
				add_temp := resize(add_st0(k),Wadd+1) + add_temp;
			end loop;
			add_st1 <= add_temp;					
		end if;
	end process p_add_st1;

	p_output : process (reset,clk)
	begin
		if(reset=BUTTON_HIGH) then
			o_data  <= (others=>'0');
		elsif(rising_edge(clk)) then
			o_data  <= std_logic_vector(add_st1(Wadd downto (Wadd-(o_data'length-1))));
			--divide = shift right		
		end if;
	end process p_output;

end rtl;