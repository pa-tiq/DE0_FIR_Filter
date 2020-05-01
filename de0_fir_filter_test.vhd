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
-- Fle Name: de0_fir_filter_test.vhd
-- 
-- scope: DE0 top level for _fir_filter_test
-- button(2) : start generation data
-- button(1) : read request for memory
-- button(0) : reset
--
-- rev 1.00
-- 
-- ******************************************************************** 
-- ******************************************************************** 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de0_fir_filter_test is
generic( 
	Win : INTEGER := 10; -- Input bit width
	Wmult : INTEGER := 20;-- Multiplier bit width 2*W1
	Wadd : INTEGER := 28;-- Adder width = Wmult+log2(L)-1
	Wout : INTEGER := 12;-- Output bit width
	BUTTON_HIGH : STD_LOGIC := '0';
	PATTERN_SIZE: INTEGER := 32;
	RANGE_LOW : INTEGER := -512; --pattern range: power of 2
	RANGE_HIGH : INTEGER := 511); --must change pattern too
	LFilter  : INTEGER := 513); -- Filter length
port (
	-- ////////////////////	clock input	 	////////////////////	 
	pad_i_clock_50                             : in    std_logic;  --	50 MHz
	pad_i_clock_50_2                           : in    std_logic;  --	50 MHz
	-- ////////////////////	push button		////////////////////
	pad_i_button                               : in    std_logic_vector(2 downto 0);  --	pushbutton[2:0]
	-- ////////////////////	dpdt switch		////////////////////
	pad_i_sw                                   : in    std_logic_vector(9 downto 0);  -- toggle switch[9:0]
	-- ////////////////////	7-seg dispaly	////////////////////
	pad_o_hex0_d                               : out   std_logic_vector(6 downto 0);  -- seven segment digit 0
	pad_o_hex0_dp                              : out   std_logic;                     -- seven segment digit dp 0
	pad_o_hex1_d                               : out   std_logic_vector(6 downto 0);  -- seven segment digit 1
	pad_o_hex1_dp                              : out   std_logic;                     -- seven segment digit dp 1
	pad_o_hex2_d                               : out   std_logic_vector(6 downto 0);  -- seven segment digit 2
	pad_o_hex2_dp                              : out   std_logic;                     -- seven segment digit dp 2
	pad_o_hex3_d                               : out   std_logic_vector(6 downto 0);  -- seven segment digit 3
	pad_o_hex3_dp                              : out   std_logic;                     -- seven segment digit dp 3
	-- ////////////////////////	led		////////////////////////
	pad_o_ledg                                 : out   std_logic_vector(9 downto 0);  -- 	led green[9:0]
	-- ////////////////////////	uart	////////////////////////
	pad_o_uart_tx                              : out   std_logic;  -- uart transmitter
	pad_i_uart_rx                              : in    std_logic;  -- uart receiver
	pad_o_uart_cts                             : out   std_logic;  -- uart clear to send
	pad_i_uart_rts                             : in    std_logic;  -- uart request to send
	-- /////////////////////	sdram interface		////////////////
	pad_b_dram_dq                              : inout std_logic_vector(15 downto 0);  -- sdram data bus 16 bits
	pad_o_dram_addr                            : out   std_logic_vector(12 downto 0);  -- sdram address bus 13 bits
	pad_o_dram_ldqm                            : out   std_logic;  -- sdram low-byte data mask 
	pad_o_dram_udqm                            : out   std_logic;  -- sdram high-byte data mask
	pad_o_dram_we_n                            : out   std_logic;  -- sdram write enable
	pad_o_dram_cas_n                           : out   std_logic;  -- sdram column address strobe
	pad_o_dram_ras_n                           : out   std_logic;  -- sdram row address strobe
	pad_o_dram_cs_n                            : out   std_logic;  -- sdram chip select
	pad_o_dram_ba_0                            : out   std_logic;  -- sdram bank address 0
	pad_o_dram_ba_1                            : out   std_logic;  -- sdram bank address 1
	pad_o_dram_clk                             : out   std_logic;  -- sdram clock
	pad_o_dram_cke                             : out   std_logic;  -- sdram clock enable
	-- ////////////////////	flash interface		////////////////
	pad_b_fl_dq                                : inout std_logic_vector(14 downto 0);  -- flash data bus 15 bits
	pad_b_fl_dq15_am1                          : inout std_logic ;                     -- flash data bus bit 15 or address a-1
	pad_o_fl_addr                              : out   std_logic_vector(21 downto 0);  -- flash address bus 22 bits
	pad_o_fl_we_n                              : out   std_logic;  -- flash write enable
	pad_o_fl_rst_n                             : out   std_logic;  -- flash reset
	pad_o_fl_oe_n                              : out   std_logic;  -- flash output enable
	pad_o_fl_ce_n                              : out   std_logic;  -- flash chip enable
	pad_o_fl_wp_n                              : out   std_logic;  -- flash hardware write protect
	pad_o_fl_byte_n                            : out   std_logic;  -- flash selects 8/16-bit mode
	pad_i_fl_ry                                : in    std_logic;  -- flash ready/busy
	-- ////////////////////	lcd module 16x2		////////////////
	pad_o_lcd_blon                             : out   std_logic;  -- lcd back light on/off
	pad_o_lcd_rw                               : out   std_logic;  -- lcd read/write select, 0 = write, 1 = read
	pad_o_lcd_en                               : out   std_logic;  -- lcd enable
	pad_o_lcd_rs                               : out   std_logic;  -- lcd command/data select, 0 = command, 1 = data
	pad_b_lcd_data                             : inout std_logic_vector(7 downto 0);  -- lcd data bus 8 bits
	-- ////////////////////	sd_card interface	////////////////
	pad_b_sd_dat0                              : inout std_logic;  -- sd card data 0
	pad_b_sd_dat3                              : inout std_logic;  -- sd card data 3
	pad_b_sd_cmd                               : inout std_logic;  -- sd card command signal
	pad_o_sd_clk                               : out   std_logic;  -- sd card clock
	pad_o_sd_wp_n                              : out   std_logic;  -- sd card write protect
	-- ////////////////////	ps2		////////////////////////////
	pad_b_ps2_kbdat                            : inout std_logic;  -- ps2 keyboard data
	pad_b_ps2_kbclk                            : inout std_logic;  -- ps2 keyboard clock
	pad_b_ps2_msdat                            : inout std_logic;  -- ps2 mouse data
	pad_b_ps2_msclk                            : inout std_logic;  -- ps2 mouse clock
	-- ////////////////////	vga		////////////////////////////
	pad_o_vga_hs                               : out   std_logic;  -- vga h_sync
	pad_o_vga_vs                               : out   std_logic;  -- vga v_sync
	pad_o_vga_r                                : out   std_logic_vector(3 downto 0);  -- vga red[3:0]
	pad_o_vga_g                                : out   std_logic_vector(3 downto 0);  -- vga green[3:0]
	pad_o_vga_b                                : out   std_logic_vector(3 downto 0);  -- vga blue[3:0]
	-- ////////////////////	gpio	////////////////////////////
	pad_i_gpio0_clkin                          : in    std_logic_vector(1 downto 0);  -- gpio connection 0 clock in bus
	pad_o_gpio0_clkout                         : out   std_logic_vector(1 downto 0);  -- gpio connection 0 clock out bus
	pad_b_gpio0_d                              : inout std_logic_vector(31 downto 0);  -- gpio connection 0 data bus
	pad_i_gpio1_clkin                          : in    std_logic_vector(1 downto 0);  -- gpio connection 1 clock in bus
	pad_o_gpio1_clkout                         : out   std_logic_vector(1 downto 0);  -- gpio connection 1 clock out bus
	pad_b_gpio1_d                              : inout std_logic_vector(31 downto 0)  -- gpio connection 1 data bus
	);
