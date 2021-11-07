/*
   Hartmann Mask
   Andrew Lin, November 2021
*/


/********************
   Settings. 
*********************/

/*
   Number of facets to use when creating shapes. Larger is smoother,
   but will take longer to compute.
*/
$fn = 100;

/*
   Diameter of the thing the mask has to fit over, in millimeters.
   This is most likely the outer diameter of the OTA at the
   objective.
*/
ota_diameter = 100;

/*
   Amount of total extra space between the cap's wall and the OTA it
   is going over, in millimeters.
*/
padding = 1;

/*
   Thickness of the mask's outer wall, in millimeters.
*/
wall_thickness = 1;

/*
   Height of the outer wall, in millimeters.
*/
wall_height = 10;

/*
   Thickness of the face of the mask, in millimeters.
*/
face_thickness = 1;

/*
   Diameter of holes to put in the printed cap, in millimeters.
   For non-circular apertures, this is the diameter of the inscribed
   circle, so the actual polygons are slightly smaller.
*/
aperture = ota_diameter / 3;


/********************
   Computed Values.
*********************/

inner_diameter = ota_diameter + padding;
outer_diameter = inner_diameter + (2 * wall_thickness);


/********************
   Modules.
*********************/

module face(diameter, aperture, thickness) {
    offset = diameter / 4;  // Half the face radius.
    dx = offset * cos(30);
    dy = offset * sin(30);
    linear_extrude(height = thickness) {
        difference() {
            circle(d = diameter);
            
            // If you want circles, delete the $fn arguments.
            translate([0, offset, 0]) circle(d = aperture, $fn = 3);
            translate([dx, -dy, 0]) circle(d = aperture, $fn = 3);
            translate([-dx, -dy, 0]) circle(d = aperture, $fn = 3);
        }
    }
}

module wall(id, od, h) {
    linear_extrude(height = h) {
        difference() {
            circle(d = od);
            circle(d = id);
        }
    }
}


/********************
   Assembly.
*********************/

union() {
    face(outer_diameter, aperture, face_thickness);
    wall(inner_diameter, outer_diameter, wall_height);
}
