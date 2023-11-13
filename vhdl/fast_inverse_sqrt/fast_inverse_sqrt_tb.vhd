library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity fast_inverse_sqrt_tb is
end entity;

architecture testbench of fast_inverse_sqrt_tb is
	constant CLK_PERIOD : time := 10 ns;
	signal clk : std_logic;
	signal clk_en : std_logic;
	signal reset : std_logic;
	signal stop_clock : boolean := false;
	
	constant fixpoint_width : natural := 32;
	constant point_position : natural := 16;
	
	signal value_in : std_logic_vector(fixpoint_width-1 downto 0);
	signal value_out : std_logic_vector(fixpoint_width-1 downto 0);
	signal value_expected : std_logic_vector(fixpoint_width-1 downto 0); 
	
begin
   
	uut : entity work.fast_inverse_sqrt
		port map(clk => clk, clk_en => clk_en, reset => reset, value_in => value_in,  value_out => value_out);
	
	stimulus : process 
	
		file source_file : text open read_mode is "tb_source.txt";
		file expected_file : text open read_mode is "tb_expected.txt";
		file result_file : text open write_mode is "tb_result.txt";
		
		variable source_line : line; 
		variable expected_line : line;
		variable result_line : line;
		
		variable source_vec_var  : std_logic_vector(fixpoint_width-1 downto 0);  
		variable expected_vec_var  : std_logic_vector(fixpoint_width-1 downto 0);  
		variable result_vec_var  : std_logic_vector(fixpoint_width-1 downto 0);  
	
	begin
	
		-- reset the module
		value_in <= (others=>'0');
		reset <= '1';
		clk_en <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		reset <= '0';
		clk_en <= '1';	
		
		while not endfile(source_file) and not endfile(expected_file) loop
			-- read the input and expected output vector
			readline(source_file, source_line); -- read a line
			bread(source_line, source_vec_var); -- convert line to std_logic_vector variable in binary
			value_in <= source_vec_var; -- write vector variable to the signal
			
			readline(expected_file, expected_line);
			hread(expected_line, expected_vec_var);
			value_expected <= expected_vec_var;
			
			-- wait some clocks to make sure the calculation is finished -- may be pipelined later
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			wait until rising_edge(clk);

			assert value_out = value_expected severity error;
			
			-- write result file
			bwrite(result_line, value_out); -- convert vector to line variable in binary
			writeline(result_file, result_line); -- write line
		end loop;
		
		-- end simulation
		wait until rising_edge(clk);
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

