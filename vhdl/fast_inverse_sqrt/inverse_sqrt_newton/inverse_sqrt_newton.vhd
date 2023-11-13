library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm; 
use lpm.lpm_components.all;

-- Calculates one iteration of the inverse sqrt in fixpoint 16.16 notation: 
--	  y1  = y0 * ( 3/2 - ( x2 * y0 * y0 ) ); 
--
-- where: y0 ... is the previous iteration result
--        x2 ... is the value that you want to solve for
--        y1 ... is the result of this iteration

entity inverse_sqrt_newton is
	port (
		clk   : in std_logic;
		clk_en : in std_logic;
		reset : in std_logic;
		
		y0 : in std_logic_vector(32-1 downto 0);
		x2 : in std_logic_vector(32-1 downto 0);
		y1 : out std_logic_vector(32-1 downto 0)
	);
end entity;

architecture arch of inverse_sqrt_newton is
	constant fixpoint_width : natural := 32;
	constant point_position : natural := 16;
	
	constant threehalfs : std_logic_vector(fixpoint_width-1 downto 0) := 
				std_logic_vector(to_unsigned(0, fixpoint_width-point_position-1)) 
				& "11" 
				& std_logic_vector(to_unsigned(0, point_position-1));
	
	signal y0_y0 : std_logic_vector(32-1 downto 0);
	signal x2_y0_y0 : std_logic_vector(32-1 downto 0);
	signal threehalfs_minus_x2_y0_y0 : std_logic_vector(32-1 downto 0);
	
begin

	-- y0 * y0
	mul1 : entity work.ci_mul
		generic map(width => 32, point => 16, pipeline => 1)
		port map(clk => clk, clk_en => clk_en, reset => reset, dataa => y0, datab => y0, result => y0_y0);
	
	-- x2 * y0 * y0
	mul2 : entity work.ci_mul
		generic map(width => 32, point => 16, pipeline => 1)
		port map(clk => clk, clk_en => clk_en, reset => reset, dataa => x2, datab => y0_y0, result => x2_y0_y0);
		
	-- 3/2 - ( x2 * y0 * y0 )
	sub1 : LPM_ADD_SUB
        generic map(LPM_WIDTH => fixpoint_width, 
			LPM_DIRECTION => "SUB",
			LPM_REPRESENTATION => "SIGNED",
			LPM_PIPELINE => 0,
			LPM_HINT => "ONE_INPUT_IS_CONSTANT")
		port map(DATAA => threehalfs,
			DATAB => x2_y0_y0,
			ACLR => reset,
			CLOCK => clk,
			CLKEN => clk_en,
			CIN => '0',
			RESULT => threehalfs_minus_x2_y0_y0,
			COUT => open,
			OVERFLOW => open);
	
	-- y1 = y0 * ( 3/2 - ( x2 * y0 * y0 ) )
	mul3 : entity work.ci_mul
		generic map(width => 32, point => 16, pipeline => 1)
		port map(clk => clk, clk_en => clk_en, reset => reset, dataa => y0, datab => threehalfs_minus_x2_y0_y0, result => y1);

end architecture;
