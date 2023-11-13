library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mm_avalon_sqrt_tb is
end entity;

architecture testbench of mm_avalon_sqrt_tb is
	signal TestCase : natural;
	
	constant CLK_PERIOD : time := 10 ns;
	signal clk : std_logic;
	signal reset : std_logic;
	signal stop_clock : boolean := false;
	
	
	constant width : natural := 32;
	constant point : natural := 16;
	constant pipeline : natural := 3;
	
	signal address   : std_logic_vector(0 downto 0);
	signal write     : std_logic;
	signal read      : std_logic;
	signal writedata : std_logic_vector(width-1 downto 0);
	signal readdata  : std_logic_vector(width-1 downto 0);
	
	constant test1_value : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(169, Width - Point)) 
								& std_logic_vector(to_unsigned(0, Point));
	constant test1_result : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(13, Width - Point)) 
								& std_logic_vector(to_unsigned(0, Point));
	
begin

	uut : entity work.avalon_mm_sqrt
		generic map (	width => width, 
						point => point, 
						pipeline => pipeline)
		port map (	clk => clk,
					res_n => reset,
		
					--memory mapped slave
					address => address,
					write => write,
					read => read,
					writedata => writedata,
					readdata => readdata);
	
	stimulus : process
	begin
		TestCase <= 0;
		reset <= '0';
		address <= (others => '0');
		write <= '0';
		read <= '0';
		writedata <= (others => '0');
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		reset <= '1';
		
	-- test 1 write data and check status flag:
		TestCase <= 1;
		
		-- write data
		address <= "0";
		write <= '1';
		read <= '1';
		writedata <= test1_value;
		wait until rising_edge(clk);
		assert readdata(0) = '1' report "Test1-1: statusflag should be '1' signaling empty" severity error;
		-- read status
		address <= "0";
		write <= '0';
		read <= '1';
		wait until rising_edge(clk);
		assert readdata(0) = '1' report "Test1-2: statusflag should be '1' signaling empty" severity error;
		wait until rising_edge(clk);
		assert readdata(0) = '0' report "Test1-3: statusflag should be '0' there is no result but in the next cycle when you read it there will be" severity error;
		
		-- using the 'data is about to be ready' trick together with result forwarding (skipping the fifo entirely) saves two clock cycles 
		-- wait until rising_edge(clk);
		-- assert readdata(0) = '0' report "Test1-4: statusflag should be '0' signaling data" severity error;
		-- wait until rising_edge(clk);

	-- test 2 read data result of the calculation
		TestCase <= 2;
		--read data
		address <= "1";
		write <= '0';
		read <= '1';
		wait until rising_edge(clk);
		read <= '0';
		assert (readdata = test1_result) report "test 2-2: square error sqr(169) != 13" severity error;
		
	
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

