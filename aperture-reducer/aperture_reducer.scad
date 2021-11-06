/*
   Aperture Reducer Cap
   Andrew Lin, November 2021.
*/

/**************************
   Configuration Settings
***************************/

/*
   Number of facets to use when creating shapes. Larger is smoother,
   but will take longer to compute.
*/
$fn = 50;

/*
   Diameter of the thing the cap has to fit over, in millimeters.
   This could be the outer diameter of the OTA at the objective, or 
   the diameter of the cap holder on the OTA's main objective dust
   cover.
*/
ota_diameter = 46;

/*
   Amount of total extra space between the cap's wall and the OTA it
   is going over, in millimeters.
*/
padding = 1;

/*
   Diameter of hole to put in the printed cap, in millimeters.
*/
aperture = 10;

/*
   Aperture offset from center, in millimeters.
*/
aperture_offset = 0;

/*
   Thickness of the cap's outer wall, in millimeters.
*/
wall_thickness = 1;

/*
   Height of the outer wall, in millimeters.
*/
wall_height = 10;

/*
   Thickness of the face of the cap, in millimeters.
*/
face_thickness = 1;


/**************************
   Computed Values
***************************/

inner_diameter = ota_diameter + padding;
outer_diameter = inner_diameter + (2 * wall_thickness);


/**************************
   Modules
***************************/

/*
   Cap face. 
   The bit with the hole in it.
*/
module face(diameter, aperture, dx, thickness) {
    linear_extrude(height = thickness) {
        difference() {
            circle(d = diameter);
            translate([dx, 0, 0]) circle(d = aperture);
        }
    }
}

/*
   Cap wall.
   The bit that holds the cap on the OTA.
*/
module wall(id, od, h) {
    linear_extrude(height = h) {
        difference() {
            circle(d = od);
            circle(d = id);
        }
    }
}


/**************************
   Assembly.
***************************/

union() {
    face(inner_diameter, aperture, aperture_offset, face_thickness);
    wall(inner_diameter, outer_diameter, wall_height);
}