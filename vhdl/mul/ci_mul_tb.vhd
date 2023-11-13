library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ci_mul_tb is
end entity;

architecture testbench of ci_mul_tb is
	type TestCase_t is (TestReset, Test1, Test2, Test3, EndTests);
	signal TestCase : TestCase_t;

	constant Width : natural := 32;
	constant Point : natural := 16;
	constant Pipeline : natural := 2;

	signal clk : std_logic;
	signal reset : std_logic;
	signal dataa : std_logic_vector(Width-1 downto 0);
	signal datab : std_logic_vector(Width-1 downto 0);
	signal result : std_logic_vector(Width-1 downto 0);
	
	
	constant CLK_PERIOD : time := 10 ns;
	signal stop_clock : boolean := false;
	
	-- test 1
	constant test1_a : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(42, Width - Point)) 
								& std_logic_vector(to_unsigned(0, Point));
	constant test1_b : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(13, Width - Point)) 
								& std_logic_vector(to_unsigned(0, Point));
	constant test1_result : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(42 * 13, Width - Point)) 
								& std_logic_vector(to_unsigned(0, Point));
	
	-- test 2
	constant test2_a : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(42, Width - (Point - 2))) 
								& std_logic_vector(to_unsigned(0, Point - 2));
	constant test2_b : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(13, Width - (Point - 1))) 
								& std_logic_vector(to_unsigned(0, Point - 1));
	constant test2_result : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(42 * 13, Width - (Point - 3))) 
								& std_logic_vector(to_unsigned(0, Point - 3));
		
	-- test 3					
	constant pi : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(205887, Width));
	constant e : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(178145, Width));
	
begin

	uut : entity work.ci_mul
		generic map(
			width => Width, 
			point => Point, 
			pipeline => Pipeline)
		port map(
			clk => clk, 
			clk_en => '1', 
			reset => reset, 
			dataa => dataa, 
			datab => datab, 
			result => result);
	
	stimulus : process
	begin
	
		TestCase <= TestReset;
		reset <= '1';
		dataa <= (others=> '0');
		datab <= (others=> '0');
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		reset <= '0';
		
		TestCase <= Test1;
		dataa <= test1_a;
		datab <= test1_b;
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert (result = test1_result) report "multiplication of two natural" severity error;
		
		TestCase <= Test2;
		dataa <= test2_a;
		datab <= test2_b;
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		assert (result = test2_result) report "multiplication of two rational" severity error;
		
		TestCase <= Test3;
		dataa <= pi;
		datab <= e;
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		
		
		TestCase <= EndTests;
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		stop_clock <= true; -- end simulation
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

