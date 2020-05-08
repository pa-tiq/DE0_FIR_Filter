PACKAGE n_bit_int IS    -- User defined types
	SUBTYPE S8i IS INTEGER RANGE -128 TO 127;
	SUBTYPE S8o IS INTEGER RANGE -512 TO 511;
	TYPE AS8i IS ARRAY (0 TO 3) OF S8i;
	TYPE AS8i_32 IS ARRAY (0 TO 31) OF S8i;
END n_bit_int;

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
	x     :   IN  S8i		; -- System input
	y     :   OUT S8o		);-- System output
END fir_filter_4;

ARCHITECTURE fpga OF fir_filter_4 IS
	SIGNAL t1,t2,t3,t4 : S8o;
	SIGNAL tap : AS8i;
BEGIN
	P1: PROCESS(clk, reset, x, tap) -- Behavioral Style	
	BEGIN
		IF reset = '0' THEN   -- clear shift register
			FOR K IN 0 TO 3 LOOP
				tap(K) <= 0;
			END LOOP;			
			y<=0;
			t1<=0;
			t2<=0;
			t3<=0;
			t4<=0;
		ELSIF rising_edge(clk) THEN
		-- Compute output y with the filter coefficients weight.
		-- The coefficients are [-0.5  0.5  0.5  -0.5].
		-- Division for Altera VHDL is only allowed for
		-- powers-of-two values!
			--WAIT UNTIL clk = '1';  -- Pipelined all operations
			t1 <= tap(1) + tap(2); -- Use symmetry of coefficients
			t2 <= tap(0) + tap(3); -- and pipeline adder
			t3 <= t1-t1/2;  --Pipelined CSD multiplier
			t4 <= -t2/2;  -- Build a binary tree and add delay
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
		
		
		
		
		
		
		
		
		
		
		
		
		
		