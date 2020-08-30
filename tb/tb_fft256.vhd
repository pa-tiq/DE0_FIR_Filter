-- Generic 256 point DIF FFT algorithm using a register
-- array for data and coefficients

PACKAGE n_bits_int IS          -- User defined types
	SUBTYPE U9 IS INTEGER RANGE 0 TO 2**9-1;
	SUBTYPE S16 IS INTEGER RANGE -2**15 TO 2**15-1;
	SUBTYPE S32 IS INTEGER RANGE -2147483647 TO 2147483647;
	TYPE ARRAY0_7S16 IS ARRAY (0 TO 7) of S16;
	TYPE ARRAY0_255S16 IS ARRAY (0 TO 255) of S16;
	TYPE ARRAY0_127S16 IS ARRAY (0 TO 127) of S16;
	TYPE STATE_TYPE IS(start, load, calc, update, reverse, done);
END n_bits_int;

LIBRARY work; 
USE work.n_bits_int.ALL;
LIBRARY ieee; 
USE ieee.std_logic_1164.ALL;
--USE ieee.std_logic_arith.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;

entity tb_fft256 is
end tb_fft256;

architecture behave of tb_fft256 is

	component fft256   ------> Interface
	PORT (clk, reset 		: IN  STD_LOGIC; -- Clock and reset
		  xr_in, xi_in   	: IN  S16; -- Real and imag. input
		  fft_valid 		: OUT STD_LOGIC; -- FFT output is valid
		  fftr, ffti 		: OUT S16; -- Real and imag. output
		  rcount_o 			: OUT U9; -- Bitreverese index counter
		  xr_out, xi_out 	: OUT ARRAY0_7S16; -- First 8 reg. files
		  stage_o, gcount_o : OUT U9; --Stage and group count
		  i1_o, i2_o 		: OUT U9; -- (Dual) data index
		  k1_o, k2_o 		: OUT U9; -- Index offset
		  w_o, dw_o  		: OUT U9; -- Cos/Sin (increment) angle
		  wo 				: OUT U9);-- Decision tree location loop FSM
	END component;

	-- L=256 RANGE -256 TO 255
	constant COEFF_ARRAY : ARRAY0_255S16 := (
		0,0,0,0,0,0,-1,-1,-1,-1,-1,-2,-2,-2,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,
		-2,-2,-1,0,1,2,3,4,5,6,7,8,10,11,12,13,14,15,15,16,17,17,17,17,17,16,16,15,14,12,
		11,9,7,5,3,0,-3,-6,-9,-12,-15,-18,-21,-24,-27,-30,-33,-35,-38,-40,-42,-43,-45,-45,
		-46,-45,-45,-44,-42,-39,-37,-33,-29,-24,-19,-13,-7,0,8,16,24,33,42,52,62,73,83,94,
		105,116,127,137,148,159,169,179,188,197,206,214,221,228,234,240,244,248,251,253,255,
		255,253,251,248,244,240,234,228,221,214,206,197,188,179,169,159,148,137,127,116,105,
		94,83,73,62,52,42,33,24,16,8,0,-7,-13,-19,-24,-29,-33,-37,-39,-42,-44,-45,-45,-46,-45,
		-45,-43,-42,-40,-38,-35,-33,-30,-27,-24,-21,-18,-15,-12,-9,-6,-3,0,3,5,7,9,11,12,14,
		15,16,16,17,17,17,17,17,16,15,15,14,13,12,11,10,8,7,6,5,4,3,2,1,0,-1,-2,-2,-3,-3,-4,
		-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,-3,-2,-2,-2,-1,-1,-1,-1,-1,0,0,0,0,0,0);

	-- L=256 RANGE -512 TO 511
	--constant COEFF_ARRAY : ARRAY0_255S16 := (
	--	0,0,0,0,0,-1,-1,-1,-2,-2,-3,-4,-4,-5,-5,-6,-7,-7,-8,-8,-8,-8,-8,-8,-8,-8,-7,-6,-5,-4,-3,
	--	-2,0,2,4,6,8,10,12,15,17,19,22,24,26,28,29,31,32,33,34,34,34,34,33,31,30,27,25,22,18,14,
	--	10,5,0,-5,-11,-17,-23,-29,-36,-42,-48,-54,-60,-66,-71,-76,-80,-84,-87,-89,-91,-91,-91,
	--	-90,-87,-84,-79,-74,-67,-58,-49,-39,-27,-14,0,15,31,48,66,85,105,125,146,167,189,210,232,
	--	254,276,298,319,339,359,378,396,414,430,445,459,471,482,491,498,504,509,511,511,509,504,
	--	498,491,482,471,459,445,430,414,396,378,359,339,319,298,276,254,232,210,189,167,146,125,
	--	105,85,66,48,31,15,0,-14,-27,-39,-49,-58,-67,-74,-79,-84,-87,-90,-91,-91,-91,-89,-87,-84,
	--	-80,-76,-71,-66,-60,-54,-48,-42,-36,-29,-23,-17,-11,-5,0,5,10,14,18,22,25,27,30,31,33,34,
	--	34,34,34,33,32,31,29,28,26,24,22,19,17,15,12,10,8,6,4,2,0,-2,-3,-4,-5,-6,-7,-8,-8,-8,-8,
	--	-8,-8,-8,-8,-7,-7,-6,-5,-5,-4,-4,-3,-2,-2,-1,-1,-1,0,0,0,0,0);
	
	signal clk                  : std_logic:='0';
	signal reset                : std_logic;
	signal xr_in, xi_in   		: S16; 
	signal fft_valid 			: STD_LOGIC;
	signal fftr, ffti 			: S16;  
	signal rcount_o 			: U9; 
	signal xr_out, xi_out 		: ARRAY0_7S16; 
	signal stage_o, gcount_o	: U9;
	signal i1_o, i2_o 			: U9;
	signal k1_o, k2_o 			: U9;
	signal w_o, dw_o  			: U9;
	signal wo 					: U9;

begin

	clk   <= not clk after 5 ns;
	reset  <= '0', '1' after 132 ns;

	u_fft256 : fft256
	port map(
		clk  		 		=> clk  			,
		reset				=> reset			, 
		xr_in 				=> xr_in 			,
		xi_in   	  		=> xi_in   	  	  	,
		fft_valid 	  		=> fft_valid 		,
		fftr				=> fftr			  	,
		ffti 		  		=> ffti 		  	,
		rcount_o 			=> rcount_o 		,
		xr_out				=> xr_out			,
		xi_out 	  			=> xi_out 	  		,
		stage_o				=> stage_o			,
		gcount_o  			=> gcount_o  		,	
		i1_o				=> i1_o			  	, 
		i2_o 			  	=> i2_o 			,	
		k1_o 				=> k1_o 			,	
		k2_o 		  		=> k2_o 		  	,	
		w_o 		 		=> w_o 		 	  	,	
		dw_o  		 		=> dw_o  		 	,	
		wo 				  	=> wo 				);	

	p_input : process (reset,clk)
		variable count 		: integer := 0;
	begin
		if(reset='0') then
			xr_in  <= 0;
			xi_in  <= 0;
		elsif(rising_edge(clk)) then
			if(count <= 255) then
				xr_in  <= to_integer(to_signed(COEFF_ARRAY(count),9));
				count := count+1;
			else
				xr_in <= 0; 
			end if;
			xi_in  <= 0;
			
		end	if;
	end process p_input;

end behave;

