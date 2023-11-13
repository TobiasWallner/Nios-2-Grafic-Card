
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY lpm; 
USE lpm.lpm_components.all;

-- convertes an unsigned fixpoint number to an unsigned floating point number
--	input:  
--	+-------------------------------+
--	|		fixpoint_width			|
--	+---------------+---------------+
--	|          		| point_position|
--	+-------------------------------+
--	|		fixpoint_in				|
--	+---------------+---------------+
--	|     decimal   .  number    	|
--	+----------+--------------------+
--	
--  represented number: fixpoint_in * 2 ^ (-point_position)
--
-- output:
--	+----------------+----------------+
--	| exponent_width | mantissa_width |
--	+----------------+----------------+
--	|    exponent    |     mantissa   |
--	+----------------+----------------+
--	| 			float_out 			  |
--	+----------------+----------------+
--
-- represented number: mantissa * 2 ^ (exponent - 2^(exponent_width-1) - 1)
--
-- The exponent needs at least a bit width of: exponent_width = log_2(fixpoint_width)+1


entity ufixpoint_to_ufloat is
	port (
		fixpoint_in : in std_logic_vector(32-1 downto 0); 
		float_out : out std_logic_vector(6 + 30 - 1 downto 0)
	);
end entity;

architecture arch of ufixpoint_to_ufloat is

	constant fixpoint_width : natural := 32;
	constant point_position : natural := 16;
	constant mantissa_width : natural := 30;
	constant exponent_width : natural := 6;

	constant max_exponent : std_logic_vector(exponent_width-1 downto 0) := (others=>'1');
	constant min_exponent : std_logic_vector(exponent_width-1 downto 0) := (others=>'0');
	constant exponent_offset : std_logic_vector(exponent_width-1 downto 0) := '0' & max_exponent(exponent_width-2 downto 0);
	constant exponent_offset_int : integer := to_integer(unsigned(exponent_offset));
	constant pre_calc: integer := fixpoint_width - 1 + exponent_offset_int - point_position;
 
	signal mantissa : std_logic_vector(mantissa_width-1 downto 0); 
	signal exponent : std_logic_vector(exponent_width-1 downto 0);

begin
	combinatorical : process(fixpoint_in) begin
		exponent <= (others=>'0');
		mantissa <= (others=>'0');
		
		if fixpoint_in(fixpoint_width - 1) = '1' then
			exponent <= std_logic_vector(to_signed(((fixpoint_width + exponent_offset_int) - point_position) - (0+1) , exponent_width));
			mantissa <= fixpoint_in(fixpoint_width-2 downto 1);
		else
			for i in 1 to fixpoint_width-1 loop exit when (fixpoint_in(fixpoint_width - i) = '1');
		  		if(fixpoint_in(fixpoint_width-1 - i) = '1') then 
					exponent <= std_logic_vector(to_unsigned(pre_calc - i, exponent_width));
					mantissa(mantissa_width-1 downto mantissa_width-(fixpoint_width-(i+1))) <= fixpoint_in(fixpoint_width-1 - (i+1) downto 0);
				end if;
			end loop;
		end if;
	end process combinatorical;
	float_out <= exponent & mantissa;
	
end architecture;
