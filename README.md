# OS_Nano_Balance
Firmware and design files for an open source digital balance with 3D printable components.
([Project Page](https://www.appropedia.org/3-D_Printable_Digital_Balance))

# Printable Parts
The bed, cover, and base utilize other supporting .scad files. These can all be
printed for a total of $2. 

# Wiring
Wiring has not yet been cleanly drawn up. 
Pin locations can be determined by looking at the .ino source code.

**Load Cell --> HX711:**  
* red --> E+  
* blk --> E-  
* grn --> A+  
* wht --> A-  

**HX711 --> Arduino:**  
The HX711 is powered by the Arduino's digital pin. 
This is possible because the Arduino can supply 20 mA of current, while the 
HX711 only requires 1.5 mA. 
* GND --> GND  
* DT  --> D2  
* SCK --> D3  
* VCC --> D4  

**Buttons --> Arduino:**  
* GND --> Cal  --> D7
* GND --> Tare --> D8

# Firmware
The firmware sends a readout to the Serial Monitor for interaction.
Arduino's Serial Plotter can be used to get a live readout of changing mass on
the balance.

## Tare
To tare, simply hit the tare button (on pin 8). This will zero the output.

## Calibrate
To calibrate, hit the calibrate button (on pin 7). 
This will send the scale into its calibrate state.
You may tare the scale while in calibration state.
The scale will take several averages and then calculate a new sensitivity.
At this time, the device is set to calibrate with 0.2359 kg, the mass of 1 US Cup of water.

## Data Logging
To log data, use a third-party client such as PuTTY, which offers session-logging
capabilities.