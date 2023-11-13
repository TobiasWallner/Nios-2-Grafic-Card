-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library lpm;
use lpm.lpm_components.all;

entity ci_div is
	generic (
		width : natural := 32;
		point : natural := 16;
		pipeline : natural := 48
	);
	port (
		clk   : in std_logic;
		clk_en : in std_logic;
		reset : in std_logic;
		
		dataa : in std_logic_vector(width-1 downto 0); 
		datab : in std_logic_vector(width-1 downto 0);
		result : out std_logic_vector(width-1 downto 0);

		start : in std_logic;
		done : out std_logic;
		
		n : in std_logic_vector(0 downto 0)
	);
end entity;


architecture arch of ci_div is
	type state_t is (WaitOnInstruction, ReadStall);
	signal state : state_t;
	signal next_state : state_t;

	signal calc_instruction : std_logic;
	signal read_instruction : std_logic;
	
	signal assigned_calculation : std_logic;

	signal numerator : std_logic_vector(width+point-1 downto 0); 
	signal denominator : std_logic_vector(width-1 downto 0);
	
	signal div_numerator : std_logic_vector(width+point-1 downto 0); 
	signal div_denominator : std_logic_vector(width-1 downto 0);
	signal div_numerator_previous : std_logic_vector(width+point-1 downto 0); 
	signal div_denominator_previous : std_logic_vector(width-1 downto 0);
	
	signal quotient : std_logic_vector(width+point-1 downto 0);
	signal quotient_trimmed  : std_logic_vector(width-1 downto 0); 
	-- signal remainder : std_logic_vector(width-1 downto 0); 

	signal pipeline_status : std_logic_vector(pipeline-1 downto 0); -- tracks progression of data in the pipeline
	signal pipeline_working_set : std_logic_vector(pipeline-2 downto 0);
	constant pipeline_working_set_zeros : std_logic_vector(pipeline-2 downto 0) := (others=>'0');
	signal pipeline_working : std_logic;
	signal quotient_ready : std_logic;
	
	signal fifo_read_data : std_logic_vector(width-1 downto 0);
	signal fifo_write_request : std_logic;
	signal fifo_read_request : std_logic;
	signal fifo_empty : std_logic;
	-- signal fifo_full : std_logic;
	
	signal previous_result : std_logic_vector(width-1 downto 0);
	
	signal div_clock_en : std_logic;
	
begin
	
	numerator(width+point-1 downto point) <= dataa;
	numerator(point-1 downto 0) <= (others=>'0');
	denominator <= datab;
	
	div : LPM_DIVIDE
		generic map (
			LPM_WIDTHN => width+point, 
			LPM_WIDTHD => width, 
			LPM_PIPELINE => pipeline,
			LPM_NREPRESENTATION => "SIGNED",
			LPM_DREPRESENTATION => "UNSIGNED")
		port map (
			NUMER => div_numerator, 
			DENOM => div_denominator, 
			ACLR => reset, 
			CLOCK => clk, 
			CLKEN => div_clock_en, 
			QUOTIENT => quotient, 
			REMAIN => open);
			
	quotient_trimmed <= quotient(width-1 downto 0);
	
	calc_instruction <= '1' when (start = '1' and n = "0") else '0';
	read_instruction <= '1' when (start = '1' and n = "1") else '0';
	
	-- have to do the following this way, because Quartus unary 'or' operator is not supported
	pipeline_working_set <= pipeline_status(pipeline-2 downto 0);
	pipeline_working <= '1' when (pipeline_working_set /= pipeline_working_set_zeros) else '0';
	
	quotient_ready <= pipeline_status(pipeline-1);
	
	div_clock_en <= pipeline_working or assigned_calculation;
	
	fifo : entity work.my_fifo
		generic map (
			DATA_WIDTH => width, 
			NUM_ELEMENTS => pipeline)
		PORT map (areset => reset, clock => clk, 
					write_data => quotient_trimmed, write_request => fifo_write_request, 
					read_data => fifo_read_data, read_request => fifo_read_request,
					empty => fifo_empty, full => open);

	sync : process(clk, reset) begin
		if reset = '1' then 
			state <= WaitOnInstruction;
			pipeline_status <= (others=>'0');
			previous_result <= (others=>'0');
			div_numerator_previous <= (others=>'0');
			div_denominator_previous <= (others=>'0');
		elsif rising_edge(clk) then
			state <= next_state;
			pipeline_status(pipeline-1 downto 0) <= pipeline_status(pipeline-2 downto 0) & (assigned_calculation);
			previous_result <= result;
			div_numerator_previous <= div_numerator;
			div_denominator_previous <= div_denominator;
		end if;
	end process;
	
	next_state_logic : process(all) begin
		next_state <= state;
		done <= '0';
		assigned_calculation <= '0';
		fifo_read_request <= '0';
		result <= previous_result;
		-- write to fifo
		fifo_write_request <= quotient_ready;
		div_numerator <= div_numerator_previous;
		div_denominator <= div_denominator_previous;
		
		case state is
			when WaitOnInstruction => 
				if calc_instruction = '1' then 
					done <= '1';
					assigned_calculation <= '1';
					div_numerator <= numerator;
					div_denominator <= denominator;
					
				elsif read_instruction = '1' and fifo_empty = '1' then
					next_state <= ReadStall;
				
				elsif read_instruction = '1' and fifo_empty = '0' then
					result <= fifo_read_data;
					fifo_read_request <= '1';
					done <= '1';
					
				end if;
				
			when ReadStall =>
				if quotient_ready = '1' then
					-- do not write to the fifo in stalling mode
					-- write directly to the output instead
					fifo_write_request <= '0';
					result <= quotient_trimmed;
					done <= '1';
					next_state <= WaitOnInstruction;
					
				end if;
		end case;
		
	end process;

end architecture;

