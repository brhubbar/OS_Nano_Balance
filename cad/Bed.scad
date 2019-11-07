/* OS Nano Balance - Bed: Accepts mass, connects to load cells
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
 
// Library of LoadCell receivers.
use <LoadCellRx.scad>;

// Bed dimensions.
minkowskiDim = [10, 10, 1];
oDim = [100, 100, 10]; //[150, 150, 10];
iDim = [95, 95, 6]; //[144, 144, 6];
// Dimensional difference - for placement.
diff = oDim - iDim;

// Make the main body.
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
    translate([oDim[0]/2, oDim[1]/2, 0])TAL220("M4", 1);
  }
     
  // Place the TAL221 at the center. The top of the hex cutout is at the origin of the Rx unit.
  //translate([oDim[0]/2, oDim[1]/2, 0])TAL221(2);
   
  // Place the TAL220 at the center. It's sized so that it fits around the TAL221.
  translate([oDim[0]/2, oDim[1]/2, 0])TAL220("M4", 2);
}

