-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


LIBRARY lpm;
USE lpm.lpm_components.all;

entity ci_mul is
	generic (
		width : natural := 32;
		point : natural := 16;
		pipeline : natural := 1
	);
	port (
		clk   : in std_logic;
		clk_en : in std_logic;
		reset : in std_logic;
		
		dataa : in std_logic_vector(width-1 downto 0); 
		datab : in std_logic_vector(width-1 downto 0);
		result : out std_logic_vector(width-1 downto 0)
	);
end entity;

architecture arch of ci_mul is 

	signal internal_mul_result : std_logic_vector(width*2-1 downto 0); 

begin
	mul : LPM_MULT 
		generic map (LPM_WIDTHA => width, LPM_WIDTHB => width, LPM_WIDTHP => 2*width, LPM_PIPELINE => pipeline,
						LPM_REPRESENTATION => "SIGNED")
		port map (dataa => dataa, datab => datab, clock => clk, clken => clk_en, aclr => reset, result => internal_mul_result);
	
	result <= internal_mul_result(point+width-1 downto point);
end architecture;


