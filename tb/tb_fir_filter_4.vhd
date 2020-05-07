PACKAGE n_bit_int IS    -- User defined types
	SUBTYPE S8 IS INTEGER RANGE -128 TO 127;
	TYPE AS8 IS ARRAY (0 TO 3) OF S8;
	TYPE AS8_32 IS ARRAY (0 TO 31) OF S8;
END n_bit_int;
LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fir_filter_4 is
	generic( 
	Win			 : INTEGER 		:= 8;
	BUTTON_HIGH  : STD_LOGIC 	:= '0');
end tb_fir_filter_4;

architecture behave of tb_fir_filter_4 is

component fir_filter_4 
port (
	clk    : IN  STD_LOGIC	;  -- System clock
	reset  : IN  STD_LOGIC	;  -- Asynchron reset
	x 	   : IN  S8			;-- System input
	y  	   : OUT S8			);-- System output 
end component;

signal clk          : std_logic:='0';
signal reset        : std_logic:='0';
signal x         	: S8;
signal y        	: S8;
signal x_t			: std_logic_vector(Win-1 downto 0);

begin

clk   <= not clk after 5 ns;
reset  <= '0', '1' after 132 ns;

u_fir_filter_4 : fir_filter_4 
port map(
	clk         => clk        ,
	reset       => reset      ,
	x       	=> x      	  ,
	y  	   		=> y	  	  );

p_input : process (reset,clk)
variable control : unsigned(Win-1 downto 0):= (others=>'0');
--variable controlCoeff : unsigned(Win-1 downto 0):= (others=>'0');
begin
	if(reset='0') then
		x       <= 0;
	elsif(rising_edge(clk)) then
--		if(controlCoeff = LFilter) then
			if(control=10) then  -- delta
				--x_in       <= ('0',others=>'1');
				x_t  <=  ('0',others=>'1');
				x <=  to_integer(signed(x_t));
			elsif(control(7)='1') then  -- step
				--x_in       <= ('0',others=>'1');
				x_t  <=  ('0',others=>'1');
				x <=  to_integer(signed(x_t));
			else
				--x_in       <= (others=>'0');
				x_t  <=  (others=>'0');
				x <=  to_integer(signed(x_t));
			end if;
			control := control + 1;
--		else
--			controlCoeff := controlCoeff +1;
	end if;
end process p_input;


end behave;
