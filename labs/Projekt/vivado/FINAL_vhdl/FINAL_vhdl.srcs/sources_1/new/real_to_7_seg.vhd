library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all; -- function floor()

--------------------------------------------------------------
-- Entity declaration for real to hexadecimal convertor
--
--             +------------------+
--      -------|> clk             |
--             |                  |
--      ---/---| real_i           |
--       real  |      data0_o(3:0)|---/---
--             |      data1_o(3:0)|---/---
--             |      data2_o(3:0)|---/---
--             |      data3_o(3:0)|---/---
--             |         dp_o(3:0)|---/---
--             |                  |   4
--             +------------------+
--
-- Inputs:
--   clk
--   real_i      -- Data type "real" value
--
-- Outputs:
--   dp_o(3:0):        -- Decimal point for specific digit
--   dataX_o(3:0)      -- Data values for individual digitss
--------------------------------------------------------------

entity real_to_hex is
    port(
        clk         : in  std_logic;
        data0_o : out  std_logic_vector(3 downto 0) := "0000";
        data1_o : out  std_logic_vector(3 downto 0) := "0000";
        data2_o : out  std_logic_vector(3 downto 0) := "0000";
        data3_o : out  std_logic_vector(3 downto 0) := "0000";
        dp_o    : out  std_logic_vector(3 downto 0) := "0000";
        real_i : in real
    
    );
end real_to_hex;

--------------------------------------------------------------
-- Architecture declaration for real to hexadecimal convertor
--------------------------------------------------------------

