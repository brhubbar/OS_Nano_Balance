/*  OS Nano Balance uses a load cell to measure and report an object's mass.
    Copyright (C) 2019 Benjamin Hubbard

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

/* External Libraries */
// Load cell amplifier.
#include "src\HX711\src\HX711.h"
// Hard Memory read/write.
#include <EEPROM.h>
// LCD Controller.
#include "src\LiquidCrystal\src\LiquidCrystal.h"

/* Globals */
// HX711
// Data pin.
const int hx_dt  = 2;
// Clock pin.
const int hx_sck = 3;
// Vcc pin - HX711 requires 3-5V @ 1.5 mA, Nano supplies 5V @ 20 mA.
const int hx_vcc = 4;
// Number of averages while measuring. *Set to 1 because the library's averaging
// is too slow and interferes with other interactions.
const int hx_num_avgs = 1;
// Number of averages while calibrating.
const int hx_cal_num_avgs = 10;
// HX711 object.
HX711 loadcell;

// LCD
// Is there an LCD?
bool isLCD = true;
// Reset pin.
const int lcd_rs = A0;
// Enable pin.
const int lcd_en = A1;
// Data pins.
const int lcd_d4 = A2;
const int lcd_d5 = A3;
const int lcd_d6 = A4;
const int lcd_d7 = A5;
// Display size.
const int lcd_rows = 2;
const int lcd_cols = 16;
// Power supply. allaboutcircuits.com suggests an LCD requires 5V @ 3mA.
const int lcd_vcc = 12;
// LCD object.
LiquidCrystal lcd;

// Calibration (EEPROM).
// Signature to store in the memory when calibrating.
char cal_sig = 'C';
// Variable to store calibration signature check.
char cal_check;
// Address of calibration signature.
int cal_sig_addr = 0;
// Address of the stored calibration value.
int cal_val_addr = sizeof(char);
// Stores the calibration value from EEPROM.
float cal_val = 0.00f;
// Mass used to calibrate (1 US cup of water);
double standard_mass = 0.2359;
// Mass units.
String units = "kg";
// Sensitivity value.
float sensitivity;


// Input pins.
// Calibrate.
const int btn_cal = 7;
// Tare.
const int btn_tare = 8;


// Readouts.
// Raw value.
double val;
// Scaled value.
float mass;
// Number of digits after the decimal.
int num_digits = 6;


/* Methods */
/* initLoadCell() 
 * Set up the HX711 for use. Turns on the device, then verifies the calibration 
 * value.
 */
HX711 initLoadCell() {
	Serial.println("Initializing HX711...");
	
	// Turn on the HX711 power supply.
	pinMode(hx_vcc, OUTPUT);
	digitalWrite(hx_vcc, HIGH);
	
	// Give it time to power on.
	delay(500);
	
	// Initialize the HX711.
	HX711 loadcell;
	loadcell.begin(hx_dt, hx_sck);
	
	// Wait until it's ready.
	bool is_ready = false;
	int num_retries = 3;
	int wait_delay = 200;
	while (!is_ready) {
		// Give some indication that it's thinking.
		Serial.print("...");
		is_ready = loadcell.wait_ready_retry(num_retries, wait_delay);
	}
	
	Serial.println("HX711 Initialized!");
	
	// Set calibration value.
	// Check if the calibration has been saved.
	Serial.println("Loading calibration...");
	EEPROM.get(cal_sig_addr, cal_check);
	if (cal_check == cal_sig) {
		// Get the saved calibration value.
		EEPROM.get(cal_val_addr, cal_val);
		Serial.print("Calibration value: ");
		Serial.print(cal_val);
		Serial.print(" div/");
		Serial.println(units);
		
		// Apply the calibration value to the driver.
		loadcell.set_scale(cal_val);
	} else {
		// There is not a stored calibration value.
		Serial.println("Calibration value is not stored.");
		Serial.println("Defaulting to calibration of 1 (raw value)");
		loadcell.set_scale(1.00f);
	}

	// Give the HX711 a chance to finish initializing.
	delay(500);
	
	// Tare the thing.
	Serial.println("Tare...");
	loadcell.tare(hx_num_avgs);
	
	return loadcell;
}


