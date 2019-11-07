/* TAL220 Load Cell Rx - Receives cable (base) end of TAL220
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
 
 
// General resolution.
$fn = 50;


// Place samples.
translate([-10, -10, 0])TAL220("M4");
translate([-10, 10, 0])TAL220("M5");
translate([20, 10, 0])TAL221();

translate([-10, -30, 0])TAL220("M4", 2);
translate([-10, 30, 0])TAL220("M5", 2);
translate([20, -10, 0])TAL221(2);


// Nut cutout.
// E = corner to corner.
E_M3 = 6.2; // M3: 6.01-6.35
E_M4 = 9; // M4: 7.66-8.08  
E_M5 = 10; // M5: 8.79-9.24

// M = thickness.
M_M3 = 2.4;  // M3: 2.15-2.40
M_M4 = 4.4;  //M4: 2.90-3.20 Screw head height = 4
M_M5 = 5.4; // M5: 4.40-4.70 Screw head height = 5


// Thru hole diameters (M4 or M5).
diam_M3  = 4; //3.5;
diam_M4 = 5; //4.5;
diam_M5 = 6.25; //5.5;


// Screw locations.
holeX_220 = [7.5, -7.5];
holeY_220 = [0, 0];

holeX_221 = [0, 0];
holeY_221 = [-3, 3];


// Large beam strain gage.
module TAL220(MX, Cutout) {
  // 0 = Full stand-off.
  // 1 = Solid Boss.
  // 2 = Screw Cutout.
  if (is_undef(Cutout) || Cutout == 0) {
    if (MX == "M4") {
      Rx(E_M4, M_M4, holeX_220, holeY_220, diam_M4);     
    }

    if (MX == "M5") {     
      Rx(E_M5, M_M5, holeX_220, holeY_220, diam_M5);
    }
  }

  if (Cutout == 1) {
    if (MX == "M4") {
      RxBoss(holeX_220, holeY_220, E_M4);
    }

    if (MX == "M5") {
      RxBoss(holeX_220, holeY_220, E_M5);
    }
  } 
  
  if (Cutout == 2) {
    if (MX == "M4") {
      RxThruHole(E_M4, M_M5, holeX_220, holeY_220, diam_M4);
    }

    if (MX == "M5") {
      RxThruHole(E_M5, M_M5, holeX_220, holeY_220, diam_M5);
    }
  } 
}


// Small beam strain gage.
module TAL221(Cutout) {
  if (is_undef(Cutout) || Cutout == 0) {
    Rx(E_M3, M_M3, holeX_221, holeY_221, diam_M3);
  } 

  if (Cutout == 1) {
    RxBoss(holeX_221, holeY_221, E_M3);
  }
  
  if (Cutout == 2) {
    RxThruHole(E_M3, M_M3, holeX_221, holeY_221, diam_M3);
  }
}


// Building Blocks.
// Boss for screw to pass through.
module RxBoss(holeX, holeY, E){
  for (i=[0:1]) {
    translate([holeX[i], holeY[i], 0])cylinder(d = E+6, h = 15);
  }
}


// Through hole (holds screw and nut).
module RxThruHole(E, M, holeX, holeY, diam) {
  // Thru hole
  for (i=[0:1]) {
    translate([holeX[i], holeY[i], 0])cylinder(d = diam, h = 15);

    // Nut receiver
    translate([holeX[i], holeY[i], 0])cylinder(d = E, h = M);//, $fn=6);
  }
}


// Build the full receiver (thru hole cut out of boss).
module Rx(E, M, holeX, holeY, diam) {
  translate([0, 0, 0])difference() { 
    RxBoss(holeX, holeY, E);
    RxThruHole(E, M, holeX, holeY, diam);
  }
}