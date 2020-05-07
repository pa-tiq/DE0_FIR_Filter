LIBRARY work;
USE work.n_bit_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY fir_filter_4 IS 
GENERIC(
	BUTTON_HIGH : STD_LOGIC := '0');
PORT (
	clk   :   IN  STD_LOGIC	; -- System clock
	reset :   IN  STD_LOGIC	; -- Asynchron reset
	x     :   IN  S8			; -- System input
	y     :   OUT S8			);-- System output
END fir_filter_4;

ARCHITECTURE fpga OF fir_filter_4 IS
	SIGNAL t1,t2,t3,t4 : S8;
	SIGNAL tap : AS8;
BEGIN
	P1: PROCESS(clk, reset, x, tap) -- Behavioral Style	
	BEGIN
		IF reset = '0' THEN   -- clear shift register
			FOR K IN 0 TO 3 LOOP
				tap(K) <= 0;
			END LOOP;
			y<=0;
		ELSIF rising_edge(clk) THEN
		-- Compute output y with the filter coefficients weight.
		-- The coefficients are [-1  3.75  3.75  -1].
		-- Division for Altera VHDL is only allowed for
		-- powers-of-two values!
			--WAIT UNTIL clk = '1';  -- Pipelined all operations
			t1 <= tap(1) + tap(2); -- Use symmetry of coefficients
			t2 <= tap(0) + tap(3); -- and pipeline adder
			t3 <= 4*t1-t1/4;  --Pipelined CSD multiplier
			t4 <= -t2;  -- Build a binary tree and add delay
			y <=  t3 + t4;
			FOR I IN 3 DOWNTO 1 LOOP
				tap(I) <= tap(I-1); -- Tapped delay line: shift one
			END LOOP;
		END IF;
		tap(0) <= x; -- Input in register 0
	END PROCESS P1;
END fpga;

--    0.0028
--	  0.0084
--   -0.0079
--   -0.0044
--    0.0111
--   -0.0017
--   -0.0109
--    0.0083
--    0.0070
--   -0.0131
--    0.0001
--    0.0144
--   -0.0086
--   -0.0108
--    0.0160
--    0.0026
--   -0.0196
--    0.0089
--    0.0170
--   -0.0206
--   -0.0074
--    0.0289
--   -0.0090
--   -0.0297
--    0.0301
--    0.0188
--   -0.0525
--    0.0091
--    0.0723
--   -0.0695
--   -0.0860
--    0.3054
--    0.5908
--    0.3054
--   -0.0860
--   -0.0695
--    0.0723
--    0.0091
--   -0.0525
--    0.0188
--    0.0301
--   -0.0297
--   -0.0090
--    0.0289
--   -0.0074
--   -0.0206
--    0.0170
--    0.0089
--   -0.0196
--    0.0026
--    0.0160
--   -0.0108
--   -0.0086
--    0.0144
--    0.0001
--   -0.0131
--    0.0070
--    0.0083
--   -0.0109
--   -0.0017
--    0.0111
--   -0.0044
--   -0.0079
--    0.0084
--    0.0028
		
		
		
		
		
		
		
		
		
		
		
		
		
		