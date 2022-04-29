library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity speed_switch is
    port(
    	-- hodinovy signal z desky
        clk         : in  std_logic;
        
        -- rychlosti ve vsech sektorech
        v1_i    : in  real;
        v2_i    : in  real;
        v3_i    : in  real;
        v_i    : in  real;
        
        -- switche z hlavni desky
        s1_i    : in  std_logic;
        s2_i    : in  std_logic;
        
        -- vystup: jedna z rychlosti
        v_print_o : out real
    
    );
end speed_switch;

architecture Behavioral of speed_switch is
    
    
    
    
    -- Rychlost
    -- promenne pro vypocet rychlosti a informace o jejich desetinnych teckach
    -- signal s_v1			: real	:= 0.0;


begin

    p_measure : process(clk)
    begin
        if rising_edge(clk) then
			
            -- s2_i = '0' , s1_i = '0' -> print average speed
            -- s2_i = '0' , s1_i = '1' -> print speed in 1. sector
            -- s2_i = '1' , s1_i = '0' -> print speed in 2. sector
            -- s2_i = '1' , s1_i = '1' -> print speed in 3. sector
            
            if(s2_i = '0') then
            
            	if(s1_i = '0') then
                	v_print_o <= v_i; -- "00"
                
                else
                	v_print_o <= v1_i; -- "01"
                
                end if;
                
            else
            
            	if(s1_i = '0') then
                	v_print_o <= v2_i; -- "10"
                
                else
                	v_print_o <= v3_i; -- "11"
                
                end if;
            
            end if;
            
            
            
        end if;
    end process p_measure;
    
end architecture Behavioral;
