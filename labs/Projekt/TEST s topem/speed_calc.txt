library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity speed_calc is

	generic(
    	-- konstanty potrebne pro vypocet rychlosti:
        g_DELKA_1 	: natural := 20; -- delka useku 1 v cm
     	g_DELKA_2 	: natural := 20;
      	g_DELKA_3 	: natural := 20;
        g_clk_freq : natural := 100000000  -- frekvence clocku v Hz  
    );

    port(
    	-- hodinovy signal z desky
        clk         : in  std_logic;
        
        -- vystupni signaly ze senzoru
        sensor_1_i    : in  std_logic;
        sensor_2_i    : in  std_logic;
        sensor_3_i    : in  std_logic;
        sensor_4_i    : in  std_logic;
        
        speed_1_o		: out real := 0.0;
        speed_2_o		: out real := 0.0;
        speed_3_o		: out real := 0.0;
        speed_o	: out real := 0.0
    );
    
end speed_calc;

architecture Behavioral of speed_calc is

	type t_state is (L_SECTOR_1,
                     L_SECTOR_2,
                     L_SECTOR_3,
                     L_WAIT,
                     R_SECTOR_1,
                     R_SECTOR_2,
                     R_SECTOR_3,
                     R_WAIT,
                     READY);
                     
    signal s_state : t_state := READY;

    -- Cas straveny v useku
    signal s_cnt_1      : natural := 1; -- zacatek: 1, abychom neprisli o prvni inkrementaci
    signal s_cnt_2      : natural := 1;
    signal s_cnt_3      : natural := 1;
      
   	-- promena pro reset
    signal s_reset      : std_logic := '0';

    -- Delka useku v cm
    constant c_DELKA 	: natural := (g_DELKA_1 + g_DELKA_2 + g_DELKA_3);
    
    -- konstanta pro prevod z cm/T_clocku na m/s
   	constant c_cmT_to_ms : real := Real(g_clk_freq)/100.0;


begin

    p_measure : process(clk)
    begin
    
        if rising_edge(clk) then
        
            -- pokud counter cita dyl nez 5 vterin -> restart
            if ((s_cnt_1>(5*g_clk_freq)) or (s_cnt_2>(5*g_clk_freq))) then
                  s_reset <= '1';
                  s_state <= READY;
            end if; 
			
			-- restart counteru 
         	if (s_reset = '1') then
                      s_cnt_1 <= 1;
                      s_cnt_2 <= 1;
                      s_cnt_3 <= 1;
                      s_reset <= '0';
            end if;
            
            case s_state is

                  -- ZLEVA, prvni usek
                  when L_SECTOR_1 =>

                      if (sensor_2_i = '0') then
                          s_cnt_1 <= s_cnt_1 + 1;
                      else
                          speed_1_o <= (Real(g_DELKA_1) / Real(s_cnt_1))*c_cmT_to_ms; -- rychlost v m/s
                          s_state <= L_SECTOR_2;
                      end if;

                  -- ZLEVA, druhy usek
                  when L_SECTOR_2 =>

                      if(sensor_3_i = '0') then
                          s_cnt_2 <= s_cnt_2 + 1;
                      else
                          speed_2_o <= (Real(g_DELKA_2) / Real(s_cnt_2))*c_cmT_to_ms;
                          s_state <= L_SECTOR_3;
                      end if;
                      
				  -- ZLEVA, treti usek
                  when L_SECTOR_3 =>

                      if(sensor_4_i = '0') then
                          s_cnt_3 <= s_cnt_3 + 1;
                      else
                          speed_3_o <= (Real(g_DELKA_3) / Real(s_cnt_3))*c_cmT_to_ms;
                          speed_o	<= ( Real(c_DELKA) / (Real(s_cnt_3) + Real(s_cnt_2) + Real(s_cnt_1)))*c_cmT_to_ms;
                          s_reset <= '1';
                          s_state <= L_WAIT; -- probiha mereni, ZLEVA 
                      end if;
					
                  -- ZLEVA, cekani na dokonceni mereni
                  when L_WAIT =>
                      if(sensor_4_i = '0') then
                          s_state <= READY;
                      end if;

                  -- ZPRAVA, treti usek
                  when R_SECTOR_3 =>

                      if(sensor_3_i = '0') then
                          s_cnt_3 <= s_cnt_3 + 1;
                      else
                          speed_3_o <= (Real(g_DELKA_3) / Real(s_cnt_3))*c_cmT_to_ms;
                          s_state <= R_SECTOR_2;
                     end if;

                  -- ZPRAVA, druhy usek
                  when R_SECTOR_2 =>

                      if(sensor_2_i = '0') then
                          s_cnt_2 <= s_cnt_2 + 1;
                      else
                          speed_2_o <= (Real(g_DELKA_2) / Real(s_cnt_2))*c_cmT_to_ms;
                          s_state <= R_SECTOR_1;
                      end if;
                  
                  -- ZPRAVA, prvni usek
				  when R_SECTOR_1 =>

                      if(sensor_1_i = '0') then
                          s_cnt_1 <= s_cnt_1 + 1;
                      else
                          speed_1_o <= (Real(g_DELKA_1) / Real(s_cnt_1))*c_cmT_to_ms;
                          speed_o	<= ( Real(c_DELKA) / Real(s_cnt_3+s_cnt_2+s_cnt_1))*c_cmT_to_ms;
                          s_reset <= '1';
                          s_state <= R_WAIT; -- probiha mereni, ZPRAVA
                      end if;
				
                  -- ZPRAVA, cekani na dokonceni mereni
                  when R_WAIT =>
                      if(sensor_1_i = '0') then
                          s_state <= READY;
                      end if;  

                  when READY =>

                      -- pokud reaguje prvni senzor, merime ZLEVA
                      if(sensor_1_i = '1') then
                          s_state <= L_SECTOR_1;
                      end if;

                      -- pokud reaguje treti senzor, merime ZPRAVA
                      if(sensor_4_i = '1') then
                          s_state <= R_SECTOR_3;
                      end if;

                  when others =>
                      -- prikazy
            end case;
        end if;
    end process p_measure;
    
end architecture Behavioral;
