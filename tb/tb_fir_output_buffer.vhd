LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fir_output_buffer is
	generic( 
	Win : INTEGER := 7; -- Input bit width
	Wmult : INTEGER := 20;-- Multiplier bit width 2*W1
	Wadd : INTEGER := 28;-- Adder width = Wmult+log2(L)-1
	Wout : INTEGER := 9;-- Output bit width
	BUTTON_HIGH : STD_LOGIC := '0';
	LFilter  : INTEGER := 513); -- Filter length
end tb_fir_output_buffer;

architecture behave of tb_fir_output_buffer is

component fir_output_buffer 
port (
	i_clk                   : in  std_logic;
	i_rstb                  : in  std_logic;
	i_write_enable          : in  std_logic;
--	i_data                  : in  std_logic_vector( Wout-1 downto 0); -- from FIR
	i_data                  : in  S8 -- from FIR
	i_read_request          : in  std_logic;
	o_data                  : out std_logic_vector( Wout-1  downto 0); -- to seven segment
	o_test_add              : out std_logic_vector( 4 downto 0)); -- test read address
end component;

signal i_clk                   : std_logic:='0';
signal i_rstb                  : std_logic;
signal i_write_enable          : std_logic;
--signal i_data                  : std_logic_vector( Wout-1  downto 0); -- from FIR 
signal i_data                  : S8 -- from FIR 
signal i_read_request          : std_logic;
signal o_data                  : std_logic_vector( Wout-1  downto 0); -- to seven segment
signal o_test_add              : std_logic_vector( 4 downto 0); -- test read address

begin

i_clk   <= not i_clk after 5 ns;
i_rstb  <= '0', '1' after 132 ns;

u_fir_output_buffer : fir_output_buffer 
port map(
	i_clk                   => i_clk                   ,
	i_rstb                  => i_rstb                  ,
	i_write_enable          => i_write_enable          ,
	i_data                  => i_data                  ,
	i_read_request          => i_read_request          ,
	o_data                  => o_data                  ,
	o_test_add              => o_test_add              );
	
------------------------------------------------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------------------------------------------------

p_input : process (i_rstb,i_clk)
variable control            : unsigned(Win-1 downto 0):= (others=>'0');
variable controlCoeff       : unsigned(Win-1 downto 0):= (others=>'0');
begin
	if(i_rstb='0') then
		i_write_enable           <= '0';
		i_read_request           <= '0';
		i_data                   <= to_integer("0000000011");
	elsif(rising_edge(i_clk)) then
--		if(controlCoeff = LFilter)
			if(control>=10) and  (control<=60) then  -- step
				--i_data                   <= std_logic_vector(unsigned(i_data) + 1);
				i_data                   <= i_data + 1;
				i_write_enable           <= '1';
			else
				i_write_enable           <= '0';
			end if;
			control := control + 1;
			
			if(control>100)then
				i_read_request           <= control(3);
			else
				i_read_request           <= '0';
			end if;
--		else
--			controlCoeff := controlCoeff+1;
	end if;
end process p_input;


end behave;
