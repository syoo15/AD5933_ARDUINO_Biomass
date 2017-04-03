// Arduino Code for estimating bulk density of biomass during compression
// Idea: Measure the change of capacitance over frequency 
// Measured data are saved and plotted through Matlab program
// Author: Seokchan Yoo
// Date: April-03-2017
// Reference: AD5933 Library code is based on Il-Taek Kwon 
// URL Link: https://github.com/WuMRC/drive


#define cycles_base 15
#define cycles_multiplier 1
#define start_frequency 1000
#define cal_samples 1

#include "AD5933.h"
#include <Wire.h>


// Constant Variable Declarations
// Future work: Store arrays efficiently so that we can save memory space and increase a number of frequency increment
const int numofIncrement = 90;
const double calResistance = 10000;
double gainF[numofIncrement+1];
double phShift[numofIncrement+1];
double impVal[numofIncrement+ 1];
double phVal[numofIncrement+ 1];
char state;
double temp;

void setup()
{
  Wire.begin();        // join i2c bus (address optional for master)
  Serial.begin(115200);  // start serial for output

  // Basic AD5933 register setup commands
  //setByte(0x81, 0x18); // Reset & Use Ext. Clock - 0001 1000
  AD5933.setExtClock(false);
  AD5933.resetAD5933();
  AD5933.setStartFreq(start_frequency);
  AD5933.setSettlingCycles(cycles_base, cycles_multiplier);
  AD5933.setStepSize(1000);
  AD5933.setNumofIncrement(90);
  AD5933.setPGA(GAIN_1);
  AD5933.setRange(RANGE_3);
  AD5933.tempUpdate();

  // Automatic Calibration upon boot
  Serial.println(F("Please setup for calibration. If completed, press p and Enter>"));
  while( Serial.read() != 'p');
    
  AD5933.getGainFactorsSweep(calResistance,cal_samples, gainF, phShift);
  //printGainFactor();  // Check gain factor 
  Serial.println(F("Calibration Done!"));
  /*
  Serial.println("Change resistor to measure! If completed, press p and Enter>");
  while( Serial.read() != 'p')
    ;
  */
}

void loop()
{
  AD5933.tempUpdate();  // Update temperature without reading it in order to increase accuracy
  
 if(Serial.available()>0) {
      state = Serial.read();

      //FSM
      switch(state) {
        case 'A':  //Program Registers
          AD5933.tempUpdate();
          AD5933.setCtrMode(TEMP_MEASURE);
          delay(10);
          temp = AD5933.getTemperature();
          Serial.println(temp);
          delay(10);
          AD5933.setCtrMode(STAND_BY);
          break;
          
        case 'B':
          AD5933.getComplexSweep(gainF, phShift, impVal, phVal);
          printImpedanceData();
          break;
      }
      Serial.flush();
    }
}

// Print Gain Factor array
void printGainFactor(){
  for(int i = 0; i < numofIncrement+1; i++)
  {
  Serial.println(gainF[i]);
  Serial.println(phShift[i]);
  }
}

// Print Impedance Data with 5 digits precision
void printImpedanceData(){
  int cfreq = start_frequency/1000;
  for(int i =0; i < numofIncrement+1; i++, cfreq++){
            Serial.println(cfreq);
            //Serial.println(F("kHz"));
            //Serial.print(F("|Z|="));
            Serial.println(impVal[i],5);
            //Serial.print(F("Phi="));
            Serial.println(phVal[i],5);   // in Radian
            delay(10);
   }
}

