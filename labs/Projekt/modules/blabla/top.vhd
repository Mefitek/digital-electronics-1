library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


------------------------------------------------------------
-- Entity declaration for top
------------------------------------------------------------
entity top is
    Port(
		-- PMod pins
		JA1 : in STD_LOGIC;
		JA2 : in STD_LOGIC;
		JB1 : in STD_LOGIC;
		JB2 : in STD_LOGIC;

        -- Clock
        CLK100MHZ : in STD_LOGIC;

        -- Switches
		SW 		  : in STD_LOGIC_VECTOR (1 downto 0);
		
        -- 7segment display cathodes
		CA : out STD_LOGIC;
		CB : out STD_LOGIC;
		CC : out STD_LOGIC;
		CD : out STD_LOGIC;
		CE : out STD_LOGIC;
		CF : out STD_LOGIC;
		CG : out STD_LOGIC;
        -- 7segmet display decimal point
		DP : out STD_LOGIC;
		 
        -- 7segment display anodes
		AN : out STD_LOGIC_VECTOR (7 downto 0)  
    );
end entity top;

------------------------------------------------------------------------
-- Architecture body for top level
------------------------------------------------------------------------
architecture Behavioral of top is

  -- Internal signals between speed_measure modules and real_switch
  signal s_r1       : real := 0.0 ;
  signal s_r2       : real := 0.0 ;
  signal s_r3       : real := 0.0 ;
  signal s_ravg     : real := 0.0 ;

  -- Internal signal between real_switch and real_to_hex
  signal s_r        : real := 0.0 ;
  
  -- Internal signal between real_to_hex and driver_7seg_4digits
  signal s_data0 : std_logic_vector(4 - 1 downto 0);
  signal s_data1 : std_logic_vector(4 - 1 downto 0);
  signal s_data2 : std_logic_vector(4 - 1 downto 0);
  signal s_data3 : std_logic_vector(4 - 1 downto 0);
  signal s_dp : std_logic_vector(4 - 1 downto 0);

begin	
	--------------------------------------------------------------------
    -- Instance (copy) of speed_measure entity (first)
	speed_measure_section_1 : entity work.speed_measure
      generic map(
          g_dist => 20.0;
		  g_active => '0'; -- Whether the input sensors are active HIGH or LOW
          g_clk_f => 100000000  -- Main clock frequency [Hz]
      )
      port map(
          clk   => CLK100MHZ,
          en_i  => JA1,
          dis_i => JA2,
          reset => '0',
          v_o	 => s_r1
      );
	--------------------------------------------------------------------

    --------------------------------------------------------------------
    -- FOur instances (copie) of speed_measure entity
    speed_measure_section_2 : entity work.speed_measure
      generic map(
          g_dist => 30.0;
		  g_active => '0'; -- Whether the input sensors are active HIGH or LOW
          g_clk_f => 100000000  -- Main clock frequency [Hz]
      )
      port map(
          clk   => CLK100MHZ,
          en_i  => JA2,
          dis_i => JB1,
		  reset => JA1,
          v_o	 => s_r2
      );

    speed_measure_section_3 : entity work.speed_measure
      generic map(
          g_dist => 20.0;
		  g_active => '0'; -- Whether the input sensors are active HIGH or LOW
          g_clk_f => 100000000  -- Main clock frequency [Hz]
      )
      port map(
          clk   => CLK100MHZ,
          en_i  => JB1,
          dis_i => JB2,
		  reset => JA1,
          v_o	 => s_r3
      );

	speed_measure_avg : entity work.speed_measure
      generic map(
          g_dist => 70.0;
		  g_active => '0'; -- Whether the input sensors are active HIGH or LOW
          g_clk_f => 100000000  -- Main clock frequency [Hz]
      )
      port map(
          clk   => CLK100MHZ,
          en_i  => JA1,
          dis_i => JB2,
          reset  => '0',
          v_o	 => s_ravg
      );
      
	speed_real_switch  : entity work.real_switch
		port map(
      
			clk   => CLK100MHZ,
			
			r1_i => s_v1,
			r2_i => s_v2,
			r3_i => s_v3,
			r4_i  => s_v,
			
			s1_i => SW(0),
			s2_i => SW(1),
	 
			r_o => s_r
      
      );
    --------------------------------------------------------------------

    --------------------------------------------------------------------
    -- Instance (copy) of real_to_hex entity 
    speed_real_convert : entity work.real_to_hex
		port map(
      
			clk   => CLK100MHZ,
			
			real_i  => s_r,
			data0_o => s_data0,
			data1_o => s_data1,
			data2_o => s_data2,
			data3_o => s_data3,
			dp_o    => s_dp
		);
    
    --------------------------------------------------------------------
    
    --------------------------------------------------------------------
    -- Instance (copy) of driver_7seg_4digits entity 
    speed_driver_7s : entity work.driver_7seg_4digits
        
        port map(
            clk   		=> CLK100MHZ,
           	reset		=> '0',
            
            data0_i(3 downto 0)	=> s_data0(3 downto 0),
            data1_i(3 downto 0)	=> s_data1(3 downto 0),
            data2_i(3 downto 0)	=> s_data2(3 downto 0),
            data3_i(3 downto 0)	=> s_data3(3 downto 0),
            dp_i(3 downto 0)	=> s_dp(3 downto 0),
            
            seg_o(0)	=> CG,
            seg_o(1)	=> CF,
            seg_o(2)	=> CE,
            seg_o(3)	=> CD,
            seg_o(4)	=> CC,
            seg_o(5)	=> CB,
            seg_o(6)	=> CA,
            dp_o		=> DP,
            dig_o(3 downto 0) => AN(3 downto 0)
        );
    --------------------------------------------------------------------
        

    -- Disconnect the unused part of the 7-segment display
        AN(7 downto 4) <= "1111";

end architecture Behavioral;
