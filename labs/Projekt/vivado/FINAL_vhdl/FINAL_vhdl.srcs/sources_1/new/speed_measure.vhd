library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

------------------------------------------------------------
-- Entity declaration for speed measure
--
--             +----------------+
--             | g_dist = 20.0  |
--             | g_active = '1' |
--             | g_clk_f = 10^8 |
--             |                |
--        -----|> clk           |
--        -----| reset          |
--             |            v_o |---/---
--        -----| en_i           |  real
--        -----| dis_i          |
--             |                |
--             +----------------+
--
-- Inputs:
--   clk
--   reset
--   en_i	-- signal beginning the speed measurement (in our case a sensor)
--   dis_i	-- signal ending the speed measurement (in our case a sensor)
--
-- Outputs:
--   v_o:  	-- measured speed
--
------------------------------------------------------------

entity speed_measure is
	 generic(
        g_dist : real := 20.0; -- Distance travelled between sensors [cm]
        g_active : std_logic := '1'; -- Whether the input sensors are active HIGH or LOW
        g_clk_f : natural := 100000000  -- Main clock frequency [Hz]
    );

    port(
        clk         : in  std_logic; -- Main clock
        reset       : in  std_logic; -- Reset
        
        -- Input sensor signals
        en_i        : in  std_logic;
        dis_i       : in  std_logic;
        
        v_o	        : out real := 0.0 -- Output speed (data type "real")
    
    );
end speed_measure;

------------------------------------------------------------
-- Architecture declaration for speed measurer
------------------------------------------------------------
architecture Behavioral of speed_measure is

    -- Local counter
    signal s_cnt        : natural := 0; 
   
    -- Local signal indicating measurement status
    signal s_meas     : std_logic := '0';
    
    -- Constant - converting measured [cm/clock_period] to [m/s]
   	constant c_cmT_to_ms : real := Real(g_clk_f)/100.0;

begin

	--------------------------------------------------------
    -- p_measure:
    -- The sequential process with synchronous reset. Begins
    -- measurement at active en_i signal and end it at active
    -- dis_i.
    --------------------------------------------------------
    p_measure : process(clk)
    begin
    
        if rising_edge(clk) then
        
        	if (reset = '1') then -- Synchronous reset
        		s_meas <= '0'; -- reset measurement status
                s_cnt <= 0; -- reset counter
				v_o <= 0.0; -- set output speed to 0
            else
        
        	  -- When en_i signal becomes active and measurement status s_meas
              -- is '0' we set it to '1' and reset counter and output.
              -- BEGIN MREASUREMENT
              if (en_i = g_active) then
                  if (s_meas = '0') then
                      s_meas <= '1';
                      s_cnt <= 1;
					  v_o <= 0.0;
                  end if;
              end if;

		  	  -- When dis_i signal becomes active and s_meas is '1' we set it to
              -- '0' and calculate the output speed
              -- END MREASUREMENT
              if (dis_i = g_active) then
                  if (s_meas = '1') then
                      s_meas <= '0';
                      -- speed calculation: (distance)/(time)*conversion [m/s]
                      v_o <= ((g_dist) / Real(s_cnt))*c_cmT_to_ms;
                  end if;
              end if;

			  -- When measurement status is '1' we increment the local counter
              -- COUNTER++
              if (s_meas = '1') then
                  s_cnt <= s_cnt + 1;
              end if;
              
          end if; -- Synchronous reset
      end if; -- Rising edge
      end process p_measure;
    
end architecture Behavioral;