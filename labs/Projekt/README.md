# Measuring the speed of an object through a series of IR sensors (such as HW-201) or optical barriers

### Team members

* Petr Klíma - Team leader, Programming, Design
   * Top simulation
   * Odkazy na kody misto bloku kodu
* Vladimír Skoumal - Testing, Hardware behaviour, Video presentation
   * Video presentation, 
   * Modules testing a description (real_switch and real_to_hex) 	
* Matěj Černohous - Programming, Documentation
   * Check english language
   * Comment TOP source code
* Together - finish TOP description


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
Distance between sensors is set to 0,0025 cm and time between detections is 2080 ns (0,00208 ms), so we should get speed (0,000025/0,00000208) = approx. 12,019 m/s. 
- [Simulation in EDAplayground](https://www.edaplayground.com/x/SycU)
- You can see that we got a speed ~ 12,02 m/s 

![Speed_measure simulation](images/Simulations/speed_measure.png)

### Speed_measure_logic

#### Description
This module was supposed to replace the module speed_measure after figuring out that program using data type real cannot be synthetized (therefore cannot be uploaded onto the board). As can be seen on the images bellow, the only real differences were different data types and different calculation of final speed.

[speed_measure_logic.vhd](modules/speed_measure_logic.vhd)

**Changes in generic variables**: 

  1. `g_dist` = now as an unsigned with 5 bits (up to 31 cm - more than length of our connector cables)
  2. `g_clk_f` = now as an unsigned with 27 bits (up to ~ 134*10^6 - more than the board main clock's frequency)

**Changes in output**:

  `v_o` = now a 32 bit logic vector (why 32 bits -> see local variable `s_help`)
  
**Changes in local variables**:
   
   1. `s_v` = 32 bit unsigned number used for speed calculation, later converted to logic vector as the module's output
   2. `s_help` = replacement of `c_cmT_to_ms` - 32 bits needed because multiplying two binary numbers of M & N bits requires M+N bits (27+5 = 32)

**Changes in speed calculation**:
  
  Speed is now calculated by taking advantage of the fact that when a number is shifted by X bits, it is equivalent to deviding that number by 2^X. We do of course 
  lose some precision, but since the displayed speed is in range of 00.00 ÷ 99.99 m/s the units of cm/s are sufficient.

**Change comparison**:
  Comparison of parts of the speed_measure module (on the left) and speed_measure_logic module (on the right) 

![speed_measure_logic comparison 1](images/speed_measure_logic/speed_measure_logic1.png)
![speed_measure_logic comparison 2](images/speed_measure_logic/speed_measure_logic2.png)

#### Simulation
During the simulation we encountered an unknown error that we weren't able to fix. For the lack of time to consult this problem with the project assignee, we were 
unable to implement this module into the final version of the project.
- [EDAplayground link](https://www.edaplayground.com/x/jZ7T)


![Speed_measure_logic simulation error](images/speed_measure_logic/error.png)

<a name="top"></a>

### Real_switch

![Speed_measure](images/Simulations/real_switch_block.png) 

Real switch module is similar to a Multiplexor. There are four inputs - `r1_i`, `r2_i`, `r3_i`, `r4_i`, 2 controlling inputs `s1_i`, `s2_i` and one output - `r_o`. Which of the four inputs is outputted is determined by the combination of the controlling inputs.

![Real switch](images/Simulations/real_switch.png) 

| **Controlling inputs (s2_i s1_i)** | **Output** |
| :-: | :-: |
| 0 0 | `r4_i` |
| 0 1 | `r3_i` |
| 1 0 | `r2_i` |
| 1 1 | `r1_i` |

The table shows the relation of controlling inputs and output.

### Real_to_hex

![real to hex module](images/Simulations/real_to_hex_block.png)

![real_to_hex.vhd](modules/real_to_hex.vhd)

This modules!s function is to convert a data type real number into a hexadecimal number (including the decimal point). The module's input `real_i` is converted (through function floor() from the `ieee.math_real` library). 
It is important to note that the conversion code is nowhere neal ideal and conventional, since working with the data type real variables is somewhat tricky. It would be favorable to use custom functions for the calculations. 
The range of outputted hexadecimal number was decided to be "XX.XX" - which meant we would be able to display speeds between 0.01 - 99.99 m/s. The output `dp_o` represents the decimal point's position and outputs 
`data0_o`, `data1_o`, `data2_o`, `data3_o` represent the individual decimals.

#### Algorithm

Despite the code looking complicated at first, it is a fairly simple chain of if-else if conditional statements, each of them being responsible for one of the four orders of magnitude (tens, units, tenths, hundredths). 
Depending on the rounded value the output of that spicific order is set to the appropriate (hexa)decimal constant.

#### Simulation

In the simulation wave is shown input signal like real number and the converted output signals like hexadecimal numbers.

- [EDAplayground link](https://www.edaplayground.com/x/uEgg)
![real to hex simulation](images/Simulations/real_to_hex.png)

## TOP module description and simulations

### Description
By having 4 sensors connected to PMod pins JA1, JA2, JB1, JB2 we have 3 "sections" of speed measurement + average speed across all sectors. That's why **we use 4 _speed_measure_ modules**. Outputs from these modules go into **_real_switch_** module. Which of the 4 speeds is shown on the 7-segment display is determined by the combination of switches (principle of multiplexor). But before that the output signal from **_real_switch_** is inputted to the module **_real_to_hex_**, which tranforms the data type real signal to hexadecimal format (including the decimal point). The output signal of said module is then inputted to the module **_driver_7seg_4digits_**, which makes it possible for the data to be displayed on the 7segment display.

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



------------------------------------------------------------
-- Entity declaration for top
------------------------------------------------------------
entity top is
    Port(
	-- PMod pins
		JA1 : in STD_LOGIC;
		JA2 : in STD_LOGIC;
		JB1 : in STD_LOGIC;
		JB2 : in STD_LOGIC;

        -- Clock
        	CLK100MHZ : in STD_LOGIC;

        -- Switches
		SW 		  : in STD_LOGIC_VECTOR (1 downto 0);
		
        -- 7segment display cathodes
		CA : out STD_LOGIC;
		CB : out STD_LOGIC;
		CC : out STD_LOGIC;
		CD : out STD_LOGIC;
		CE : out STD_LOGIC;
		CF : out STD_LOGIC;
		CG : out STD_LOGIC;
        -- 7segmet display decimal point
		DP : out STD_LOGIC;
		 
        -- 7segment display anodes
		AN : out STD_LOGIC_VECTOR (7 downto 0)  
    );
end entity top;

------------------------------------------------------------------------
-- Architecture body for top level
------------------------------------------------------------------------
architecture Behavioral of top is

  -- Internal signals between speed_measure modules and real_switch
  signal s_r1       : real := 0.0 ;
  signal s_r2       : real := 0.0 ;
  signal s_r3       : real := 0.0 ;
  signal s_ravg     : real := 0.0 ;

  -- Internal signal between real_switch and real_to_hex
  signal s_r        : real := 0.0 ;
  
  -- Internal signal between real_to_hex and driver_7seg_4digits
  signal s_data0 : std_logic_vector(4 - 1 downto 0);
  signal s_data1 : std_logic_vector(4 - 1 downto 0);
  signal s_data2 : std_logic_vector(4 - 1 downto 0);
  signal s_data3 : std_logic_vector(4 - 1 downto 0);
  signal s_dp : std_logic_vector(4 - 1 downto 0);

begin	
	--------------------------------------------------------------------
    -- Instance (copy) of speed_measure entity (first)
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

    --------------------------------------------------------------------
    -- FOur instances (copie) of speed_measure entity
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
      
     speed_real_switch  : entity work.real_switch
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
    --------------------------------------------------------------------

    --------------------------------------------------------------------
    -- Instance (copy) of real_to_hex entity 
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
    
    --------------------------------------------------------------------
    
    --------------------------------------------------------------------
    -- Instance (copy) of driver_7seg_4digits entity 
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
    --------------------------------------------------------------------
        

    -- Disconnect the unused part of the 7-segment display
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
