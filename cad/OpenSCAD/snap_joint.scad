/* OpenSCAD Snap Joint
    Copyright (C) 2019  Benjamin Hubbard

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
 

module snap_joint(size, isCutout) {
  height = size * 5;
  width = size * 6;
 
  if (isCutout) {
    height = height * 1.1;
    width = width * 1.1;
    
    union(){
      translate([-size*0.6, 0, height/2])
        cube([size * 2.5, width, height], center = true);
      
      translate([size * 0.6, 0, height - 1.25 * size])
        scale([1, 1, 1])
            cube([size * 1, width, size * 2.5], center = true);
    }
  }
  
  if (!isCutout) {
    union(){
      translate([0, 0, height / 2])
        cube([size, width, height], center = true);
      
      translate([size / 2, 0, height - size])
        scale([0.6, 1, 1])
          rotate([0, 45, 0])
            cube([size * sqrt(2), width, size * sqrt(2)], center = true);
    }
  }
}



// Sample render.
// Hole size, mm.
size = 1;

snap_joint(size, 0);
%snap_joint(size, 1);