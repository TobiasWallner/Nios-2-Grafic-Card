

library ieee;
use ieee.std_logic_1164.all;

-- sry but the other fifo you provided is stupid

entity my_fifo is
	generic (
		DATA_WIDTH : natural := 32;
		NUM_ELEMENTS : natural := 8);
	port (
		areset : in STD_LOGIC;
		clock : in STD_LOGIC;

		write_data : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
		write_request : in STD_LOGIC;

		read_data : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
		read_request : in STD_LOGIC;
		
		empty : out STD_LOGIC ;
		full : out STD_LOGIC);
end entity;

architecture arch of my_fifo is
	type std_logic_vector_array is array (natural range <>) of std_logic_vector;
	signal mem : std_logic_vector_array (0 to NUM_ELEMENTS-1)(DATA_WIDTH-1 downto 0);
	signal count : natural range 0 to NUM_ELEMENTS;
begin

	read_data <= mem(0);
	
	sync : process(clock, areset) begin
		if areset = '1' then
			empty <= '1';
			full <= '0';
			count <= 0;
			mem <= (others=>(others=>'0'));
			
		elsif (rising_edge(clock)) then
			if (write_request = '1' and read_request = '0') then
				mem(count) <= write_data;
				empty <= '0';
				if count = NUM_ELEMENTS-1 then
					full <= '1';
				else 
					full <= '0';
				end if;
				count <= count + 1;
				
			elsif (write_request = '0' and read_request = '1') then
				mem(0 to NUM_ELEMENTS-2) <= mem(1 to NUM_ELEMENTS-1);
				full <= '0';
				if count = 1 then
					empty <= '1';  
				else 
					empty <= '0';
				end if;
				count <= count - 1;
			
			elsif (write_request = '1' and read_request = '1' and (not (count = 0)) ) then
				mem(0 to NUM_ELEMENTS-2) <= mem(1 to NUM_ELEMENTS-1);
				mem(count - 1)  <=  write_data;
			
			end if;
		
		end if;
		
	end process sync;

end architecture;

