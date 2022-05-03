------------------------------------------------------------
--
-- Speed calculator between 4 sensors, both directions
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

------------------------------------------------------------
-- Entity declaration for speed calculator
--
--             +---------------------+
--             | g_sector_1 = 20.0   |
--             | g_sector_2 = 20.0   |
--             | g_sector_3 = 20.0   |
--             | g_sens_active = '1' |
--             | g_clk_freq = 10^8   |
--             |                     |
--        -----|> clk                |
--             |                     |
--             |                     |
--        --/--| sensor_1_i          |
--        --/--| sensor_2_i          |
--        --/--| sensor_3_i          |
--        --/--| sensor_4_i          |
--          1  |           speed_1_o |---/---
--             |           speed_2_o |---/---
--             |           speed_3_o |---/---
--             |             speed_o |---/---
--             |                     |  real
--             +---------------------+
--
-- Inputs:
--   clk
--   sensor_X_i -- 1bit output of sensor X
--
-- Outputs:
--   speed_X_o  -- Speed value in sector X  [m/s]
--   speed_0    -- Average speed across the sectors [m/s]
--
------------------------------------------------------------
entity speed_calc is

	generic(
        g_sector_1 	: real := 0.0025; -- Length - sector between sensors 1 and 2 [cm]
     	g_sector_2 	: real := 0.0025; -- Between 2 and 3 [cm]
      	g_sector_3 	: real := 0.0025; -- Between 3 and 4 [cm]
        g_sens_active : std_logic := '1'; -- Whether the sensors are active HIGH or LOW
        g_clk_freq : natural := 100000000  -- Main clock frequency [Hz]
    );

    port(
        clk	: in  std_logic; -- Main clock
        
        -- Input sensor signals
        sensor_1_i   : in  std_logic; -- sensor 1
        sensor_2_i   : in  std_logic; -- sensor 2
        sensor_3_i   : in  std_logic; -- sensor 3
        sensor_4_i   : in  std_logic; -- sensor 4
        
        -- Output speed signals
        speed_1_o	: out real := 0.0; -- sector 1
        speed_2_o	: out real := 0.0; -- sector 2
        speed_3_o	: out real := 0.0; -- sector 3
        speed_o		: out real := 0.0 -- average speed
    );
    
end speed_calc;

------------------------------------------------------------
-- Architecture body for speed calculator
------------------------------------------------------------

architecture Behavioral of speed_calc is

	-- Defining the states
    -- notes:
    --   L/R      : Object direction from Left/Right
    --   SECTOR_X : Measuring in sector X
    --   WAIT     : Waiting for object to leave last sector
    --   READY    : Ready to begin new measuring
    
	type t_state is (L_SECTOR_1, 
                     L_SECTOR_2,
                     L_SECTOR_3,
                     L_WAIT,
                     R_SECTOR_1,
                     R_SECTOR_2,
                     R_SECTOR_3,
                     R_WAIT,
                     READY);
    
    -- Defining the signal that uses different states + setting initial state
    signal s_state : t_state := READY;

    -- Local counter for clock periods spent in sector 1÷3
    signal s_cnt_1      : natural := 1;
    signal s_cnt_2      : natural := 1;
    signal s_cnt_3      : natural := 1;
      
   	-- Local signal for reseting the counters
    signal s_reset      : std_logic := '0';

    -- Constant - sum of sector lengths (for code clarity)
    constant c_SECTOR 	: real := (g_SECTOR_1 + g_SECTOR_2 + g_SECTOR_3);
    
    -- Constant - converting measured [cm/clock_period] to [m/s]
   	constant c_cmT_to_ms : real := Real(g_clk_freq)/100.0;
    
    -- Constants - When is the sensor active/inactive (for code clarity)
    constant c_ACTIVE : std_logic := g_sens_active;
    constant c_INACTIVE : std_logic := not(c_ACTIVE);


