library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

PACKAGE n_bit_int IS
	SUBTYPE COEFF_TYPE IS STD_LOGIC_VECTOR(6 DOWNTO 0);
	TYPE ARRAY_COEFF IS ARRAY (NATURAL RANGE <>) OF COEFF_TYPE;
END n_bit_int;

LIBRARY work;
USE work.n_bit_int.ALL;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fir_filter is
	generic ( 
		Win 			: INTEGER 	:= 7		;-- Input bit width
		Wmult			: INTEGER 	:= 14		;-- Multiplier bit width 2*Win
		Wadd 			: INTEGER 	:= 24		;-- Adder width = Wmult+log2(L)-1
		Wout 			: INTEGER 	:= 20		;-- Output bit width: between Win and Wadd
		BUTTON_HIGH 	: STD_LOGIC := '0'		;
		PATTERN_SIZE	: INTEGER 	:= 32		;
		RANGE_LOW 		: INTEGER 	:= -64		; --pattern range: power of 2
		RANGE_HIGH 		: INTEGER 	:= 63		; --must change pattern too
		LFilter  		: INTEGER 	:= 2048		); -- Filter length
end tb_fir_filter;

architecture behave of tb_fir_filter is

	constant noisy_size : integer := 100;
	type T_COEFF_INPUT is array(0 to LFilter-1) of integer range RANGE_LOW to RANGE_HIGH;	
	type T_NOISY_INPUT is array(0 to noisy_size-1) of integer range RANGE_LOW to RANGE_HIGH;

	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--	0,1,2,5,9,16,25,36,48,62,77,92,105,115,123,127,127,123,115,105,92,
	--	77,62,48,36,25,16,9,5,2,1,0);

	-- L=256 RANGE -256 TO 255
	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--	0,0,0,0,0,0,-1,-1,-1,-1,-1,-2,-2,-2,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,
	--	-2,-2,-1,0,1,2,3,4,5,6,7,8,10,11,12,13,14,15,15,16,17,17,17,17,17,16,16,15,14,12,
	--	11,9,7,5,3,0,-3,-6,-9,-12,-15,-18,-21,-24,-27,-30,-33,-35,-38,-40,-42,-43,-45,-45,
	--	-46,-45,-45,-44,-42,-39,-37,-33,-29,-24,-19,-13,-7,0,8,16,24,33,42,52,62,73,83,94,
	--	105,116,127,137,148,159,169,179,188,197,206,214,221,228,234,240,244,248,251,253,255,
	--	255,253,251,248,244,240,234,228,221,214,206,197,188,179,169,159,148,137,127,116,105,
	--	94,83,73,62,52,42,33,24,16,8,0,-7,-13,-19,-24,-29,-33,-37,-39,-42,-44,-45,-45,-46,-45,
	--	-45,-43,-42,-40,-38,-35,-33,-30,-27,-24,-21,-18,-15,-12,-9,-6,-3,0,3,5,7,9,11,12,14,
	--	15,16,16,17,17,17,17,17,16,15,15,14,13,12,11,10,8,7,6,5,4,3,2,1,0,-1,-2,-2,-3,-3,-4,
	--	-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,-3,-2,-2,-2,-1,-1,-1,-1,-1,0,0,0,0,0,0);

	-- L=256 RANGE -512 TO 511
	--constant COEFF_ARRAY : T_COEFF_INPUT := (
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
	
	-- L=256 RANGE -512 TO 511 HAMMING
	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--	0,0,0,1,1,1,0,0,0,-1,-1,-1,-1,0,0,1,1,1,1,1,0,0,-1,-2,-2,-1,-1,0,1,2,2,2,2,1,0,-2,-3,-3,-3,-2,-1,1,3,4,4,4,
	--	2,0,-2,-4,-6,-6,-4,-2,1,4,6,7,7,5,1,-3,-6,-9,-9,-8,-5,0,5,9,12,12,9,4,-2,-8,-13,-15,-14,-10,-3,5,13,18,19,16,
	--	9,0,-10,-19,-24,-24,-18,-8,4,17,27,32,30,20,6,-12,-28,-40,-43,-37,-22,0,25,47,61,62,50,23,-13,-52,-86,-107,
	--	-106,-79,-24,56,153,257,357,439,493,511,511,493,439,357,257,153,56,-24,-79,-106,-107,-86,-52,-13,23,50,62,61,
	--	47,25,0,-22,-37,-43,-40,-28,-12,6,20,30,32,27,17,4,-8,-18,-24,-24,-19,-10,0,9,16,19,18,13,5,-3,-10,-14,-15,
	--	-13,-8,-2,4,9,12,12,9,5,0,-5,-8,-9,-9,-6,-3,1,5,7,7,6,4,1,-2,-4,-6,-6,-4,-2,0,2,4,4,4,3,1,-1,-2,-3,-3,-3,-2,
	--	0,1,2,2,2,2,1,0,-1,-1,-2,-2,-1,0,0,1,1,1,1,1,0,0,-1,-1,-1,-1,0,0,0,1,1,1,0,0,0);

	-- L=256 RANGE -512 TO 511 BLACKMANHARRIS
	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,-1,-1,-1,-1,
	--	-1,-1,0,1,2,2,2,2,0,-1,-2,-4,-4,-3,-2,0,2,4,6,6,5,2,-1,-5,-7,-9,-8,-6,-2,3,8,12,13,11,7,0,-7,-14,-18,-18,-14,
	--	-7,3,14,22,26,25,17,5,-10,-25,-35,-39,-34,-20,0,23,44,57,59,47,22,-12,-51,-84,-105,-104,-78,-24,55,152,256,356,
	--	438,492,511,511,492,438,356,256,152,55,-24,-78,-104,-105,-84,-51,-12,22,47,59,57,44,23,0,-20,-34,-39,-35,-25,-10,
	--	5,17,25,26,22,14,3,-7,-14,-18,-18,-14,-7,0,7,11,13,12,8,3,-2,-6,-8,-9,-7,-5,-1,2,5,6,6,4,2,0,-2,-3,-4,-4,-2,
	--	-1,0,2,2,2,2,1,0,-1,-1,-1,-1,-1,-1,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	--	0,0,0,0,0,0,0,0,0,0,0);

	-- L=512 RANGE -256 TO 255
	--constant COEFF_ARRAY : T_COEFF_INPUT := (
	--	0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,-3,
	--	-3,-3,-3,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,
	--	-4,-3,-3,-3,-3,-2,-2,-2,-2,-1,-1,0,0,0,1,1,2,2,3,3,4,4,5,6,6,7,7,8,8,9,10,
	--	10,11,11,12,12,13,13,14,14,15,15,15,16,16,16,17,17,17,17,17,17,17,17,17,17,
	--	16,16,16,15,15,14,14,13,12,12,11,10,9,8,7,6,5,4,3,1,0,-1,-3,-4,-6,-7,-9,-10,
	--	-12,-13,-15,-16,-18,-19,-21,-23,-24,-26,-27,-29,-30,-31,-33,-34,-35,-37,-38,
	--	-39,-40,-41,-42,-43,-43,-44,-45,-45,-45,-45,-46,-46,-45,-45,-45,-44,-44,-43,
	--	-42,-41,-40,-38,-37,-35,-33,-31,-29,-27,-24,-22,-19,-16,-13,-10,-7,-4,0,4,8,
	--	11,16,20,24,28,33,38,42,47,52,57,62,67,73,78,83,89,94,99,105,110,116,121,127,
	--	132,137,143,148,153,159,164,169,174,179,184,188,193,197,202,206,210,214,218,
	--	222,225,228,231,234,237,240,242,244,246,248,250,251,252,253,254,255,255,255,
	--	255,254,253,252,251,250,248,246,244,242,240,237,234,231,228,225,222,218,214,
	--	210,206,202,197,193,188,184,179,174,169,164,159,153,148,143,137,132,127,121,
	--	116,110,105,99,94,89,83,78,73,67,62,57,52,47,42,38,33,28,24,20,16,11,8,4,0,
	--	-4,-7,-10,-13,-16,-19,-22,-24,-27,-29,-31,-33,-35,-37,-38,-40,-41,-42,-43,-44,
	--	-44,-45,-45,-45,-46,-46,-45,-45,-45,-45,-44,-43,-43,-42,-41,-40,-39,-38,-37,
	--	-35,-34,-33,-31,-30,-29,-27,-26,-24,-23,-21,-19,-18,-16,-15,-13,-12,-10,-9,-7,
	--	-6,-4,-3,-1,0,1,3,4,5,6,7,8,9,10,11,12,12,13,14,14,15,15,16,16,16,17,17,17,17,
	--	17,17,17,17,17,17,16,16,16,15,15,15,14,14,13,13,12,12,11,11,10,10,9,8,8,7,7,6,
	--	6,5,4,4,3,3,2,2,1,1,0,0,0,-1,-1,-2,-2,-2,-2,-3,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,
	--	-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,-3,-3,-3,-3,-3,-2,-2,-2,-2,-2,-2,-1,-1,
	--	-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0);

	-- L=2048 RANGE -64 to 63 HAMMING
	constant COEFF_ARRAY : T_COEFF_INPUT := (
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,-2,-2,-2,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,-3,-3,-3,-3,-3,-3,-3,-2,-2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,4,4,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,6,6,6,6,6,6,6,6,5,5,5,5,5,5,4,4,4,4,4,3,3,3,3,2,2,2,2,1,1,1,1,0,0,0,-1,-1,-1,-2,-2,-2,-2,-3,-3,-3,-4,-4,-4,-5,-5,-5,-6,-6,-6,-6,-7,-7,-7,-8,-8,-8,-8,-9,-9,-9,-10,-10,-10,-10,-10,-11,-11,-11,-11,-11,-12,-12,-12,-12,-12,-12,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-12,-12,-12,-12,-12,-11,-11,-11,-11,-10,-10,-10,-10,-9,-9,-8,-8,-8,-7,-7,-6,-6,-6,-5,-5,-4,-3,-3,-2,-2,-1,-1,0,1,1,2,3,3,4,5,5,6,7,7,8,9,10,11,11,12,13,14,15,15,16,17,18,19,20,20,21,22,23,24,25,26,26,27,28,29,30,31,32,32,33,34,35,36,37,37,38,39,40,41,41,42,43,44,45,45,46,47,48,48,49,50,50,51,52,52,53,53,54,55,55,56,56,57,57,58,58,58,59,59,60,60,60,61,61,61,62,62,62,62,62,62,63,63,63,63,63,63,63,63,63,63,63,63,62,62,62,62,62,62,61,61,61,60,60,60,59,59,58,58,58,57,57,56,56,55,55,54,53,53,52,52,51,50,50,49,48,48,47,46,45,45,44,43,42,41,41,40,39,38,37,37,36,35,34,33,32,32,31,30,29,28,27,26,26,25,24,23,22,21,20,20,19,18,17,16,15,15,14,13,12,11,11,10,9,8,7,7,6,5,5,4,3,3,2,1,1,0,-1,-1,-2,-2,-3,-3,-4,-5,-5,-6,-6,-6,-7,-7,-8,-8,-8,-9,-9,-10,-10,-10,-10,-11,-11,-11,-11,-12,-12,-12,-12,-12,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-13,-12,-12,-12,-12,-12,-12,-11,-11,-11,-11,-11,-10,-10,-10,-10,-10,-9,-9,-9,-8,-8,-8,-8,-7,-7,-7,-6,-6,-6,-6,-5,-5,-5,-4,-4,-4,-3,-3,-3,-2,-2,-2,-2,-1,-1,-1,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,4,5,5,5,5,5,5,6,6,6,6,6,6,6,6,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,6,6,6,6,6,6,6,6,6,6,5,5,5,5,5,5,4,4,4,4,4,4,4,3,3,3,3,3,2,2,2,2,2,2,1,1,1,1,1,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,-2,-3,-3,-3,-3,-3,-3,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-2,-2,-2,-2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	);
	
	-- noisy sin -127 to 126
	--constant NOISY_ARRAY : T_NOISY_INPUT := (
	--	-10,1,11,35,36,18,49,41,42,51,51,56,70,75,79,79,72,87,96,93,100,
	--	101,98,104,100,111,101,103,106,95,121,115,109,121,103,111,109,111,
	--	110,101,104,101,103,103,100,85,87,76,73,75,80,62,64,56,59,41,42,40,
	--	38,35,21,6,5,-3,11,-11,-9,-20,-19,-35,-44,-49,-43,-52,-58,-53,-64,
	--	-70,-66,-84,-80,-83,-93,-93,-105,-108,-103,-102,-94,-114,-111,-114,
	--	-126,-119,-127,-112,-122,-117,-120,-114);

	--noisy sawtooth -64 to 63
	constant NOISY_ARRAY : T_NOISY_INPUT := (
		-30,-25,-33,-32,-20,-46,-30,-35,-26,-15,-12,-27,-20,-13,-15,-8 ,-6 ,-16,-8 ,-24,7  ,-7 ,-11,0  ,-9 ,5  ,2  ,28 ,20 ,-11,17 ,2  ,14 ,19 ,26 ,19 ,37 ,20 ,29 ,33 ,30 ,39 ,35 ,27 ,19 ,54 ,33 ,41 ,47 ,44 ,37 ,42 ,47 ,63 ,44 ,60 ,57 ,54 ,48 ,57 ,60 ,50 ,-35,-42,-34,-29,-38,-31,-24,-42,-14,0  ,-12,-22,-13,-25,3  ,-4 ,-4 ,-17,-5 ,-11,-7 ,-8 ,-10,-8 ,0  ,-12,11 ,6  ,15 ,13 ,16 ,0  ,6  ,12 ,19 ,30 ,19 ,34
		);

	-- noisy sawtooth -256 to 255
	--constant NOISY_ARRAY : T_NOISY_INPUT := (
	--	-155,-124,-155,-177,-200,-134,-104,-138,-140,-125,-147,-119,-102,-87 ,-85 ,-54 ,-65 ,2   ,-45 ,15  ,-70 ,-18 ,-40 ,-3  ,3   ,-90 ,-53 ,-50 ,22  ,67  ,9   ,56  ,53  ,2   ,61  ,26  ,114 ,64  ,131 ,63  ,106 ,89  ,25  ,69  ,133 ,115 ,83  ,107 ,145 ,107 ,184 ,132 ,227 ,130 ,182 ,127 ,162 ,173 ,215 ,241 ,224 ,206 ,256 ,-142,-160,-138,-137,-181,-112,-156,-148,-113,-124,-112,-79 ,-56 ,-95 ,-69 ,-83 ,-60 ,-46 ,-78 ,-39 ,-21 ,-33 ,32  ,-45 ,-43 ,-73 ,29  ,34  ,6   ,48  ,28  ,39  ,39  ,57  ,51  ,154 ,18		);

	component fir_filter 
	generic( 
		Win 		: INTEGER	; -- Input bit width
		Wmult 		: INTEGER	;-- Multiplier bit width 2*W1
		Wadd 		: INTEGER	;-- Adder width = Wmult+log2(L)-1
		Wout 		: INTEGER	;-- Output bit width
		BUTTON_HIGH : STD_LOGIC ;
		LFilter  	: INTEGER	);--Filter Length
	port (
		clk     : IN  STD_LOGIC								;  -- System clock
		reset   : IN  STD_LOGIC								;
		i_coeff : in  ARRAY_COEFF(0 to Lfilter-1)			; 
		i_data  : IN  std_logic_vector( Win-1 	downto 0)	;-- System input
		o_data  : OUT std_logic_vector( Wout-1 	downto 0)	);-- System output 
	end component;

	signal clk      : std_logic:='0';
	signal reset    : std_logic:='0';
	signal i_coeff 	: ARRAY_COEFF(0 to Lfilter-1); 
	signal i_data   : std_logic_vector( Win-1  downto 0);
	signal o_data   : std_logic_vector( Wout-1 downto 0);
	signal NOISY	: ARRAY_COEFF(0 to noisy_size-1);

