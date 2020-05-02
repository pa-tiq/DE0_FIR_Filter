-- ******************************************************************** 
-- ******************************************************************** 
-- 
-- Coding style summary:
--
--	i_   Input signal 
--	o_   Output signal 
--	b_   Bi-directional signal 
--	r_   Register signal 
--	w_   Wire signal (no registered logic) 
--	t_   User-Defined Type 
--	p_   pipe
--  pad_ PAD used in the top level
--	G_   Generic (UPPER CASE)
--	C_   Constant (UPPER CASE)
--  ST_  FSM state definition (UPPER CASE)
--
-- ******************************************************************** 
--
-- Copyright ©2015 SURF-VHDL
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- ******************************************************************** 
--
-- Fle Name: tb_fir_filter_4.vhd
-- 
-- scope: test bench for 4 taps fir filter
--
-- rev 1.00
-- 
-- ******************************************************************** 
-- ******************************************************************** 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fir_filter_4 is
		generic(
		Win : INTEGER := 10; -- Input bit width
		Wout : INTEGER := 12;-- Output bit width
		BUTTON_HIGH : STD_LOGIC := '0';
		Lfilter : INTEGER := 513; --Filter Length
		RANGE_LOW : INTEGER := -512; --coeff range: power of 2
		RANGE_HIGH : INTEGER := 511);
end tb_fir_filter_4;

architecture behave of tb_fir_filter_4 is

component fir_filter_4 
port (
	i_clk        : in  std_logic;
	reset       : in  std_logic;
	-- coefficient
	c_in    : in  std_logic_vector( Win-1 downto 0);
	-- data input
	x_in       : in  std_logic_vector(  Win-1 downto 0);
	-- filtered data 
	y_out       : out std_logic_vector( Wout-1 downto 0));
end component;

	component fir_filter_4 
	port (
		clk       : in  std_logic;
		reset       : in  std_logic;
		Load_x      : in  std_logic;  -- Load/run switch
		x_in        : in  std_logic_vector( Win-1 downto 0);
		c_in        : in  std_logic_vector( Win-1 downto 0);
		y_out       : out std_logic_vector( Wout-1 downto 0));
	end component;


signal clk        : std_logic:='0';
signal reset        : std_logic:='0';
-- coefficient 
signal c_in   		: std_logic_vector( Win-1 downto 0);
-- data input
signal x_in         : std_logic_vector( Win-1 downto 0);
-- filtered data 
signal y_out        : std_logic_vector( Wout-1 downto 0);

begin

clk   <= not clk after 5 ns;
reset  <= '0', '1' after 132 ns;

u_fir_filter_4 : fir_filter_4 
port map(
	clk      => clk        ,
	reset    => reset       ,
	Load_x   => Load_x      ,
	x_in     => x_in       ,
	c_in     => c_in    ,
	-- filtered data 
	y_out    => y_out       );

------------------------------------------------------------------------------------------------------------------------
-- FIR delta input, step input
------------------------------------------------------------------------------------------------------------------------

p_input : process (reset,clk)
variable control            : unsigned(10 downto 0):= (others=>'0');
begin
	if(reset=BUTTON_HIGH) then
		x_in       <= (others=>'0');
	elsif(rising_edge(clk)) then
		if(control=10) then  -- delta
			x_in       <= ('0',others=>'1');
		elsif(control(7)='1') then  -- step
			x_in       <= ('0',others=>'1');
		else
			x_in       <= (others=>'0');
		end if;
		control := control + 1;
	end if;
end process p_input;


end behave;
