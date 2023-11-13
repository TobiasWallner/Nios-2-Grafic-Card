-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
USE lpm.lpm_components.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

entity avalon_mm_sqrt is
	generic (	width : natural := 32; 
				point : natural := 16;
				pipeline : natural := 16 
			);
	port ( 		clk   : in std_logic;
				res_n : in std_logic;
		
				--memory mapped slave
				address   : in  std_logic_vector(0 downto 0);
				write     : in  std_logic;
				read      : in  std_logic;
				writedata : in  std_logic_vector(width-1 downto 0);
				readdata  : out std_logic_vector(width-1 downto 0)
		);
end entity;


architecture rtl of avalon_mm_sqrt is
	-- the state of the state machine
	type state_t is (WaitOnInstruction);
	signal state : state_t;
	signal next_state : state_t;
	
	signal sqrt_output : std_logic_vector(((width+point) / 2)-1 downto 0); -- the output of the sqrt module
				-- the output of a sqrt result can only have half the bits of the input
	signal fmt_sqrt_output : std_logic_vector(width-1 downto 0); -- formated output of the sqrt to have a vector with the size of 'width' again
	signal sqrt_input : std_logic_vector(width+point-1 downto 0); -- the input to the sqrt module
	signal sqrt_input_previous : std_logic_vector(width+point-1 downto 0); -- the previous result of the module, used to hold the output
	
	-- the formated input value so that the result corresponds to the correct fixed point format
	signal fmt_input_value : std_logic_vector(width+point-1 downto 0);
	
	signal write_request : std_logic; -- true if a 'write value' request is issued to the module
	signal read_request : std_logic; -- true if a 'read result' request is issued to the module
	signal status_request : std_logic; -- true is a 'read status' request is issued to the module
	-- note that write_request and status_request can be true at the same time
	
	signal assigned_calculation : std_logic; -- true if a new calculation has been issued to the sqrt module
	
	signal pipeline_status : std_logic_vector(pipeline-1 downto 0); -- tracks progression of data in the pipeline
	signal pipeline_working_set : std_logic_vector(pipeline-2 downto 0); -- the subset of the pipeline that is doing the work
	constant pipeline_working_set_zeros : std_logic_vector(pipeline-2 downto 0) := (others=>'0'); -- zero vector as large as its prefix name
	signal pipeline_working : std_logic; -- true if the pipeline is working on the calculations
	signal sqrt_output_about_to_be_ready : std_logic; -- true if there is a result that can be read from the result in the next clock cycle
			-- this is handy, because the status register and the value register cannot be read from at the same time.
			-- so if you read the status register and there will be a result in the next clockcycle it will tell you the result is finished
			-- because in the next clockcycle when you read it, it will be. 
	signal sqrt_output_ready : std_logic; -- true if the output can be read from the pipeline
	
	signal fifo_read_data : std_logic_vector(width-1 downto 0); -- the data that is currently at position 0 in the fifo
	signal fifo_write_request : std_logic; -- activates a write of the fifo on the next clock
	signal fifo_read_request : std_logic; -- activates a read of the fifo on the next clock
	signal fifo_empty : std_logic; -- true if the fifo is empty
	-- signal fifo_full : std_logic; -- true if the fifo is full
	
	signal result : std_logic_vector(width-1 downto 0); -- the result that can be read from 'readdata'
	signal previous_result : std_logic_vector(width-1 downto 0); -- the previous result to hold the output
	
	signal sqrt_enable : std_logic;
begin

	readdata <= result;

	sqrt : ALTSQRT 
		generic map (
			pipeline => pipeline, 
			q_port_width => (width+point) / 2, 
			r_port_width => (width+point) / 2 + 1, 
			width => width+point)
		port map(	
			aclr => not res_n, 
			clk => clk, 
			ena => sqrt_enable, 
			q => sqrt_output, 
			radical => sqrt_input, 
			remainder => open);
			
	fifo : entity work.my_fifo
		generic map (
			DATA_WIDTH => width, 
			NUM_ELEMENTS => pipeline)
		PORT map (areset => not res_n, clock => clk, 
					write_data => fmt_sqrt_output, write_request => fifo_write_request, 
					read_data => fifo_read_data, read_request => fifo_read_request,
					empty => fifo_empty, full => open);
	
	-- input status
	write_request <= '1' when (address(0) = '0' and write = '1') else '0';
	read_request <= '1' when (address(0) = '1' and read = '1') else '0';
	status_request <= '1' when (address(0) = '0' and read = '1') else '0';

	-- pipeline status
	-- have to do the following this way, because Quartus unary 'or' operator is not supported
	pipeline_working_set <= pipeline_status(pipeline-2 downto 0);
	pipeline_working <= '1' when (pipeline_working_set /= pipeline_working_set_zeros) else '0';
	
	sqrt_enable <= pipeline_working or assigned_calculation;
	
	-- sqrt calculation status
	sqrt_output_about_to_be_ready <= pipeline_status(pipeline-2);
	sqrt_output_ready <= pipeline_status(pipeline-1);
	
	fmt_sqrt_output(width-1 downto ((width+point) / 2)) <= (others=>'0');
	fmt_sqrt_output(((width+point) / 2)-1 downto 0) <= sqrt_output;
	
	
	-- format and write input data to ALTSQRT
	fmt_input_value(width+point-1 downto point) <= writedata;
	fmt_input_value(point-1 downto 0) <= (others=>'0');
	
	sync : process(clk, res_n) begin
		if res_n = '0' then 
			state <= WaitOnInstruction;
			pipeline_status <= (others=>'0');
			previous_result <= (others=>'0');
			sqrt_input_previous <= (others=>'0');
			
		elsif rising_edge(clk) then
			state <= next_state;
			pipeline_status(pipeline-1 downto 0) <= pipeline_status(pipeline-2 downto 0) & (assigned_calculation);
			previous_result <= result;
			sqrt_input_previous <= sqrt_input;
		end if;
	end process;
	
	next_state_logic : process(all) begin
		next_state <= state;
		assigned_calculation <= '0';
		fifo_read_request <= '0';
		result <= previous_result;
		sqrt_input <= sqrt_input_previous;
		-- write sqrt result to the fifo
		fifo_write_request <= sqrt_output_ready; 
		
		case state is
			when WaitOnInstruction => 
				if write_request = '1' then
					assigned_calculation <= '1';
					sqrt_input <= fmt_input_value;
				end if;
					
				if read_request = '1' and fifo_empty = '0' then
					result <= fifo_read_data;
					fifo_read_request <= '1';
				
				elsif read_request = '1' and fifo_empty = '1' and sqrt_output_ready = '1' then
					result <= fmt_sqrt_output;
					fifo_write_request <= '0'; -- suppress write to fifo
				
				elsif read_request = '1' and fifo_empty = '1' then
					-- reading if nothing is present should not stall
					-- the result is undefined
					result <= (others=>'U');
				
				elsif status_request = '1' then
					-- reading from address 0 should return 
					--		1 if no result is ready
					--		0 if a result is ready
					result(width-1 downto 1) <= (others=>'0');
					if ((fifo_empty = '0') or (sqrt_output_ready = '1') or (sqrt_output_about_to_be_ready = '1')) then
						result(0) <= '0';
					else 
						result(0) <= '1';
					end if;
				end if;
		end case;
	end process;
end architecture;

