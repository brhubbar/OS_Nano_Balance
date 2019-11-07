/* OS Nano Balance - Base: Accepts load cell, holds electronics.
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
 
 $fn = 50;
 
// Library of LoadCell receivers.
use <LoadCellRx.scad>;

// Snap Pieces.
use <snap_joint.scad>;

// Bed dimensions.
minkowskiDim = [10, 10, 1];
oDim = [150, 105, 30]; //[150, 150, 10];
iDim = [145, 100, 26]; //[144, 144, 6];
// Dimensional difference - for placement (also = shell thickness * 2)
diff = oDim - iDim;

// Front bevel.
bevelL = 39.35;


// Switch dimensions.
swL = 21.5;
swW = 13;

// Screen dimensions.


// Make the main body.
module mainBody() {
  difference(){
    union(){
      translate([minkowskiDim[0], minkowskiDim[1], 0])difference(){
        minkowski(){
          cube(oDim - minkowskiDim*2);
          cylinder(r = minkowskiDim[0], h = minkowskiDim[2]);
        }
        minkowski(){
          translate([diff[0]/2, diff[1]/2, diff[2]])cube(iDim - minkowskiDim*2);
          cylinder(r = minkowskiDim[0], h = minkowskiDim[2]*2);
        }
      }
      // Place the TAL221 at the center. The top of the hex cutout is at the origin of the Rx unit.
      //translate([oDim[0]/2, oDim[1]/2, 0])TAL221(1);
       
      // Place the TAL220 at the center. It's sized so that it fits around the TAL221.
      translate([oDim[0]/3, oDim[1]/2, 0])TAL220("M5", 1);
    }
       
    // Place the TAL221 at the center. The top of the hex cutout is at the origin of the Rx unit.
    //translate([oDim[0]/2, oDim[1]/2, 0])TAL221(2);
     
    // Place the TAL220 at the center. It's sized so that it fits around the TAL221.
    translate([oDim[0]/3, oDim[1]/2, 0])TAL220("M5", 2);
    
    // Cut out the back for load cell rating visibility and nano access.
    translate([iDim[0]*0.9, diff[1]/2, 8+diff[2]])cube([iDim[0]*0.2, iDim[1]/2, iDim[2]]);
  }
}


difference() {
  mainBody();
    // Front bevel cutout.
  translate([0, 0, diff[0]])rotate([0, -35, 0])cube([bevelL, oDim[1], bevelL]);
}

intersection(){
        translate([minkowskiDim[0], minkowskiDim[1], 0])minkowski(){
          cube(oDim - minkowskiDim*2);
          cylinder(r = minkowskiDim[0], h = minkowskiDim[2]);
        }

  translate([0, 0, diff[0]])rotate([0, -35, 0])cube([bevelL, oDim[1], diff[0]]);
}


// Place the arduino nano

