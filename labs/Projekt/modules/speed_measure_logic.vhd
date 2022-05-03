------------------------------------------------------------
--
-- Speed measure between 2 sensors, output as logic vector
-- Nexys A7-50T, Vivado v2020.1.1, EDA Playground
--
-- Copyright (c) 2020-Present Petr Klima, Matej Cernohous, Vladimir Skoumal
-- Dept. of Radio Electronics, Brno Univ. of Technology, Czechia
-- This work is licensed under the terms of the MIT license.
--
------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity speed_measure_logic is
	 generic(
        g_dist 		: unsigned(5 - 1 downto 0) := to_unsigned(20,5);
        g_clk_f		: unsigned(27 - 1 downto 0) := to_unsigned(100000000,27);
        g_active : std_logic := '1'
    );

    port(
    	
        clk         : in  std_logic;
        en_i        : in  std_logic;
        dis_i       : in  std_logic;
        reset_i     : in  std_logic;
        
        v_o	        : out std_logic_vector(32 - 1 downto 0)
    );
end entity speed_measure_logic;

architecture Behavioral of speed_measure_logic is


    signal s_cnt        : natural := 1; 
    signal s_meas     : std_logic := '0';
    
    signal s_v : unsigned(32 - 1 downto 0);
    signal s_help : unsigned(32 - 1 downto 0) := g_clk_f*g_dist; 

begin

    p_measure : process(clk)
    begin
    
        if rising_edge(clk) then
        
        	-- Reset_i
        	if (reset_i = '1') then
        		s_meas <= '0';
                s_cnt <= 0;
				s_v <= "00000000000000000000000000000000";
            else
        
              if (en_i = '1') then
                  if (s_meas = '0') then
                      s_meas <= '1';
                      s_cnt <= 1;
					  s_v <= "00000000000000000000000000000000";
                  end if;
              end if;

              if (dis_i = g_active) then
                  if (s_meas = '1') then
                      s_meas <= '0';
                      	-- Calculating speed
                        -- Division by shifting the bits
                        if(s_cnt >= 4294967296) then -- 2^32
                        	s_v <= shift_right(s_help, 32);
                        elsif (s_cnt >= 2147483648) then -- 2^31
                        	s_v <= shift_right(s_help, 31); 
                       	-- ...
                        -- other cases
                        -- ...
                        elsif (s_cnt >= 4) then -- 2^2
                        	s_v <= shift_right(s_help, 2);
                        elsif (s_cnt >= 2) then -- 2^1
                        	s_v <= shift_right(s_help, 1);
                       	end if; -- Shifting
                  end if; -- s_meas = '1'
              end if; -- dis_i = '1'

              if (s_meas = '1') then
                  s_cnt <= s_cnt + 1;
              end if;
          end if;
      end if;
      end process p_measure;
      
       v_o <= std_logic_vector(s_v);
    
end architecture Behavioral;
