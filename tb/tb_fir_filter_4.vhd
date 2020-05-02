library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fir_filter_4 is
	generic( 
	Win : INTEGER := 10; -- Input bit width
	Wmult : INTEGER := 20;-- Multiplier bit width 2*W1
	Wadd : INTEGER := 28;-- Adder width = Wmult+log2(L)-1
	Wout : INTEGER := 12;-- Output bit width
	BUTTON_HIGH : STD_LOGIC := '0';
	LFilter  : INTEGER := 513); -- Filter length
end tb_fir_filter_4;

architecture behave of tb_fir_filter_4 is

component fir_filter_4 
port (
	clk    : IN STD_LOGIC;  -- System clock
	reset  : IN STD_LOGIC;  -- Asynchron reset
	Load_x : IN  STD_LOGIC;  -- Load/run switch
	x_in   : IN  STD_LOGIC_VECTOR(Win-1 DOWNTO 0);-- System input
	c_in   : IN  STD_LOGIC_VECTOR(Win-1 DOWNTO 0);-- Coefficient data input
	y_out  : OUT STD_LOGIC_VECTOR(Wout-1 DOWNTO 0));-- System output 
end component;

signal clk          : std_logic:='0';
signal reset        : std_logic:='0';
signal Load_x       : std_logic:='0';
signal x_in         : std_logic_vector( Win-1 downto 0);
signal c_in         : std_logic_vector( Win-1 downto 0);
signal y_out        : std_logic_vector( Wout-1 downto 0);

begin

clk   <= not clk after 5 ns;
reset  <= '0', '1' after 132 ns;

u_fir_filter_4 : fir_filter_4 
port map(
	clk         => clk        ,
	reset       => reset      ,
	Load_x      => Load_x     ,
	x_in        => x_in       ,
	c_in        => c_in       ,
	y_out  	    => y_out	  );

p_input : process (reset,clk)
variable control : unsigned(Win-1 downto 0):= (others=>'0');
variable controlCoeff : unsigned(Win-1 downto 0):= (others=>'0');
begin
	if(reset=BUTTON_HIGH) then
		x_in       <= (others=>'0');
	elsif(rising_edge(clk)) then
		if(controlCoeff = LFilter) then
			if(control=10) then  -- delta
				x_in       <= ('0',others=>'1');
			elsif(control(7)='1') then  -- step
				x_in       <= ('0',others=>'1');
			else
				x_in       <= (others=>'0');
			end if;
			control := control + 1;
		else
			controlCoeff := controlCoeff +1;
	end if;
end process p_input;


end behave;
