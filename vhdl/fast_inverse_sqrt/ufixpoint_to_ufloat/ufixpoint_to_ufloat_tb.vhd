library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ufixpoint_to_ufloat_tb is
end entity;

architecture testbench of ufixpoint_to_ufloat_tb is
	constant CLK_PERIOD : time := 10 ns;
	signal clk : std_logic;
	signal stop_clock : boolean := false;
	
	constant fixpoint_width : natural := 32;
	constant point_position : natural := 16;
	constant mantissa_width : natural := 30;
	constant exponent_width : natural := 6;
	
	signal fixpoint : std_logic_vector(fixpoint_width-1 downto 0);
	signal float : std_logic_vector(exponent_width + mantissa_width - 1 downto 0);
	
begin

	uut : entity work.ufixpoint_to_ufloat
			port map (
				fixpoint_in => fixpoint,
				float_out => float
			);
	
	stimulus : process
	begin
	
	-- down shifting
	
	fixpoint <= std_logic_vector(to_unsigned(0, fixpoint_width - point_position)) & std_logic_vector(to_unsigned(0, point_position));
	wait until rising_edge(clk);
	assert float = "000000000000000000000000000000000000" severity error;

	fixpoint <= std_logic_vector(to_unsigned(1, fixpoint_width - point_position)) & std_logic_vector(to_unsigned(0, point_position));
	wait until rising_edge(clk);
	assert float = "011111000000000000000000000000000000" severity error;
	
	fixpoint <= std_logic_vector(to_unsigned(1, fixpoint_width - point_position + 1)) & std_logic_vector(to_unsigned(0, point_position - 1));
	wait until rising_edge(clk);
	assert float = "011110000000000000000000000000000000" severity error;
	
	fixpoint <= std_logic_vector(to_unsigned(1, fixpoint_width - point_position + 2)) & std_logic_vector(to_unsigned(0, point_position - 2));
	wait until rising_edge(clk);
	assert float = "011101000000000000000000000000000000" severity error;
	
	fixpoint <= std_logic_vector(to_unsigned(1, fixpoint_width - point_position + 3)) & std_logic_vector(to_unsigned(0, point_position - 3));
	wait until rising_edge(clk);
	assert float = "011100000000000000000000000000000000" severity error;
	
	fixpoint <= std_logic_vector(to_unsigned(1, fixpoint_width - point_position + 4)) & std_logic_vector(to_unsigned(0, point_position - 4));
	wait until rising_edge(clk);
	assert float = "011011000000000000000000000000000000" severity error;
	
	fixpoint <= std_logic_vector(to_unsigned(2, fixpoint_width));
	wait until rising_edge(clk);
	assert float = "010000000000000000000000000000000000" severity error;
	
	fixpoint <= std_logic_vector(to_unsigned(1, fixpoint_width));
	wait until rising_edge(clk);
	assert float = "001111000000000000000000000000000000" severity error;
	
	
	
	
	-- up shifting

	fixpoint <= std_logic_vector(to_unsigned(1, fixpoint_width - point_position)) & std_logic_vector(to_unsigned(0, point_position));
	wait until rising_edge(clk);
	assert float = "011111000000000000000000000000000000" severity error;
	
	fixpoint <= std_logic_vector(to_unsigned(1, fixpoint_width - point_position - 1)) & std_logic_vector(to_unsigned(0, point_position + 1));
	wait until rising_edge(clk);
	assert float = "100000000000000000000000000000000000" severity error;
	
	fixpoint <= std_logic_vector(to_unsigned(1, fixpoint_width - point_position - 2)) & std_logic_vector(to_unsigned(0, point_position + 2));
	wait until rising_edge(clk);
	assert float = "100001000000000000000000000000000000" severity error;
	
	fixpoint <= std_logic_vector(to_unsigned(1, fixpoint_width - point_position - 3)) & std_logic_vector(to_unsigned(0, point_position + 3));
	wait until rising_edge(clk);
	assert float = "100010000000000000000000000000000000" severity error;
	
	fixpoint <= std_logic_vector(to_unsigned(1, fixpoint_width - point_position - 4)) & std_logic_vector(to_unsigned(0, point_position + 4));
	wait until rising_edge(clk);
	assert float = "100011000000000000000000000000000000" severity error;
	
	fixpoint <= "01" & std_logic_vector(to_unsigned(0, fixpoint_width-2));
	wait until rising_edge(clk);
	assert float = "101101000000000000000000000000000000" severity error;
	
	fixpoint <= "1" & std_logic_vector(to_unsigned(0, fixpoint_width-1));
	wait until rising_edge(clk);
	assert float = "101110000000000000000000000000000000" severity error;
	
	-- random numbers
	fixpoint <= std_logic_vector(to_unsigned(13, fixpoint_width - point_position)) & std_logic_vector(to_unsigned(0, point_position));
	wait until rising_edge(clk);
	assert float = "100010101000000000000000000000000000" severity error;
	
	fixpoint <= std_logic_vector(to_unsigned(14758, fixpoint_width - point_position)) & std_logic_vector(to_unsigned(0, point_position));
	wait until rising_edge(clk);
	assert float = "101100110011010011000000000000000000" severity error;
	
	fixpoint <= std_logic_vector(to_unsigned(0, fixpoint_width - point_position)) & std_logic_vector(to_unsigned(111, point_position));
	wait until rising_edge(clk);
	assert float = "010101101111000000000000000000000000" severity error;
	
	wait until rising_edge(clk);
	-- end simulation
		stop_clock <= true; 
		wait;
	end process;
	
	clk_generator : process
	begin
		while (not stop_clock) loop
			clk <= '0';
			wait for CLK_PERIOD / 2;
			clk <= '1';
			wait for CLK_PERIOD / 2;
		end loop;
		wait;
	end process clk_generator;
	
end architecture;

