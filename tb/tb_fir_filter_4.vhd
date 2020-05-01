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
end tb_fir_filter_4;

architecture behave of tb_fir_filter_4 is

component fir_filter_4 
port (
	i_clk        : in  std_logic;
	i_rstb       : in  std_logic;
	-- coefficient
	i_coeff_0    : in  std_logic_vector( 7 downto 0);
	i_coeff_1    : in  std_logic_vector( 7 downto 0);
	i_coeff_2    : in  std_logic_vector( 7 downto 0);
	i_coeff_3    : in  std_logic_vector( 7 downto 0);
	-- data input
	i_data       : in  std_logic_vector( 7 downto 0);
	-- filtered data 
	o_data       : out std_logic_vector( 9 downto 0));
end component;

signal i_clk        : std_logic:='0';
signal i_rstb       : std_logic:='0';
-- coefficient
signal i_coeff_0    : std_logic_vector( 7 downto 0):= std_logic_vector(to_signed(-10,8));
signal i_coeff_1    : std_logic_vector( 7 downto 0):= std_logic_vector(to_signed(110,8));
signal i_coeff_2    : std_logic_vector( 7 downto 0):= std_logic_vector(to_signed(127,8));
signal i_coeff_3    : std_logic_vector( 7 downto 0):= std_logic_vector(to_signed(-20,8));
-- data input
signal i_data       : std_logic_vector( 7 downto 0);
-- filtered data 
signal o_data       : std_logic_vector( 9 downto 0);

begin

i_clk   <= not i_clk after 5 ns;
i_rstb  <= '0', '1' after 132 ns;

u_fir_filter_4 : fir_filter_4 
port map(
	i_clk        => i_clk        ,
	i_rstb       => i_rstb       ,
	-- coefficient
	i_coeff_0    => i_coeff_0    ,
	i_coeff_1    => i_coeff_1    ,
	i_coeff_2    => i_coeff_2    ,
	i_coeff_3    => i_coeff_3    ,
	-- data input
	i_data       => i_data       ,
	-- filtered data 
	o_data       => o_data       );

------------------------------------------------------------------------------------------------------------------------
-- FIR delta input, step input
------------------------------------------------------------------------------------------------------------------------

p_input : process (i_rstb,i_clk)
variable control            : unsigned(10 downto 0):= (others=>'0');
begin
	if(i_rstb='0') then
		i_data       <= (others=>'0');
	elsif(rising_edge(i_clk)) then
		if(control=10) then  -- delta
			i_data       <= ('0',others=>'1');
		elsif(control(7)='1') then  -- step
			i_data       <= ('0',others=>'1');
		else
			i_data       <= (others=>'0');
		end if;
		control := control + 1;
	end if;
end process p_input;


end behave;