begin

	clk   <= not clk after 5 ns;
	reset  <= '0', '1' after 132 ns;

	u_fir_filter : fir_filter 
	generic map( 
		Win 		 => Win				, -- Input bit width
		Wmult		 => Wmult			,
		Wadd		 => Wadd			,
		Wout 		 => Wout			,-- Output bit width
		BUTTON_HIGH  => BUTTON_HIGH		,
		LFilter  	 => LFilter			) -- Filter length	
	port map(
		clk         => clk        ,
		reset       => reset      ,
		i_coeff 	=> i_coeff	  ,
		i_data      => i_data     ,
		o_data      => o_data     );

	p_input : process (reset,clk)
		variable control  	: unsigned(11 downto 0):= (others=>'0');
		variable count 		: integer := 0;
		variable first_time : std_logic := '0';
	begin
		if(first_time='0') then
			for k in 0 to Lfilter-1 loop
				i_coeff(k)  <=  std_logic_vector(to_signed(COEFF_ARRAY(k),Win));
			end loop;			
			for j in 0 to noisy_size-1 loop
				NOISY(j)  <=  std_logic_vector(to_signed(NOISY_ARRAY(j),Win));
			end loop;
			first_time := '1';
		end if;
		
		if(reset=BUTTON_HIGH) then
			i_data       <= (others=>'0'); 
		elsif(rising_edge(clk)) then
			
		-- DELTA, STEP ...........
			if(control=100 and count = 0) then  -- delta
				i_data       <= ('0',others=>'1');
			elsif(control(11)='1' and count <3000 ) then  -- step
				i_data       <= ('0',others=>'1');
				count := count + 1;
			else
				i_data       <= (others=>'0');
			end if;
			control := control + 1;
		------------------------------------------------

		-- DELTA, STEP, STEP, STEP, .......
		--	if(control=10) then  -- delta
		--		i_data       <= ('0',others=>'1');
		--	elsif(control(7)='1') then  -- step
		--		i_data       <= ('0',others=>'1');
		--	else
		--		i_data       <= (others=>'0');
		--	end if;
		--	control := control + 1;
		-------------------------------------------------
		
		-- NOISY ANALOG SIGNAL
		--	if(count < noisy_size) then
		--		i_data <= NOISY(count);
		--		count := count + 1;
		--	else
		--		i_data <= (others=>'0');
		--	end if;
		-------------------------------------------------

		end if;
	end process p_input;

end behave;
