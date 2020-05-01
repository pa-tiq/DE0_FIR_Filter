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
-- Fle Name: seven_seg_driver.vhd
-- 
-- scope: driver for 7-segment display: 4-bit input; 7 bit output
--
-- rev 1.00
-- 
-- ******************************************************************** 
-- ******************************************************************** 


--      ---a----
--      |	  |
--      f 	  b
--      |	  |
--      ---g----
--      |	  |
--      e 	  c
--      |	  |
--      ---d--- 

-- a = h(0)
-- b = h(1)
-- c = h(2)
-- d = h(3)
-- e = h(4)
-- f = h(5)
-- g = h(6)

library ieee;
use ieee.std_logic_1164.all;

entity seven_seg_driver is
port(
-- input control
	i_h0                       : in  std_logic_vector(3 downto 0);  -- h(3..0) => nibble
	i_h1                       : in  std_logic_vector(3 downto 0);  -- h(3..0) => nibble 
	i_h2                       : in  std_logic_vector(3 downto 0);  -- h(3..0) => nibble 
	i_h3                       : in  std_logic_vector(3 downto 0);  -- h(3..0) => nibble 
-- seven segment output
	o_h0                       : out std_logic_vector(6 downto 0);   -- h(6..0) => display segment 
	o_h1                       : out std_logic_vector(6 downto 0);   -- h(6..0) => display segment
	o_h2                       : out std_logic_vector(6 downto 0);   -- h(6..0) => display segment
	o_h3                       : out std_logic_vector(6 downto 0));  -- h(6..0) => display segment
end seven_seg_driver;

architecture rtl of seven_seg_driver is
------------------------------------------------------------------------------------------------
-- LUT mapping
function seven_seg_lut4(nibble : in std_logic_vector(3 downto 0)) return std_logic_vector is
variable ret   : std_logic_vector(6 downto 0);
begin
	case (nibble(3 downto 0)) is
		when   X"1" => ret := "1111001";
		when   X"2" => ret := "0100100";
		when   X"3" => ret := "0110000";
		when   X"4" => ret := "0011001";
		when   X"5" => ret := "0010010";
		when   X"6" => ret := "0000010";
		when   X"7" => ret := "1111000";
		when   X"8" => ret := "0000000";
		when   X"9" => ret := "0011000";
		when   X"a" => ret := "0001000";
		when   X"b" => ret := "0000011";
		when   X"c" => ret := "1000110";
		when   X"d" => ret := "0100001";
		when   X"e" => ret := "0000110";
		when   X"f" => ret := "0001110";
		when others => ret := "1000000";  -- X"0"
	end case;
	return ret;
end seven_seg_lut4;
------------------------------------------------------------------------------------------------

begin

o_h0  <= seven_seg_lut4(i_h0);
o_h1  <= seven_seg_lut4(i_h1);
o_h2  <= seven_seg_lut4(i_h2);
o_h3  <= seven_seg_lut4(i_h3);

end rtl;
