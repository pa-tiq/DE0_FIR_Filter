PACKAGE n_bit_int IS    -- User defined types
	SUBTYPE S8i IS INTEGER RANGE -128 TO 127;
	SUBTYPE S8o IS INTEGER RANGE -512 TO 511;
	TYPE AS8i IS ARRAY (0 TO 3) OF S8i;
	TYPE AS8i_32 IS ARRAY (0 TO 31) OF S8i;
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
	x 	   : IN  S8i			;-- System input
	y  	   : OUT S8o			);-- System output 
end component;

signal clk          : std_logic:='0';
signal reset        : std_logic:='0';
signal x         	: S8i;
signal y        	: S8o;
signal x_in			: std_logic_vector(Win-1 downto 0);

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
variable control : unsigned(10 downto 0):= (others=>'0');
--variable controlCoeff : unsigned(Win-1 downto 0):= (others=>'0');
begin
	if(reset='0') then
		x       <= 0;
		x_in    <= (others => '0');
	elsif(rising_edge(clk)) then
--		if(controlCoeff = LFilter) then
			if(control=10) then  -- delta
				x_in    <= ('0',others=>'1');
				x 		<=  to_integer(signed(x_in));
			elsif(control(7)='1') then  -- step
				x_in    <= ('0',others=>'1');
				x 		<=  to_integer(signed(x_in));
			--else
				--x_in       <= (others=>'0');
				--x <=  0;
			end if;
			control := control + 1;
--		else
--			controlCoeff := controlCoeff +1;
	end if;
end process p_input;


end behave;
