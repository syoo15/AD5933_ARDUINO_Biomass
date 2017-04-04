# AD5933_ARDUINO_Biomass
## Capacitance measurement of biomass during compression using AD5933, Arduino
### What you need
* Matlab
* Arduino Uno
* AD5933 EVAL Board or customized AD5933 board <br/>

### Connecting Arduino and AD5933 EVAL Board (or custom board)
1. Connect 5V and GND pin from AD5933 EVAL Board to corresponding pins on Arduino Uno <br/>
2. Connect SDA to A4 pin on Arduino <br/>
3. Connect SCL to A5 pin on Arduino <br/>

### How Matlab code works?
1. Once wires are connected together open up serial_com.m file and run it. <br/>
2. First, AD5933 requires calibration step before starting any measurements. Choose a calibration resistor value and connect AD5933 Board to measure the resistor (Refer to reference [3] on how to choose this value). <br/>
3. Type 'p' and enter. Arduino will automatically save arrays of gainfactor and phase offset into its memory. To measure impedance over a wide range of sweep freqeuncy, multi-frequency gainfactors are saved at each point of frequency.<br/>
4. There are three different modes currently, which are followings: <br/>
* 'A' : Temperature measurement. Measure temperature for 20 secs and plot in real-time. 
* 'B' : Impedance measurement. Measure impedance and phase. Type the name of csv file. After csv file is saved, Matlab will generate plots for the data.
* 'C' : Terminate serial communication. It is highly recommended to end the program with this mode in order to ensure closing of serial port. <br/>

### Arduino software must be re-uploaded if calibration resistor value or sweep frequency parameters are to be changed. 
Modifiable variables are: <br/>
* start_frequency : Define start freqeuncy. Limit: 1000 - 100,000
* cal_samples : Define # of times you'd like to measure and take the average. (Note: Currently only works for calibration step. Will be implemented for impedance measurement in the future)
* numofIncrement : Define # of frequency increment steps. Limited up to 90 due to the memory size of Arduino Uno. (Better way to store gain factor arrays?)
* calResistance : The value of calibration resistor.
* AD5933.setStepSize(value) : Frequency step size. This should always be real number.
* AD5933.setPGA() : Gain setting. GAIN_1 for x1. GAIN_5 for x5.
* AD5933.setRange() : Output Excitation Voltage setting. RANGE_1 for 2V, RANGE_2 for 1V, RANGE_3 for 0.4V, RANGE_4 for 0.2V. Need to select carefully depending on the range of impedance to be measured. <br/>

## To do..
* Plot impedance and phase in one figure, instead of two separate ones.
* Check if the program is estimating capacitance value accurately.

## References
1. AD5933 driver codes are based on Il-Taek Kwon's work </br>
Link: [AD5933_Driver](https://github.com/WuMRC/drive)

2. CSV write with header (Matlab file) is work by Keith Brady </br>
Copyright (c) 2011, Keith Brady All rights reserved. </br>
Link: [Matlab_CSV_Header](https://www.mathworks.com/matlabcentral/fileexchange/29933-csv-with-column-headers)
