library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

------------------------------------------------------------
-- Entity declaration for real switch
--
--             +------------------+
--      -------|> clk             |
--             |                  |
--      -------| s1_i             |
--      -------| s2_i             |
--             |              r_o |---/---
--      ---/---| r1_i             |  real
--      ---/---| r2_i             |
--      ---/---| r3_i             |
--      ---/---| r4_i             |
--       real  |                  |
--             |                  |
--             +------------------+
--
-- Inputs:
--   sX_i	-- Two 1bit inputs (giving us 4 combinations)
--   rX_i	-- Four real type inputs
--
-- Outputs:
--   r_o	-- Realy type output (decided by combination of inputs)
--
------------------------------------------------------------

entity real_switch is
    port(
        clk         : in  std_logic; -- Main clock
        
        -- 4 signals of data type "real", 1 of them to be chosen as output signal
        r1_i    : in  real;
        r2_i    : in  real;
        r3_i    : in  real;
        r4_i    : in  real;
        
        -- 2 switches to control which input to be outputted
        s1_i    : in  std_logic;
        s2_i    : in  std_logic;
        
        r_o : out real -- Output
    
    );
end real_switch;


------------------------------------------------------------
-- Architecture declaration for real switch
------------------------------------------------------------
architecture Behavioral of real_switch is
    
begin

	--------------------------------------------------------
    -- p_switch:
    -- A sequential process that depending on the switch inputs
    -- s1_i and s2_i outputs only one of the 4 data type "real"
    -- inputs
    --------------------------------------------------------
    p_switch : process(clk)
    begin
        if rising_edge(clk) then
			
            -- required output: (s1_i = LSB, s2_i = MSB)
            -- "00" r_o <= r4_i
            -- "01" r_o <= r3_i
            -- "10" r_o <= r2_i
            -- "11" r_o <= r1_i
            
            --"0X"
            if(s2_i = '0') then 
            
            	if(s1_i = '0') then
                	-- "00"
                	r_o <= r4_i; 
                else
                	-- "01"
                	r_o <= r1_i;
                
                end if;
                
            --"1X"  
            else 
            
            	if(s1_i = '0') then
                	-- "10"
                	r_o <= r2_i;
                else
                	-- "11"
                	r_o <= r3_i;
                end if;
            
            end if;
            
        end if;-- Rising edge
    end process p_switch;
    
end architecture Behavioral;