// calibrate() calibrates the load cell.
// loadcell = load cell amplifier object.
// standard_mass = mass used to calibrate.
// units = units to display in the readout. 
void calibrate() {	
	// Give the user a second to release the button.
	delay(1000);
		
	// Recall that the buttons are active LOW.
	// Start reading, wait until a button press indicates calibration is done.
	while (digitalRead(btn_cal) == 1) {
		if (digitalRead(btn_tare) == 0) {
			// TODO: Make a custom tare function to keep this DRY.
			Serial.println("Tare...");
			loadcell.tare(hx_num_avgs);
		}
		
		// Read the tared value (raw reading).
		val = loadcell.get_value(hx_cal_num_avgs);
		Serial.print("Raw Value: ");
		Serial.print(val);
		
		// Calculate the sensitivity.
		sensitivity = (float) (val / standard_mass);
			
		// Let the user know what they can now set it to.
		Serial.print(", new sensitivity: ");
		Serial.print(sensitivity, num_digits);
		Serial.print(" div/");
		Serial.print(units);
	}	// Button pressed.
	
	// Set the sensitivity.
	// TODO: Make a print_with_units function.
	Serial.print("Using sensitivity: ");
	Serial.print(sensitivity, num_digits);
	Serial.print(" div/");
	Serial.println(units);
	loadcell.set_scale(sensitivity);
	
	// Store the sensitivity to hard memory.
	EEPROM.put(cal_sig_addr, cal_sig);
	EEPROM.put(cal_val_addr, sensitivity);
	
	// Give the user a chance to release the button.
	delay(500);
	return;
}


/* initDisplay()
 * Prepare the LCD for use. Turns on the display and preps initial settings.
 */
LiquidCrystal initLCD() {
	Serial.println("Initializing LCD...");
	
	// Turn on the LCD power supply.
	pinMode(lcd_vcc, OUTPUT);
	digitalWrite(lcd_vcc, HIGH);
	
	// Give it time to power on.
	delay(500);
	
	// Initialize the display.
	LiquidCrystal lcd(lcd_rs, lcd_en, lcd_d4, lcd_d5, lcd_d6, lcd_d7);
	lcd.begin(lcd_cols, lcd_rows);
	// Clear the display.
	lcd.clear();
	// Home the cursor.
	lcd.home();
	// Hide the cursor.
	lcd.noCursor();
	// Ensure the display is on. (lcd.noDisplay() turns off the display).
	lcd.display();
	
	// Test the display.
	Serial.println("Testing the display...");
	// Print an 8 to each character in the display.
	for (int i = 0; i < lcd_rows * lcd_cols; i++) {
		lcd.print("8");
		delay(50);
	}
	delay(1000);
	lcd.clear;
	lcd.home;
	
	Serial.println("LCD initialized!");
	
	return lcd;
}


void setup() {
	Serial.begin(115200);
	while(!Serial){
		// Wait for serial to initialize.
	}	// Serial initialized.
	
	::loadcell = initLoadCell();
	if (isLCD) {
		::lcd = initLCD();
	}
	
	/* Tare and Calibarion sensors. Internal pullup resistor defaults the pin to 
	 * HIGH, meaning the tare must be connected to ground when closed/active.
	 */
	pinMode(::btn_cal, INPUT_PULLUP);
	pinMode(::btn_tare, INPUT_PULLUP);
}


void loop() {
	/* TODO: make a custom running average algorithm - using the built in averages
	 * introduces too much delay and making detection of button presses difficult.
	 */
	// See what's being measured without the calibration (but with tare offset).
	val = loadcell.get_value(hx_num_avgs);
	// Calibrated measurement.
	mass = loadcell.get_units(hx_num_avgs);
	
	// Report the measurements.
	Serial.print("Raw value: ");
	Serial.print(val);
	Serial.print(", Mass: ");
	Serial.print(mass, num_digits);
	Serial.print(" ");
	Serial.println(units);
	lcd.clear();
	lcd.home();
	lcd.print(mass, num_digits);
	lcd.print(" ");
	lcd.print(units);
	
	// Watch for a tare request.
	if (digitalRead(btn_tare) == 0) {
		Serial.println("Tare...");
		loadcell.tare(hx_num_avgs);
	}
		
	// Watch for a calibration request.
	if (digitalRead(btn_cal) == 0) {
		Serial.println("Calibrate...");
		calibrate();
	}
}