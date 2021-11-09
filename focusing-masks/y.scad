/*
   Y (Lord) Mask
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
   Focal length of OTA in millimeters.
   Focal length is the diameter of the main objective multiplied by
   the f-ratio of the OTA. e.g. for an Orion ST80, which has an
   80mm objective, and an f-ratio of 5, the focal length is 400mm.
   (80mm * 5mm = 400mm). This value is used the computing the
   thickness of the bars.
*/
focal_length = 400;

/*
   Angle of rotation for angled bars, in degrees.
   The amount to rotate the "off axis" slits. Traditionally, it's
   20 degrees, but you can use whatever value makes focusing easier
   for you.
*/
theta = 20;

/*
   The minimum slit width to print in millimeters. This can be the size of a
   slit your printer can print around without gumming up the slit, or something
   significantly larger if you want a more robust mask that won't easily break.
   The minimum value is probably slightly larger than your print head nozzle
   diameter. This actual width may be slightly larger, based on the step size
   calculation.
*/
minimum_width = 5;

/*
   Diameter of the thing the mask has to fit over, in millimeters.
   This is most likely the outer diameter of the OTA at the
   objective, or end of the lens hood.
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
   Width of the solid area on the face between the wall and the
   mask in millimeters.
*/
shoulder = min(10, 0.1 * ota_diameter);


/********************
   Computed Values.
*********************/

/*
   Bahtinov Mask step size formula is from 
   https://www.cloudynights.com/topic/178843-revolutionary-new-way-of-focusing-no-less/
   
   s = f / N
   where
     s = step size.
     f = focal length of OTA.
     N = magic number in [150, 200]
   The step size is the distance for a slit and the following bar, so
   the width of the slit (and the surrounding solids) is s / 2.
   
   The Y-Mask maximizes aperture by removing the grid of slits,
   leaving a single solid of width s / 2 for each set of slits.
*/

/*
   Returns the minimum step size for the mask slits. The conditional
   is whether or not a slit can be printed or not. If the step size
   is too small for the printer, the third-order spectrum. Keep
   increasing to the next third-order spectrum until the slits size
   is printable.
   
   Args:
      s - current step size.
*/
function step_size(s) = s < 2 * minimum_width ? 
    step_size(3 * s) : 
    s;

N = 175;  // Smack in the middle of the range.

/*
   A step includes a slit and a solid. And bar_width is the size of
   a slit.
*/
bar_width = step_size(focal_length / N) / 2;

inner_diameter = ota_diameter + padding;
outer_diameter = inner_diameter + (2 * wall_thickness);


/********************
   Modules.
*********************/

module bar(l, w) {
    translate([0, -w / 2, 0]) square([l, w]);
}

module bars(l, w, theta) {
    union() {
        bar(l, w);
        rotate([0, 0, 180 - theta]) bar(l, w);
        rotate([0, 0, 180 + theta]) bar(l, w);
    }
}

module mask(diameter, width, theta) {
    intersection() {
        circle(d = diameter);
        bars(diameter, width, theta);
    }
}

module face_ring(id, od) {
    difference() {
        circle(d = od);
        circle(d = id);
    }
}

module face(diameter, bar_width, theta, shoulder, thickness) {
    linear_extrude(height = thickness) {
        union() {
            face_ring(diameter - shoulder, diameter);
            mask(diameter, bar_width, theta); 
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
    face(outer_diameter, bar_width, theta, shoulder, face_thickness);
    wall(inner_diameter, outer_diameter, wall_height);
}