end de0_fir_filter_test;

architecture rtl of de0_fir_filter_test is

component seven_seg_driver
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
end component;

component fir_filter_test
port (
	i_clk                   : in  std_logic;
	i_rstb                  : in  std_logic;
	i_pattern_sel           : in  std_logic;  -- '0'=> delta; '1'=> step
	i_start_generation      : in  std_logic;
	i_read_request          : in  std_logic;
	o_data_buffer           : out std_logic_vector( Wout-1 downto 0); -- to seven segment
	o_test_add              : out std_logic_vector( 4 downto 0)); -- test read address
end component;

signal w_rstb                     : std_logic;
signal w_clk                      : std_logic;
signal w_pattern_sel              : std_logic;  -- '0'=> delta; '1'=> step
signal w_start_generation         : std_logic;
signal w_read_request             : std_logic;
signal w_data_buffer              : std_logic_vector( Wout-1 downto 0); -- to seven segment
signal w_test_add                 : std_logic_vector( 4 downto 0); -- test read address

-- SEVEN SEGMENT
signal w_h0_in                    : std_logic_vector(3 downto 0);
signal w_h1_in                    : std_logic_vector(3 downto 0);
signal w_h2_in                    : std_logic_vector(3 downto 0);
signal w_h3_in                    : std_logic_vector(3 downto 0);


begin
-- CLOCK and RESET
w_rstb                     <= pad_i_button(0);
w_clk                      <= pad_i_clock_50;