architecture Behavioral of real_to_hex is
	-- internal real to work with currently inputted value
    signal s_r			: real	:= 0.0;
    -- internal real to remember last inputted value
    signal s_r_old		: real := 0.0;
    -- internal 4-bit constants c_X containing X coded in binary
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

	----------------------------------------------------------
    -- p_calculate:
    -- A sequential process that converts the real number to
    -- a format that is required by driver_7seg_4digits
    -- (4 digits, each as a 4bit binary number and the decimal 
    --  point location)
    -- For simplicity and efficiency the format is restricted
    -- to XX.XX (meaning that the range is 00.01 - 99.99)
    ----------------------------------------------------------
    p_calculate : process(clk)
    begin
       if rising_edge(clk) then
       
           dp_o <= "1011";
           s_r <= real_i;
		
           -- only doing the necessary calculations if currect input
           -- is different than the last one
           if (s_r /= s_r_old) then
           
              -- in case the input is over 100.0, output is 99.99
              if(s_r >= 100.0) then
                  data0_o <= c_9;
                  data1_o <= c_9;
                  data2_o <= c_9;
                  data3_o <= c_9;
              
              else

                -- since we restricted the output format to XY.ZU where
                -- X = data0_o
                -- Y = data1_o
                -- Z = data2_o
                -- U = data3_o
                
                -- we can deduce the following:
                -- data0_o correspods to order of tens
                -- data1_o correspods to order of units
                -- data2_o correspods to order of tenths
                -- data3_o correspods to order of hundredths
                
                -- the floor() function from "ieee.math_real" library
                -- rounds real numbers down (e.g. 10.564 -> 10.0)
                -- using this function and basic mathematics we
                -- can output the correct values
				
                -- Notes regarding the following code:
                
                -- "case expression when" cannot be used since the
                -- expression used has to be a discreet number
                
                -- generally it is favorable to save the expressions
                -- compared in conditional statements (such as if else)
                -- into variables of corresponding type.
                -- unfortunately, that couldn't be done here - the
                -- calculation took place but calculated value wouldn't
                -- save into the corresponding variable for unknown reason
                
                
                -- calculations:
                -- order of tens:    floor(s_r/10.0)
                -- order of units:   floor(s_r) - 10.0*floor(s_r/10.0)
                -- order of tenths:  floor(s_r*10.0) - 10.0*floor(s_r)
                -- of of hundredths: floor(s_r*100.0) - 10.0*floor(s_r*10.0)
               
				-- order of tens
                if ( floor(s_r/10.0) = 0.0) then
                    data0_o <= c_0;
                elsif ( floor(s_r/10.0) = 1.0) then
                    data0_o <= c_1;
                elsif ( floor(s_r/10.0) = 2.0 ) then
                    data0_o <= c_2;
                elsif ( floor(s_r/10.0) = 3.0 ) then
                    data0_o <= c_3;
                elsif ( floor(s_r/10.0) = 4.0 ) then
                    data0_o <= c_4;
                elsif ( floor(s_r/10.0) = 5.0 ) then
                    data0_o <= c_5;
                elsif ( floor(s_r/10.0) = 6.0 ) then
                    data0_o <= c_6;
                elsif ( floor(s_r/10.0) = 7.0 ) then
                    data0_o <= c_7;
                elsif ( floor(s_r/10.0) = 8.0 ) then
                    data0_o <= c_8;
                else
                    data0_o <= c_9;
                end if;

		
                -- order of units
                if ( (floor(s_r) - 10.0*floor(s_r/10.0)) = 0.0) then
                    data1_o <= c_0;
                elsif ( (floor(s_r) - 10.0*floor(s_r/10.0)) = 1.0) then
                    data1_o <= c_1;
                elsif ( (floor(s_r) - 10.0*floor(s_r/10.0)) = 2.0 ) then
                    data1_o <= c_2;
                elsif ( (floor(s_r) - 10.0*floor(s_r/10.0)) = 3.0 ) then
                    data1_o <= c_3;
                elsif ( (floor(s_r) - 10.0*floor(s_r/10.0)) = 4.0 ) then
                    data1_o <= c_4;
                elsif ( (floor(s_r) - 10.0*floor(s_r/10.0)) = 5.0 ) then
                    data1_o <= c_5;
                elsif ( (floor(s_r) - 10.0*floor(s_r/10.0)) = 6.0 ) then
                    data1_o <= c_6;
                elsif ( (floor(s_r) - 10.0*floor(s_r/10.0)) = 7.0 ) then
                    data1_o <= c_7;
                elsif ( (floor(s_r) - 10.0*floor(s_r/10.0)) = 8.0 ) then
                    data1_o <= c_8;
                else
                    data1_o <= c_9;
                end if;

                -- order of tenths
                if ( (floor(s_r*10.0) - 10.0*floor(s_r)) = 0.0) then
                    data2_o <= c_0;
                elsif ( (floor(s_r*10.0) - 10.0*floor(s_r)) = 1.0) then
                    data2_o <= c_1;
                elsif ( (floor(s_r*10.0) - 10.0*floor(s_r)) = 2.0 ) then
                    data2_o <= c_2;
                elsif ( (floor(s_r*10.0) - 10.0*floor(s_r)) = 3.0 ) then
                    data2_o <= c_3;
                elsif ( (floor(s_r*10.0) - 10.0*floor(s_r)) = 4.0 ) then
                    data2_o <= c_4;
                elsif ( (floor(s_r*10.0) - 10.0*floor(s_r)) = 5.0 ) then
                    data2_o <= c_5;
                elsif ( (floor(s_r*10.0) - 10.0*floor(s_r)) = 6.0 ) then
                    data2_o <= c_6;
                elsif ( (floor(s_r*10.0) - 10.0*floor(s_r)) = 7.0 ) then
                    data2_o <= c_7;
                elsif ( (floor(s_r*10.0) - 10.0*floor(s_r)) = 8.0 ) then
                    data2_o <= c_8;
                else
                    data2_o <= c_9;
                end if;

                -- order of hundredths
                if ( (floor(s_r*100.0) - 10.0*floor(s_r*10.0)) = 0.0) then
                    data3_o <= c_0;
                elsif ( (floor(s_r*100.0) - 10.0*floor(s_r*10.0)) = 1.0) then
                    data3_o <= c_1;
                elsif ( (floor(s_r*100.0) - 10.0*floor(s_r*10.0)) = 2.0 ) then
                    data3_o <= c_2;
                elsif ( (floor(s_r*100.0) - 10.0*floor(s_r*10.0)) = 3.0 ) then
                    data3_o <= c_3;
                elsif ( (floor(s_r*100.0) - 10.0*floor(s_r*10.0)) = 4.0 ) then
                    data3_o <= c_4;
                elsif ( (floor(s_r*100.0) - 10.0*floor(s_r*10.0)) = 5.0 ) then
                    data3_o <= c_5;
                elsif ( (floor(s_r*100.0) - 10.0*floor(s_r*10.0)) = 6.0 ) then
                    data3_o <= c_6;
                elsif ( (floor(s_r*100.0) - 10.0*floor(s_r*10.0)) = 7.0 ) then
                    data3_o <= c_7;
                elsif ( (floor(s_r*100.0) - 10.0*floor(s_r*10.0)) = 8.0 ) then
                    data3_o <= c_8;
                else
                    data3_o <= c_9;
                end if;
                
                -- update of last calculated input
                s_r_old <= s_r;

              end if;
           end if;
		end if;
       
    end process p_calculate;
    
end architecture Behavioral;