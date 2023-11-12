library ieee;
use ieee.std_logic_1164.all;

entity top is
	port (
		clk   : in std_logic;
		res_n : in std_logic;

		-- interface to the ADV7123 and VGA connector
		vga_dac_r       : out std_logic_vector(7 downto 0);
		vga_dac_g       : out std_logic_vector(7 downto 0);
		vga_dac_b       : out std_logic_vector(7 downto 0);
		vga_dac_clk     : out std_logic;
		vga_dac_sync_n  : out std_logic;
		vga_dac_blank_n : out std_logic;
		vga_hsync       : out std_logic;
		vga_vsync       : out std_logic;

		--interface to the 128MB SDRAM
		sdram_clk   : out   std_logic;
		sdram_addr  : out   std_logic_vector(12 downto 0);
		sdram_ba    : out   std_logic_vector(1 downto 0);
		sdram_cas_n : out   std_logic;
		sdram_cke   : out   std_logic;
		sdram_cs_n  : out   std_logic;
		sdram_dq    : inout std_logic_vector(31 downto 0) := (others => 'X');
		sdram_dqm   : out   std_logic_vector(3 downto 0);
		sdram_ras_n : out   std_logic;
		sdram_we_n  : out   std_logic
	);
end entity;

architecture arch of top is
	component raytracing is
		port (
			altpll_0_areset_conduit_export : in    std_logic                     := 'X';             -- export
			altpll_0_locked_conduit_export : out   std_logic;                                        -- export
			clk_clk                        : in    std_logic                     := 'X';             -- clk
			reset_reset_n                  : in    std_logic                     := 'X';             -- reset_n
			sdram_addr                     : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_ba                       : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_cas_n                    : out   std_logic;                                        -- cas_n
			sdram_cke                      : out   std_logic;                                        -- cke
			sdram_cs_n                     : out   std_logic;                                        -- cs_n
			sdram_dq                       : inout std_logic_vector(31 downto 0) := (others => 'X'); -- dq
			sdram_dqm                      : out   std_logic_vector(3 downto 0);                     -- dqm
			sdram_ras_n                    : out   std_logic;                                        -- ras_n
			sdram_we_n                     : out   std_logic;                                        -- we_n
			sdram_clk_clk                  : out   std_logic;                                        -- clk
			vga_CLK                        : out   std_logic;                                        -- CLK
			vga_HS                         : out   std_logic;                                        -- HS
			vga_VS                         : out   std_logic;                                        -- VS
			vga_BLANK                      : out   std_logic;                                        -- BLANK
			vga_SYNC                       : out   std_logic;                                        -- SYNC
			vga_R                          : out   std_logic_vector(7 downto 0);                     -- R
			vga_G                          : out   std_logic_vector(7 downto 0);                     -- G
			vga_B                          : out   std_logic_vector(7 downto 0)                      -- B
		);
	end component raytracing;
begin
	u0 : component raytracing
	port map (
		clk_clk                        => clk,
		reset_reset_n                  => res_n,
		altpll_0_areset_conduit_export => '0',
		altpll_0_locked_conduit_export => open,
		vga_CLK                        => vga_dac_clk,
		vga_R	                    => vga_dac_r,
		vga_G	                    => vga_dac_g,
		vga_B	                    => vga_dac_b,
		vga_VS                         => vga_vsync,
		vga_HS                         => vga_hsync,
		vga_BLANK                      => vga_dac_blank_n,
		vga_SYNC                       => vga_dac_sync_n,
		sdram_addr                     => sdram_addr,
		sdram_ba                       => sdram_ba,
		sdram_cas_n                    => sdram_cas_n,
		sdram_cke                      => sdram_cke,
		sdram_cs_n                     => sdram_cs_n,
		sdram_dq                       => sdram_dq,
		sdram_dqm                      => sdram_dqm,
		sdram_ras_n                    => sdram_ras_n,
		sdram_we_n                     => sdram_we_n,
		sdram_clk_clk                  => sdram_clk
	);
end architecture;


