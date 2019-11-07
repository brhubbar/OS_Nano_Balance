/* TAL220 Load Cell - Basic dimensional representation of the TAL220
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
 
 TAL220();
 
 module TAL220() {
   // Outer Dimensions (l, w, h)
   dim   = [80, 12.7, 12.7];
   
   // Hole locations.
   holeX = [-35, -20, 20, 35];
   holeY = [0, 0, 0, 0];
   
   // Hole diameters (M4, M4, M5, M5).
   diam  = [4.5, 4.5, 5.5, 5.5];
   
   // Strain gage cables
   cableThickness = 1.3;
   
   // Make the TAL220, centroid at the origin.
   difference() {
     cube(dim, center = true);
     for (i=[0:3]) {
       translate([holeX[i], holeY[i], 0])cylinder(d = diam[i], h = dim[2], center=true);
     }
   }
   
   // Add cable representation.
   translate([dim[0]/2, dim[1]/2 + cableThickness/2, 0])cube([10, cableThickness, dim[2]], center=true);
 }