-- LED
pad_o_ledg(0)  <= '0';
pad_o_ledg(1)  <= '0';
pad_o_ledg(2)  <= '0';
pad_o_ledg(3)  <= '0';
pad_o_ledg(4)  <= '0';
pad_o_ledg(5)  <= '0';
pad_o_ledg(6)  <= '0';
pad_o_ledg(7)  <= pad_i_button(2);
pad_o_ledg(8)  <= pad_i_button(1) ;
pad_o_ledg(9)  <= pad_i_button(0);

-- SEVEN SEGMENT
u_seven_seg_driver : seven_seg_driver
port map(
-- input control
	i_h0                       => w_h0_in                    ,
	i_h1                       => w_h1_in                    ,
	i_h2                       => w_h2_in                    ,
	i_h3                       => w_h3_in                    ,
-- seven segment output
	o_h0                       => pad_o_hex0_d               ,
	o_h1                       => pad_o_hex1_d               ,
	o_h2                       => pad_o_hex2_d               ,
	o_h3                       => pad_o_hex3_d               );

-- SEVEN SEGMENT
w_h0_in                    <= w_data_buffer(3 downto 0);
w_h1_in                    <= w_data_buffer(7 downto 4);
w_h2_in                    <= w_data_buffer(11 downto 8);
w_h3_in                    <= w_test_add(3 downto 0);

pad_o_hex0_dp              <= '0';
pad_o_hex1_dp              <= '0';
pad_o_hex2_dp              <= '0';
pad_o_hex3_dp              <= not w_test_add(4); -- MSB for address


w_pattern_sel        <= pad_i_sw(9);
w_start_generation   <= not pad_i_button(2);
w_read_request       <= not pad_i_button(1);

u_fir_filter_test : fir_filter_test
port map(
	i_clk                   => w_clk                   ,
	i_rstb                  => w_rstb                  ,
	i_pattern_sel           => w_pattern_sel           ,
	i_start_generation      => w_start_generation      ,
	i_read_request          => w_read_request          ,
	o_data_buffer           => w_data_buffer           ,
	o_test_add              => w_test_add              );

------------------------------------------------------------------------------------------------------------------
-- ASSIGN unused pins
------------------------------------------------------------------------------------------------------------------
	-- ////////////////////////	uart	////////////////////////
	pad_o_uart_tx             <= '1';
	pad_o_uart_cts            <= '1';

	-- /////////////////////	sdram interface		////////////////
	pad_b_dram_dq         <= (others=>'Z');
	pad_o_dram_addr       <= (others=>'0');
	pad_o_dram_ldqm       <= '1';
	pad_o_dram_udqm       <= '1';
	pad_o_dram_we_n       <= '1';
	pad_o_dram_cas_n      <= '1';
	pad_o_dram_ras_n      <= '1';
	pad_o_dram_cs_n       <= '1';
	pad_o_dram_ba_0       <= '1';
	pad_o_dram_ba_1       <= '1';
	pad_o_dram_clk        <= '1';
	pad_o_dram_cke        <= '1';

	-- ////////////////////	flash interface		////////////////
	pad_b_fl_dq           <= (others=>'Z');
	pad_b_fl_dq15_am1     <= 'Z';
	pad_o_fl_addr         <= (others=>'0');
	pad_o_fl_we_n         <= '1';
	pad_o_fl_rst_n        <= '1';
	pad_o_fl_oe_n         <= '1';
	pad_o_fl_ce_n         <= '1';
	pad_o_fl_wp_n         <= '1';
	pad_o_fl_byte_n       <= '1';

	-- ////////////////////	lcd module 16x2		////////////////
	pad_o_lcd_blon        <= '0';
	pad_o_lcd_rw          <= '0';
	pad_o_lcd_en          <= '0';
	pad_o_lcd_rs          <= '0';
	pad_b_lcd_data        <= (others=>'Z');

	-- ////////////////////	sd_card interface	////////////////
	pad_b_sd_dat0         <= 'Z';
	pad_b_sd_dat3         <= 'Z';
	pad_b_sd_cmd          <= 'Z';
	pad_o_sd_clk          <= '0';
	pad_o_sd_wp_n         <= '0';

	-- ////////////////////	ps2		////////////////////////////
	pad_b_ps2_kbdat       <= 'Z';
	pad_b_ps2_kbclk       <= 'Z';
	pad_b_ps2_msdat       <= 'Z';
	pad_b_ps2_msclk       <= 'Z';

	-- ////////////////////	vga		////////////////////////////
	pad_o_vga_hs          <= '0';
	pad_o_vga_vs          <= '0';
	pad_o_vga_r           <= (others=>'0');
	pad_o_vga_g           <= (others=>'0');
	pad_o_vga_b           <= (others=>'0');

	-- ////////////////////	gpio	////////////////////////////
	pad_o_gpio0_clkout    <= "00";
	pad_b_gpio0_d         <= (others=>'Z');
	pad_o_gpio1_clkout    <= "00";
	pad_b_gpio1_d         <= (others=>'Z');

end architecture rtl;