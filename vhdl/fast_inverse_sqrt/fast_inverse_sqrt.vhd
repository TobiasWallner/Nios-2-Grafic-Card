library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm; 
use lpm.lpm_components.all;

-- this is a hardware implementation of the "fast inverse square root" algorithm from 
-- the computergame Quake 3

entity fast_inverse_sqrt is
	port (
		clk   : in std_logic;
		clk_en : in std_logic;
		reset : in std_logic;
		
		value_in : in std_logic_vector(32-1 downto 0); 
		value_out : out std_logic_vector(32-1 downto 0)
	);
end entity;

architecture arch of fast_inverse_sqrt is
	
	constant fixpoint_width : natural := 32;
	constant point_position : natural := 16;
	
	constant mantissa_width : natural := 30;
	constant exponent_width : natural := 6;
	constant float_width : natural := mantissa_width + exponent_width;

	constant two_pow_mantissa_width : unsigned := unsigned(std_logic_vector(to_unsigned(0, exponent_width)) & '1' & std_logic_vector(to_unsigned(0, mantissa_width)));
	constant mu : unsigned := to_unsigned(0, 1);
	constant exponent_offset_u : unsigned := to_unsigned(31, exponent_width);	
	constant wtf_number_u : unsigned := (3 * two_pow_mantissa_width * (exponent_offset_u + mu)) / 2;
	constant wtf_number : std_logic_vector(float_width - 1 downto 0) := std_logic_vector(wtf_number_u(float_width - 1 downto 0));

	signal float_in : std_logic_vector(float_width - 1 downto 0);
	signal float_in_rshift : std_logic_vector(float_width-1 downto 0);

	signal x2 : std_logic_vector(fixpoint_width-1 downto 0);

	signal float_y0 : std_logic_vector(float_width-1 downto 0);
	signal y0 : std_logic_vector(fixpoint_width-1 downto 0);
begin
	
-- The fast inverse square root algorithm	
-- https://en.wikipedia.org/wiki/Fast_inverse_square_root
--
--	  long i;
--	  float x2, y;
--	  const float threehalfs = 1.5F;
--	  x2 = number * 0.5F;
--	  y  = number;
--	  i  = * ( long * ) &y;                       // evil floating point bit level hacking
--	  i  = 0x5f3759df - ( i >> 1 );               // what the fuck?
--	  y  = * ( float * ) &i;
--	  y  = y * ( threehalfs - ( x2 * y * y ) );   // 1st iteration
--	  // y  = y * ( threehalfs - ( x2 * y * y ) );   // 2nd iteration, this can be removed
--	  return y;
	
	-- x2 = number * 0.5F;
	x2 <= '0' & value_in(fixpoint_width-1 downto 1); -- halfing in fixpoint is shift to the right
	
	-- i  = * ( long * ) &y;  
	fix_to_float : entity work.ufixpoint_to_ufloat port map (fixpoint_in => value_in, float_out => float_in);
	
	-- ( i >> 1 )
	float_in_rshift <= '0' & float_in(float_width-1 downto 1); -- evil floating point bit level hacking
	
	-- i = 0x5f3759df - ( i >> 1 );   
	wtf_subtraction : LPM_ADD_SUB
        generic map(LPM_WIDTH => float_width, 
			LPM_DIRECTION => "SUB",
			LPM_REPRESENTATION => "UNSIGNED",
			LPM_PIPELINE => 0,
			LPM_HINT => "ONE_INPUT_IS_CONSTANT")
		port map(DATAA => wtf_number,
			DATAB => float_in_rshift,
			ACLR => reset,
			CLOCK => clk,
			CLKEN => '1',
			CIN => '0',
			RESULT => float_y0,
			COUT => open,
			OVERFLOW => open);
			
	-- y  = * ( float * ) &i;
	float_to_fix : entity work.ufloat_to_ufixpoint port map (float_in => float_y0, fixpoint_out => y0);
	
	-- y  = y * ( threehalfs - ( x2 * y * y ) ); 
	newton1 : entity work.inverse_sqrt_newton 
		port map(
		clk => clk,
		clk_en => '1',
		reset => reset,
		y0 => y0,
		x2 => x2,
		y1 => value_out
	);
	
end architecture;
