library ieee;
use ieee.std_logic_1164.all;	-- log2(512) = 9
use ieee.numeric_std.all;		-- 20+9-1 = 28

entity fir_filter_4 is
	generic( 
		Win : INTEGER := 10; -- Input bit width
		Wmult : INTEGER := 20;-- Multiplier bit width 2*W1
		Wadd : INTEGER := 28;-- Adder width = Wmult+log2(L)-1
		Wout : INTEGER := 12;-- Output bit width
		BUTTON_HIGH : STD_LOGIC := '0';
		LFilter  : INTEGER := 513); -- Filter length
	port (
		clk    : IN STD_LOGIC;  -- System clock
		reset  : IN STD_LOGIC;  -- Asynchron reset
		Load_x : IN  STD_LOGIC;  -- Load/run switch
		x_in   : IN  STD_LOGIC_VECTOR(Win-1 DOWNTO 0);-- System input
		c_in   : IN  STD_LOGIC_VECTOR(Win-1 DOWNTO 0);-- Coefficient data input
		y_out  : OUT STD_LOGIC_VECTOR(Wout-1 DOWNTO 0));-- System output 
end fir_filter_4;

ARCHITECTURE fpga OF fir_filter_4 IS
	SUBTYPE SLV_Win IS STD_LOGIC_VECTOR(Win-1 DOWNTO 0);
	SUBTYPE SLV_Wmult IS STD_LOGIC_VECTOR(Wmult-1 DOWNTO 0);
	SUBTYPE SLV_Wadd IS STD_LOGIC_VECTOR(Wadd-1 DOWNTO 0);
	TYPE ARR_SLV_Win IS ARRAY (0 TO L-1) OF SLV_Win;
	TYPE ARR_SLV_Wmult IS ARRAY (0 TO L-1) OF SLV_Wmult;
	TYPE ARR_SLV_Wadd IS ARRAY (0 TO L-1) OF SLV_Wadd;
	SIGNAL  x  :  SLV_Win;
	SIGNAL  y  :  SLV_Wadd;
	SIGNAL  c  :  ARR_SLV_Win ; -- Coefficient array
	SIGNAL  p  :  ARR_SLV_Wmult ; -- Product array
	SIGNAL  a  :  ARR_SLV_Wadd ; -- Adder array

BEGIN
	Load: PROCESS(clk, reset, c_in, c, x_in) 
	BEGIN    ------> Load data or coefficients
		IF reset = BUTTON_HIGH THEN -- clear data and coefficients reg
			x <= (OTHERS => '0');
			FOR K IN 0 TO L-1 LOOP
				c(K) <= (OTHERS => '0');
			END LOOP;
		ELSIF rising_edge(clk) THEN
			IF Load_x = '1' THEN
				c(L-1) <= c_in;  -- Store coefficient in register
				FOR I IN L-2 DOWNTO 0 LOOP  -- Coefficients shift one
					c(I) <= c(I+1);
				END LOOP;
			ELSE
				x <= x_in;  -- Get one data sample at a time
			END IF;
		END IF;
	END PROCESS Load;
	
	SOP: PROCESS (clk, reset, a, p)-- Compute sum-of-products
	BEGIN
		IF reset = BUTTON_HIGH THEN -- clear tap registers
			FOR K IN 0 TO L-1 LOOP
				a(K) <= (OTHERS => '0');
			END LOOP;
		ELSIF rising_edge(clk) THEN
			FOR I IN 0 TO L-2  LOOP -- Compute the transposed
				a(I) <= (p(I)(Wmult-1) & p(I)) + a(I+1); -- filter adds
			END LOOP;
			a(L-1) <= p(L-1)(Wmult-1) & p(L-1); -- First TAP has only a register
		END IF;                              
		y <= a(0);
	END PROCESS SOP;
	
	-- Instantiate L multipliers
	
	MulGen: FOR I IN 0 TO L-1 GENERATE
		p(i) <= c(i) * x;
	END GENERATE;
	
	y_out <= y(Wadd-1 DOWNTO Wadd-Wout);
	
END fpga;
			
