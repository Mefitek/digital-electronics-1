library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all; -- funkce floor()


entity real_to_7_seg is
    port(
    	-- hodinovy signal z desky
        clk         : in  std_logic;
        
      	-- vystupy pro zobrazeni na segmentovce
        data0_o : out  std_logic_vector(3 downto 0) := "0000";
        data1_o : out  std_logic_vector(3 downto 0) := "0000";
        data2_o : out  std_logic_vector(3 downto 0) := "0000";
        data3_o : out  std_logic_vector(3 downto 0) := "0000";
        dp_o    : out  std_logic_vector(3 downto 0) := "0000";
        
        speed_i : in real
    
    );
end real_to_7_seg;

architecture Behavioral of real_to_7_seg is

    -- Rychlost
    -- promenne pro vypocet rychlosti a informace o jejich desetinnych teckach
    signal s_v			: real	:= 0.0;
    signal s_v_old		: real := 0.0;
    
   	constant c_0		: std_logic_vector(3 downto 0) := "0000";
    constant c_1		: std_logic_vector(3 downto 0) := "0001";
    constant c_2		: std_logic_vector(3 downto 0) := "0010";
    constant c_3		: std_logic_vector(3 downto 0) := "0011";
    constant c_4		: std_logic_vector(3 downto 0) := "0100";
    constant c_5		: std_logic_vector(3 downto 0) := "0101";
    constant c_6		: std_logic_vector(3 downto 0) := "0110";
    constant c_7		: std_logic_vector(3 downto 0) := "0111";
    constant c_8		: std_logic_vector(3 downto 0) := "1000";
    constant c_9		: std_logic_vector(3 downto 0) := "1001";
    
begin

    p_calculate : process(clk)
    begin
       if rising_edge(clk) then
       
           dp_o <= "1011";
           s_v <= speed_i;

           if (s_v /= s_v_old) then
           
              -- pokud nad 100, zobrazi 99,99
              if(s_v >= 100.0) then
                  data0_o <= c_9;
                  data1_o <= c_9;
                  data2_o <= c_9;
                  data3_o <= c_9;

              else

                -- desitky <= floor(s_v/10.0);
                -- jednotky <= (floor(s_v) - 10.0*floor(s_v/10.0));
                -- desetiny <= (floor(s_v*10.0) - 10.0*floor(s_v));
                -- setiny <= (floor(s_v*100.0) - 10.0*floor(s_v*10.0));

				-- why not use case expression when ?
                -- can only be used for discreet expressions

				-- desitky
                if ( floor(s_v/10.0) = 0.0) then
                    data0_o <= c_0;
                elsif ( floor(s_v/10.0) = 1.0) then
                    data0_o <= c_1;
                elsif ( floor(s_v/10.0) = 2.0 ) then
                    data0_o <= c_2;
                elsif ( floor(s_v/10.0) = 3.0 ) then
                    data0_o <= c_3;
                elsif ( floor(s_v/10.0) = 4.0 ) then
                    data0_o <= c_4;
                elsif ( floor(s_v/10.0) = 5.0 ) then
                    data0_o <= c_5;
                elsif ( floor(s_v/10.0) = 6.0 ) then
                    data0_o <= c_6;
                elsif ( floor(s_v/10.0) = 7.0 ) then
                    data0_o <= c_7;
                elsif ( floor(s_v/10.0) = 8.0 ) then
                    data0_o <= c_8;
                else
                    data0_o <= c_9;
                end if;

		
                -- jednotky
                if ( (floor(s_v) - 10.0*floor(s_v/10.0)) = 0.0) then
                    data1_o <= c_0;
                elsif ( (floor(s_v) - 10.0*floor(s_v/10.0)) = 1.0) then
                    data1_o <= c_1;
                elsif ( (floor(s_v) - 10.0*floor(s_v/10.0)) = 2.0 ) then
                    data1_o <= c_2;
                elsif ( (floor(s_v) - 10.0*floor(s_v/10.0)) = 3.0 ) then
                    data1_o <= c_3;
                elsif ( (floor(s_v) - 10.0*floor(s_v/10.0)) = 4.0 ) then
                    data1_o <= c_4;
                elsif ( (floor(s_v) - 10.0*floor(s_v/10.0)) = 5.0 ) then
                    data1_o <= c_5;
                elsif ( (floor(s_v) - 10.0*floor(s_v/10.0)) = 6.0 ) then
                    data1_o <= c_6;
                elsif ( (floor(s_v) - 10.0*floor(s_v/10.0)) = 7.0 ) then
                    data1_o <= c_7;
                elsif ( (floor(s_v) - 10.0*floor(s_v/10.0)) = 8.0 ) then
                    data1_o <= c_8;
                else
                    data1_o <= c_9;
                end if;

                -- desetiny
                if ( (floor(s_v*10.0) - 10.0*floor(s_v)) = 0.0) then
                    data2_o <= c_0;
                elsif ( (floor(s_v*10.0) - 10.0*floor(s_v)) = 1.0) then
                    data2_o <= c_1;
                elsif ( (floor(s_v*10.0) - 10.0*floor(s_v)) = 2.0 ) then
                    data2_o <= c_2;
                elsif ( (floor(s_v*10.0) - 10.0*floor(s_v)) = 3.0 ) then
                    data2_o <= c_3;
                elsif ( (floor(s_v*10.0) - 10.0*floor(s_v)) = 4.0 ) then
                    data2_o <= c_4;
                elsif ( (floor(s_v*10.0) - 10.0*floor(s_v)) = 5.0 ) then
                    data2_o <= c_5;
                elsif ( (floor(s_v*10.0) - 10.0*floor(s_v)) = 6.0 ) then
                    data2_o <= c_6;
                elsif ( (floor(s_v*10.0) - 10.0*floor(s_v)) = 7.0 ) then
                    data2_o <= c_7;
                elsif ( (floor(s_v*10.0) - 10.0*floor(s_v)) = 8.0 ) then
                    data2_o <= c_8;
                else
                    data2_o <= c_9;
                end if;

                -- setiny
                if ( (floor(s_v*100.0) - 10.0*floor(s_v*10.0)) = 0.0) then
                    data3_o <= c_0;
                elsif ( (floor(s_v*100.0) - 10.0*floor(s_v*10.0)) = 1.0) then
                    data3_o <= c_1;
                elsif ( (floor(s_v*100.0) - 10.0*floor(s_v*10.0)) = 2.0 ) then
                    data3_o <= c_2;
                elsif ( (floor(s_v*100.0) - 10.0*floor(s_v*10.0)) = 3.0 ) then
                    data3_o <= c_3;
                elsif ( (floor(s_v*100.0) - 10.0*floor(s_v*10.0)) = 4.0 ) then
                    data3_o <= c_4;
                elsif ( (floor(s_v*100.0) - 10.0*floor(s_v*10.0)) = 5.0 ) then
                    data3_o <= c_5;
                elsif ( (floor(s_v*100.0) - 10.0*floor(s_v*10.0)) = 6.0 ) then
                    data3_o <= c_6;
                elsif ( (floor(s_v*100.0) - 10.0*floor(s_v*10.0)) = 7.0 ) then
                    data3_o <= c_7;
                elsif ( (floor(s_v*100.0) - 10.0*floor(s_v*10.0)) = 8.0 ) then
                    data3_o <= c_8;
                else
                    data3_o <= c_9;
                end if;
                
                s_v_old <= s_v; -- aby vypocet probehl jen jednou

              end if;
           end if;
		end if;
       
    end process p_calculate;
    
end architecture Behavioral;