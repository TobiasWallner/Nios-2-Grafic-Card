
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY lpm; 
USE lpm.lpm_components.all;

-- convertes an unsigned fixpoint number to an unsigned floating point number
--	output:  
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
-- input:
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


entity ufloat_to_ufixpoint is
	port (
		float_in : in std_logic_vector(6 + 30 - 1 downto 0);
		fixpoint_out : out std_logic_vector(32-1 downto 0) 
	);
end entity;

architecture arch of ufloat_to_ufixpoint is
	
	constant fixpoint_width : integer := 32;
	constant point_position : integer := 16;
	constant mantissa_width : integer := 30;
	constant exponent_width : integer := 6;
	constant float_width : integer := exponent_width + mantissa_width;
	constant exponent_offset : integer := 31;
	
	signal exponent : std_logic_vector(exponent_width-1 downto 0);
	signal mantissa : std_logic_vector(mantissa_width-1 downto 0);
	
begin

	exponent <= float_in(float_width-1 downto float_width-exponent_width);
	mantissa <= float_in(float_width-exponent_width-1 downto 0);
	
	process(all) begin
		fixpoint_out <= (others=>'0');
		
		-- special case in for loop
		if exponent = std_logic_vector(to_unsigned(-16 + exponent_offset, exponent_width)) then
			fixpoint_out(0) <= '1';
		end if;
		
		for i in -15 to 14 loop
			if exponent = std_logic_vector(to_unsigned(i + exponent_offset, exponent_width)) then
				fixpoint_out(i + point_position) <= '1';
				fixpoint_out(i + point_position-1 downto 0) <= mantissa(mantissa_width-1 downto mantissa_width-(i+point_position));
			end if; 
		end loop;
		
		-- special case in for loop
		if exponent = std_logic_vector(to_unsigned(15 + exponent_offset, exponent_width)) then
			fixpoint_out(fixpoint_width-1) <= '1';
			fixpoint_out(fixpoint_width-2 downto 1) <= mantissa;
		end if;

	end process;
	
end architecture;
