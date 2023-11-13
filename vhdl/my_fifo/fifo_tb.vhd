library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_tb is
end entity;

architecture testbench of fifo_tb is
	signal TestCase : natural;
	constant CLK_PERIOD : time := 10 ns;
	signal stop_clock : boolean := false;

	constant Width : natural := 8;
	constant NumElements : natural := 3;

	signal clk : std_logic;
	signal reset : std_logic;
	signal write_data : std_logic_vector(Width-1 downto 0);
	signal read_request : std_logic;
	signal write_request : std_logic;
	signal empty : std_logic;
	signal full : std_logic;
	signal read_data : std_logic_vector(Width-1 downto 0);
	
	-- test1 write data, read data
	constant test1_write_data : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(8, Width));
	
	-- test2 write twice, read twice
	constant test2_write_data_1 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(9, Width));
	constant test2_write_data_2 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(12, Width));
	constant test2_write_data_3 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(52, Width));
	
	-- test3 write read on empty
	constant test3_write_data_1 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(55, Width));
	
	-- test4 write read on full
	constant test4_write_data_1 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(9, Width));
	constant test4_write_data_2 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(12, Width));
	constant test4_write_data_3 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(52, Width));
	constant test4_write_data_4 : std_logic_vector(Width-1 downto 0) := std_logic_vector(to_unsigned(53, Width));
	
begin

	uut : entity work.my_fifo
		generic map (DATA_WIDTH => Width, NUM_ELEMENTS => NumElements)
		port map(	areset => reset, clock => clk, 
					write_data => write_data, write_request => write_request, 
					read_data => read_data, read_request => read_request,
					empty => empty, full => full);
	
	stimulus : process
	begin
		TestCase <= 0;
		reset <= '1';
		write_data <= (others=> '0');
		read_request <= '0';
		write_request <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		reset <= '0';
		
	-- test 1
		TestCase <= 1;
		-- write
		write_data <= test1_write_data;
		write_request <= '1';
		wait until rising_edge(clk);
		write_request <= '0';
		-- read
		write_request <= '0';
		read_request <= '1';
		wait until rising_edge(clk);
		read_request <= '0';
		assert (test1_write_data = read_data) report "test 1: wrong read result" severity error;
		
	-- test 2 write untill full and read until empty
		TestCase <= 2;
		-- write
		write_data <= test2_write_data_1;
		write_request <= '1';
		wait until rising_edge(clk);
		-- write
		write_data <= test2_write_data_2;
		write_request <= '1';
		wait until rising_edge(clk);
		-- write
		write_data <= test2_write_data_3;
		write_request <= '1';
		wait until rising_edge(clk);
		-- read
		write_request <= '0';
		read_request <= '1';
		wait until rising_edge(clk);
		read_request <= '0';
		assert (test2_write_data_1 = read_data) report "test 2: wrong read result 1" severity error;
		-- read
		write_request <= '0';
		read_request <= '1';
		wait until rising_edge(clk);
		read_request <= '0';
		assert (test2_write_data_2 = read_data) report "test 2: wrong read result 2" severity error;
		-- read
		write_request <= '0';
		read_request <= '1';
		wait until rising_edge(clk);
		read_request <= '0';
		assert (test2_write_data_3 = read_data) report "test 2: wrong read result 3" severity error;

	-- test3
		TestCase <= 3;
		write_data <= test3_write_data_1;
		write_request <= '1';
		read_request <= '0';
		wait until rising_edge(clk);
		-- write + read
		write_data <= test3_write_data_1;
		write_request <= '1';
		read_request <= '1';
		wait until rising_edge(clk);
		write_request <= '0';
		read_request <= '0';
		assert (test3_write_data_1 = read_data) report "test3: wrong read result 1" severity error;
		write_data <= test3_write_data_1;
		write_request <= '0';
		read_request <= '1';
		wait until rising_edge(clk);
		
	-- test4
		TestCase <= 4;
		-- write
		write_data <= test4_write_data_1;
		write_request <= '1';
		read_request <= '0';
		wait until rising_edge(clk);
		write_data <= test4_write_data_2;
		wait until rising_edge(clk);
		write_data <= test4_write_data_3;
		wait until rising_edge(clk);
		
		-- write + read
		write_data <= test4_write_data_4;
		write_request <= '1';
		read_request <= '1';
		wait until rising_edge(clk);
		
		write_request <= '0';
		read_request <= '0';
		assert (test4_write_data_1 = read_data) report "test4: wrong read result 1" severity error;
		
		-- read
		write_request <= '0';
		read_request <= '1';
		wait until rising_edge(clk);
		read_request <= '0';
		assert (test4_write_data_2 = read_data) report "test4: wrong read result 2" severity error;
		-- read
		write_request <= '0';
		read_request <= '1';
		wait until rising_edge(clk);
		read_request <= '0';
		assert (test4_write_data_3 = read_data) report "test4: wrong read result 3" severity error;
		-- read
		write_request <= '0';
		read_request <= '1';
		wait until rising_edge(clk);
		read_request <= '0';
		assert (test4_write_data_4 = read_data) report "test4: wrong read result 4" severity error;

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