begin

	--------------------------------------------------------
    -- p_measure:
    -- A sequential process controlling the s_state signal by
    -- CASE statement - allowing us to measure the speed
    -- between sensors in both directions.
    --------------------------------------------------------
    p_measure : process(clk)
    begin
        if rising_edge(clk) then
        
            -- Resetting to initial state when any counter > 5 seconds
            if ((s_cnt_1>(5*g_clk_freq)) or (s_cnt_2>(5*g_clk_freq)) or (s_cnt_3>(5*g_clk_freq))) then
                  s_reset <= '1';
                  s_state <= READY;
            end if; 
			
			-- Resetting the counters (not the state!)
         	if (s_reset = '1') then
                      s_cnt_1 <= 1;
                      s_cnt_2 <= 1;
                      s_cnt_3 <= 1;
                      s_reset <= '0';
            end if;
            
            -- Every clk period, CASE checks the value of the s_state 
            -- variable and depending on sensor states changes to the
            -- next state or increments local counter signals
            case s_state is

				  
                  -- state is READY :
                  -- If one of the edge
                  -- sensors becomes active - we begin measuring from
                  -- it's direction (we assume sensors are in order 1234)
			      when READY =>

                      -- sensor 1 becomes active - we begin measuring from Left
                      if(sensor_1_i = c_ACTIVE) then
                          s_state <= L_SECTOR_1;
                      end if;

                      -- sensor 4 becomes active - we begin measuring from Right
                      if(sensor_4_i = c_ACTIVE) then
                          s_state <= R_SECTOR_3;
                      end if;
	
				
                  -- state is L_SECTOR_1 :
                  -- When sensor 2 is inactive we increment the counter 1 signal
                  -- When it becomes active we calculate the speed in sector 1
                  -- and change the state to the next one
                  when L_SECTOR_1 =>

                      if (sensor_2_i = c_INACTIVE) then
                          s_cnt_1 <= s_cnt_1 + 1;
                      else
                      	  -- calculating speed: length/time * conversion
                          speed_1_o <= ((g_SECTOR_1) / Real(s_cnt_1))*c_cmT_to_ms;
                          s_state <= L_SECTOR_2;
                      end if;

                  -- state is L_SECTOR_2 :
                  -- The same principle as L_SECTOR_1
                  when L_SECTOR_2 =>

                      if(sensor_3_i = c_INACTIVE) then
                          s_cnt_2 <= s_cnt_2 + 1;
                      else
                          speed_2_o <= ((g_SECTOR_2) / Real(s_cnt_2))*c_cmT_to_ms;
                          s_state <= L_SECTOR_3;
                      end if;
                      
				  -- state is L_SECTOR_3 :
                  -- The same principle as L_SECTOR_1 and L_SECTOR_2 but additionally we
                  -- calculate the average speed and reset the counters
                  
                  when L_SECTOR_3 =>

                      if(sensor_4_i = c_INACTIVE) then
                          s_cnt_3 <= s_cnt_3 + 1;
                      else
                          speed_3_o <= ((g_SECTOR_3) / Real(s_cnt_3))*c_cmT_to_ms;
                          -- calculating average speed: (sum of lengths)/(sum of times)*conversion
                          speed_o	<= ( (c_SECTOR) / (Real(s_cnt_3) + Real(s_cnt_2) + Real(s_cnt_1)))*c_cmT_to_ms;
                          s_reset <= '1';
                          s_state <= L_WAIT;
                      end if;
					
                  -- state is L_WAIT :
                  -- We await the last sensor to become inactive before changing to
                  -- the READY state
                  when L_WAIT =>
                      if(sensor_4_i = c_INACTIVE) then
                          s_state <= READY;
                      end if;

                  -- state is R_SECTOR_3 :
                  -- The procedure is analogous to L_SECTOR_X, but we approach the
                  -- sensors in order 4321 instead of 1234 (opposite direction)
                  when R_SECTOR_3 =>

                      if(sensor_3_i = c_INACTIVE) then
                          s_cnt_3 <= s_cnt_3 + 1;
                      else
                          speed_3_o <= ((g_SECTOR_3) / Real(s_cnt_3))*c_cmT_to_ms;
                          s_state <= R_SECTOR_2;
                     end if;

                  -- state is R_SECTOR_2
                  when R_SECTOR_2 =>

                      if(sensor_2_i = c_INACTIVE) then
                          s_cnt_2 <= s_cnt_2 + 1;
                      else
                          speed_2_o <= ((g_SECTOR_2) / Real(s_cnt_2))*c_cmT_to_ms;
                          s_state <= R_SECTOR_1;
                      end if;
                  
                  -- state is R_SECTOR_1
				  when R_SECTOR_1 =>

                      if(sensor_1_i = c_INACTIVE) then
                          s_cnt_1 <= s_cnt_1 + 1;
                      else
                          speed_1_o <= ((g_SECTOR_1) / Real(s_cnt_1))*c_cmT_to_ms;
                          speed_o	<= ( (c_SECTOR) / Real(s_cnt_3+s_cnt_2+s_cnt_1))*c_cmT_to_ms;
                          s_reset <= '1';
                          s_state <= R_WAIT; -- probiha mereni, ZPRAVA
                      end if;
				
                  -- state is R_WAIT
                  when R_WAIT =>
                      if(sensor_1_i = c_INACTIVE) then
                          s_state <= READY;
                      end if;  

                  when others =>
                      -- All cases handled, no need to handle other cases
                      
            end case;
        end if; -- Rising edge
    end process p_measure;
    
end architecture Behavioral;
