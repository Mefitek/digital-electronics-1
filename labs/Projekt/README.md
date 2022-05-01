# Measuring the speed of an object through a series of IR sensors (such as HW-201) or optical barriers

### Team members

* Petr Klíma - Team leader, Programming, Design
   * Top simulation
* Vladimír Skoumal - Testing, Hardware behaviour, Video presentation
   * Video presentation, 
   * Modules testing a description (real_switch and real_to_hex) 	
* Matěj Černohous - Programming, Documentation
   * Check english language 

### Table of contents

* [Project objectives](#objectives)
* [Hardware description](#hardware)
* [VHDL modules description and simulations](#modules)
* [TOP module description and simulations](#top)
* [Video](#video)
* [References](#references)

<a name="objectives"></a>

## Project objectives

Official assigment: "Measuring the speed of an object through a series of IR sensors (such as HW-201) or optical barriers."

After consulting with the project assignee it was specified that the object is to pass by at least 4 IR sensors (connected to 
the NEXYS A7-50T board) and it's speeds (speed in each "sector" between individual sensors) are to be calculated and displayed on NEXYS's 7segment displays.

Our objective is to fulfill the assigment, make the funcionality versitale and modular, write the code in compliance with VHDL Guidelines and document the process 
and the final product in this file and video presentation.

<a name="hardware"></a>

## Hardware description

### Nexys A7-50T Board
It is an accessible FPGA developement board with great performance: We were already familiar with it's funcionality from the Digital electronics (DE1) practicals. 
For more information see [The store page](https://store.digilentinc.com/nexys-a7-fpga-trainer-board-recommended-for-ece-curriculum/), 
[reference manual](https://reference.digilentinc.com/reference/programmable-logic/nexys-a7/reference-manual) or 
[schematic](docs/nexys-a7-sch.pdf).

<a name="sensors"></a>
### IR sensor HW-201
It's main function is to transmit and recieve reflected infrared waves (wavelength 7000-1000 nm) to signalize the passing of an object. It is important to note 
that the IR light will have trouble reflecting of off black object, as it will be absorbed. Another important thing to mention is the fact that the sensor functions 
as "Active LOW" - meaning that when no reflected light is recieved the data output is HIGH and when reflected light is recieved it's LOW. For more information see 
[The datasheet](https://store.digilentinc.com/nexys-a7-fpga-trainer-board-recommended-for-ece-curriculum/).


<a name="modules"></a>

## VHDL modules description and simulations

### Speed_measure

#### Description
As the name of module suggests this module measures speed of any object using 2 inputs for [IR sensors](#sensors), which are connected to `en_i` and `dis_i` inpusts. Module has **3 generic variables**: 
  1. `g_dist` = distance between sensors in cm, we work with it in [TOP](#top)
  2. `g_active` = it represents active state of sensors (we use g_active = 1 for simulations)
  3. `g_clk_f` = clock frequency
![Speed_measure](images/Modules/Speed_measure.png)

```vhdl
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
                      --v_o <= (g_dist *c_cmT_to_ms) / Real(s_cnt);
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
```

#### Simulation
Distance between sensors is set to 0,0025 cm and time between detections is 2000 ns (0,002 ms), so we should get speed (0,002/0,000025) = cca 12 m/s. 
- [Simulation in EDAplayground](https://www.edaplayground.com/x/SycU)
- You can see that we got a speed 12,02 m/s 

![Speed_measure simulation](images/Simulations/speed_measure.png)

<a name="top"></a>

## TOP module description and simulations

### Description
We have 4 sensors connected to PMod pins JA1, JA2, JB1, JB2 -> we have 3 sections of speed measurement + average speed. Thats why **we use 4 _speed_measure_ modules**. Outputs from these modules go into **_real_switch_** module. Speed is shown on 7-segment display based on input combination of switches

| **Switches combination** | **Displayed speed** |
| :-: | :-: |
| 00 | Average speed |
| 01 | Speed of section 1 |
| 10 | Speed of section 2 |
| 11 | Speed of section 3 |
   
```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity top is
    Port(
		-- PMods
		JA1 : in STD_LOGIC;
		JA2 : in STD_LOGIC;
		JB1 : in STD_LOGIC;
		JB2 : in STD_LOGIC;

        	CLK100MHZ : in STD_LOGIC;
		SW  : in STD_LOGIC_VECTOR (1 downto 0);
		
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

  -- Interni signaly pro rychlost
  signal s_r1       : real := 0.0 ;
  signal s_r2       : real := 0.0 ;
  signal s_r3       : real := 0.0 ;
  signal s_ravg     : real := 0.0 ;
  signal s_r        : real := 0.0 ;
  
  signal s_data0 : std_logic_vector(4 - 1 downto 0);
  signal s_data1 : std_logic_vector(4 - 1 downto 0);
  signal s_data2 : std_logic_vector(4 - 1 downto 0);
  signal s_data3 : std_logic_vector(4 - 1 downto 0);
  signal s_dp : std_logic_vector(4 - 1 downto 0);

begin	
	--------------------------------------------------------------------
	speed_measure_section_1 : entity work.speed_measure
      generic map(
          g_dist => 20.0;
	  g_active => '0'; -- Whether the input sensors are active HIGH or LOW
          g_clk_f => 100000000  -- Main clock frequency [Hz]
      )
      port map(
          clk   => CLK100MHZ,
          en_i  => JA1,
          dis_i => JA2,
          reset => '0',
          v_o	 => s_r1
      );
	--------------------------------------------------------------------
    speed_measure_section_2 : entity work.speed_measure
      generic map(
          g_dist => 30.0;
	  g_active => '0'; -- Whether the input sensors are active HIGH or LOW
          g_clk_f => 100000000  -- Main clock frequency [Hz]
      )
      port map(
          clk   => CLK100MHZ,
          en_i  => JA2,
          dis_i => JB1,
		  reset => JA1,
          v_o	 => s_r2
      );
	--------------------------------------------------------------------
    speed_measure_section_3 : entity work.speed_measure
      generic map(
          g_dist => 20.0;
	  g_active => '0'; -- Whether the input sensors are active HIGH or LOW
          g_clk_f => 100000000  -- Main clock frequency [Hz]
      )
      port map(
          clk   => CLK100MHZ,
          en_i  => JB1,
          dis_i => JB2,
		  reset => JA1,
          v_o	 => s_r3
      );
	--------------------------------------------------------------------
	speed_measure_avg : entity work.speed_measure
      generic map(
          g_dist => 70.0;
	  g_active => '0'; -- Whether the input sensors are active HIGH or LOW
          g_clk_f => 100000000  -- Main clock frequency [Hz]
      )
      port map(
          clk   => CLK100MHZ,
          en_i  => JA1,
          dis_i => JB2,
          reset  => '0',
          v_o	 => s_ravg
      );
    --------------------------------------------------------------------
	speed_real_switch : entity work.real_switch
		port map(
      
			clk   => CLK100MHZ,
			
			r1_i => s_v1,
			r2_i => s_v2,
			r3_i => s_v3,
			r4_i  => s_v,
			
			s1_i => SW(0),
			s2_i => SW(1),
	 
			r_o => s_r
      
      );
      
    speed_real_convert : entity work.real_to_hex
		port map(
      
			clk   => CLK100MHZ,
			
			real_i  => s_r,
			data0_o => s_data0,
			data1_o => s_data1,
			data2_o => s_data2,
			data3_o => s_data3,
			dp_o    => s_dp
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
```

![Top structure](images/Top.jpg)


### Description

<a name="video"></a>

## Video

Write your text here

<a name="references"></a>

## References

1. Write your text here.
