library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



  entity top is
      Port ( CLK100MHZ : in STD_LOGIC;
              SW : in STD_LOGIC_VECTOR (15 downto 0);
              
              CA : out STD_LOGIC;
              CB : out STD_LOGIC;
              CC : out STD_LOGIC;
              CD : out STD_LOGIC;
              CE : out STD_LOGIC;
              CF : out STD_LOGIC;
              CG : out STD_LOGIC;
              DP : out STD_LOGIC;
              
              AN : out STD_LOGIC_VECTOR (7 downto 0)
           );
  end entity top;

  architecture Behavioral of top is

      -- internal signals

      signal s_v1  : real;
      signal s_v2  : real;
      signal s_v3  : real;
      signal s_v  : real;

      signal s_v_print : real;

      signal s_data0 : std_logic_vector(4 - 1 downto 0);
      signal s_data1 : std_logic_vector(4 - 1 downto 0);
      signal s_data2 : std_logic_vector(4 - 1 downto 0);
      signal s_data3 : std_logic_vector(4 - 1 downto 0);
      signal s_dp : std_logic_vector(4 - 1 downto 0);


  begin


  -- Instance (copy) of clock_enable entity
    speed_calc0 : entity work.speed_calc
        generic map(
            g_clk_freq => 100000000,
            g_DELKA_1 => 100,
            g_DELKA_2 => 100,
            g_DELKA_3 => 100
        )
        
        port map(
            clk   		=> CLK100MHZ,
            
            -- senzory jako cudliky jen pro testovani
            sensor_1_i 	=> SW(15),
            sensor_2_i 	=> SW(14),
            sensor_3_i 	=> SW(13),
            sensor_4_i 	=> SW(12),
            speed_1_o	=> s_v1,
            speed_2_o	=> s_v2,
            speed_3_o	=> s_v3,
            speed_o	=> s_v
        );
        
        
    speed_sw0 : entity work.speed_switch
        
        port map(
            clk   		=> CLK100MHZ,
            s1_i		=> SW(0),
            s2_i		=> SW(1),
            v1_i		=> s_v1,
            v2_i		=> s_v2,
            v3_i		=> s_v3,
            v_i			=> s_v,
            v_print_o	=> s_v_print
        );
        
        
   speed_r_to_7s : entity work.real_to_7_seg
        
        port map(
            clk   		=> CLK100MHZ,
            speed_i		=> s_v_print,
            data0_o		=> s_data0,
            data1_o		=> s_data1,
            data2_o		=> s_data2,
            data3_o		=> s_data3,
            dp_o		=> s_dp
        );
        
        
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
        

        AN(7 downto 4) <= "1111";
        
end architecture Behavioral;