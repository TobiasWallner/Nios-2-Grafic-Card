library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ci_div_tb is
end entity;

architecture testbench of ci_div_tb is
	signal TestCase : natural;
	
	constant CLK_PERIOD : time := 10 ns;
	signal clk : std_logic;
	signal stop_clock : boolean := false;
	
	constant width : natural := 32;
	constant point : natural := 16;
	constant pipeline : natural := 3;
	
	signal reset : std_logic;
	signal dataa : std_logic_vector(width-1 downto 0); 
	signal datab : std_logic_vector(width-1 downto 0);
	signal result : std_logic_vector(width-1 downto 0);

	signal start : std_logic;
	signal done : std_logic;
	
	signal n : std_logic_vector(0 downto 0); 
	
	constant test1_a1 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(42, Width - Point)) 
								& std_logic_vector(to_unsigned(0, Point));
	constant test1_b1 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(13, Width - Point)) 
								& std_logic_vector(to_unsigned(0, Point));
	constant test1_result1 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(42 * 65536 / 13, Width)); 
								
	constant test1_a2 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(85, Width - Point)) 
								& std_logic_vector(to_unsigned(0, Point));
	constant test1_b2 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(35, Width - Point)) 
								& std_logic_vector(to_unsigned(0, Point));
	constant test1_result2 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(85* 65536 / 35, Width));
								
								
	constant test1_a3 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(234, Width - Point)) 
								& std_logic_vector(to_unsigned(0, Point));
	constant test1_b3 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(6, Width - Point)) 
								& std_logic_vector(to_unsigned(0, Point));
	constant test1_result3 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(234 * 65536 / 6, Width));
	
begin

	uut : entity work.ci_div
		generic map (	width => width, 
						point => point, 
						pipeline => pipeline)
		port map (	clk => clk,
					clk_en => '1',
					reset => reset,
					dataa => dataa,
					datab => datab,
					result => result,
					start => start,
					done => done,
					n => n);
	
	stimulus : process
	begin
		TestCase <= 0;
		reset <= '1';
		dataa <= (others => '0');
		datab <= (others => '0');
		start <= '0';
		n <= "0";
		wait until rising_edge(clk);
		assert or result = '0' report "Reset: result should be zero" severity error;
		assert done = '0' report "Reset: done should be zero" severity error;
		wait until rising_edge(clk);
		reset <= '0';
		
		
		
	-- test 1: issue three divisions
		TestCase <= 1;
		n <= "0"; -- calc_request
		start <= '1';
		dataa <= test1_a1;
		datab <= test1_b1;
		wait until rising_edge(clk);
		assert done = '1' report "Test1: issue calculation 1 should be done" severity error;
		
		dataa <= test1_a2;
		datab <= test1_b2;
		wait until rising_edge(clk);
		assert done = '1' report "Test1: issue calculation 2 should be done" severity error;
		
		dataa <= test1_a3;
		datab <= test1_b3;
		wait until rising_edge(clk);
		assert done = '1' report "Test1: issue calculation 3 should be done" severity error;
		start <= '0';
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		
	-- test 2 read three divisions
		TestCase <= 2;
		n <= "1"; -- read_request
		start <= '1';
		wait until rising_edge(clk);
		assert (result = test1_result1) report "test2: read result 1" severity error;
		assert done = '1' 				report "Test2: read result 1 should be done" severity error;
		wait until rising_edge(clk);
		assert (result = test1_result2) report "test2: read result 2" severity error;
		assert done = '1' 				report "Test2: read result 1 should be done" severity error;
		wait until rising_edge(clk);
		start <= '0';
		assert (result = test1_result3) report "test2: read result 3" severity error;
		assert done = '1' 				report "Test2: read result 1 should be done" severity error;
		
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		
	-- test3: stall
		TestCase <= 3;
		n <= "0"; -- calc_request
		start <= '1';
		dataa <= test1_a1;
		datab <= test1_b1;
		wait until rising_edge(clk);
		assert done = '1' 				report "Test3-1: issue calc request should be done" severity error;
		
		n <= "1"; -- read_request
		start <= '1';
		wait until rising_edge(clk);
		start <= '0';
		assert done = '0' 				report "Test3-2: read request should stall and not be done" severity error;
		
		wait until rising_edge(clk);
		assert done = '0' 				report "Test3-3: read request should stall and not be done" severity error;
		wait until rising_edge(clk);
		assert done = '1' 				report "Test3-4: read request should be done" severity error;
		assert (result = test1_result1) report "Test3-4: division should yield result" severity error;
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		
	-- test 4: read an unstalled division
		TestCase <= 4;
		-- calc_request
		n <= "0";
		start <= '1';
		dataa <= test1_a2;
		datab <= test1_b2;
		wait until rising_edge(clk);
		start <= '0';
		assert done = '1' 				report "Test4-1: calculation should be done" severity error;
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);

		-- read_request
		n <= "1"; 
		start <= '1';
		wait until rising_edge(clk);
		start <= '0';
		assert done = '1' 				report "Test4-6: read request should be done immeditelly" severity error;
		assert (result = test1_result2) report "Test4-6: division has wrong result" severity error;
		


		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		
		-- test 5: issue three divisions then reest
		TestCase <= 5;
		reset <= '1';
		wait until rising_edge(clk);
		reset <= '0';
		
		n <= "0"; -- calc_request
		start <= '1';
		dataa <= test1_a1;
		datab <= test1_b1;
		wait until rising_edge(clk);
		assert done = '1' report "Test5: issue calculation 1 should be done" severity error;
		
		dataa <= test1_a2;
		datab <= test1_b2;
		wait until rising_edge(clk);
		assert done = '1' report "Test5: issue calculation 2 should be done" severity error;
		
		dataa <= test1_a3;
		datab <= test1_b3;
		wait until rising_edge(clk);
		assert done = '1' report "Test5: issue calculation 3 should be done" severity error;
		start <= '0';
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		
		reset <= '1';
		wait until rising_edge(clk);
		reset <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
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

