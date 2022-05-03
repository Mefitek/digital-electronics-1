------------------------------------------------------------
--
-- Template for 4-digit 7-segment display driver testbench.
-- Nexys A7-50T, Vivado v2020.1.1, EDA Playground
--
-- Copyright (c) 2020-Present Tomas Fryza
-- Dept. of Radio Electronics, Brno Univ. of Technology, Czechia
-- This work is licensed under the terms of the MIT license.
--
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------
-- Entity declaration for testbench
------------------------------------------------------------
entity tb_speed_measure_top is
    -- Entity of testbench is always empty
end entity tb_speed_measure_top;

------------------------------------------------------------
-- Architecture body for testbench
------------------------------------------------------------
architecture testbench of tb_speed_measure_top is

    -- Local constants
    constant c_CLK_100MHZ_PERIOD : time := 10 ns;
    constant c_MAX               : natural := 3;

    -- Local signals
    signal s_clk_100MHz : std_logic;
    signal s_sensor1 : std_logic;
    signal s_sensor2 : std_logic;
    signal s_sensor3 : std_logic;
    signal s_sensor4 : std_logic;
    signal s_reset   : std_logic;
    signal s_switch  : STD_LOGIC_VECTOR (1 downto 0);
    


begin
    -- Connecting testbench signals with driver_7seg_4digits
    -- entity (Unit Under Test)
    -- MAP I/O PORTS FROM ENTITY TO LOCAL SIGNALS
    -- uut_driver_7seg_4digits : entity work....
    uut_speed_measure_top : entity work.top
        port map(
            CLK100MHZ   => s_clk_100MHz,
			JA1     	=> s_sensor1,
            JA2     	=> s_sensor2,
            JB1     	=> s_sensor3,
            JB2     	=> s_sensor4,
			SW    		=> s_switch,
			RESET       => s_reset
        );

    --------------------------------------------------------
    -- Clock generation process
    --------------------------------------------------------
    p_clk_gen : process
    begin
        while now < 80 ms loop 
            s_clk_100MHz <= '0';
            wait for c_CLK_100MHZ_PERIOD / 2;
            s_clk_100MHz <= '1';
            wait for c_CLK_100MHZ_PERIOD / 2;
        end loop;
        wait;
    end process p_clk_gen;
    
    p_switch_gen : process
    begin
		s_switch  <= "00";
		wait for 16 ms;
        while now < 80 ms loop
            s_switch  <= "01";
            wait for 16 ms;
            s_switch  <= "10";
            wait for 16 ms;
            s_switch  <= "11";
            wait for 16 ms;
            s_switch  <= "00";
            wait for 16 ms;
           
        end loop;
        wait;
    end process p_switch_gen;

    --------------------------------------------------------
    -- Data generation process
    --------------------------------------------------------
  p_stimulus : process
  begin
        
		s_sensor1 <= '0';
		s_sensor2 <= '0';
		s_sensor3 <= '0';
		s_sensor4 <= '0';
		s_reset <= '1';
		
		wait for 100 ns;
		s_reset <= '0';
		s_sensor1 <= '1';
		wait for 100000 ns;  -- 0,1 ms
		s_sensor1 <= '0';
		
		wait for 3300000 ns;  -- 3,3 ms
		s_sensor2 <= '1';
		wait for 200000 ns;  -- 0,2 ms
		s_sensor2 <= '0';
		
		wait for 5000000 ns;  -- 5 ms
		s_sensor3 <= '1';
		wait for 50000 ns;  -- 0,05 ms
		s_sensor3 <= '0';
		
		
		wait for 7000000 ns;  -- 7 ms
		s_sensor4 <= '1';
		wait for 70000 ns;  -- 0,07 ms
		s_sensor4 <= '0';
		
        wait;
    end process p_stimulus;

end architecture testbench;

    
