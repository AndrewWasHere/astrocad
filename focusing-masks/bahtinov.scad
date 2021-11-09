/*
   Bahtinov Mask
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
   (80mm * 5mm = 400mm). This value is used in computing the
   Bahtinov mask slit size.
*/
focal_length = 400;

/*
   Angle of rotation for angled slits, in degrees.
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
minimum_width = 0.5;

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

N = 150;
s = step_size(focal_length / N);

inner_diameter = ota_diameter + padding;
outer_diameter = inner_diameter + (2 * wall_thickness);


/********************
   Modules.
*********************/

/*
   `step_size / 2`-wide rectangles that will become the on-axis 
   slits of the mask. We only want full-width slits on the mask, so 
   the module determines how many slits will fit in the available 
   space, and centers the slits around the y-axis.
*/
module slits(face_diameter, shoulder, step_size) {
    n_steps = floor((face_diameter - (2 * shoulder)) / step_size);
    half_step = step_size / 2;
    w = half_step * n_steps;
    for (x = [-w + half_step:step_size:w - half_step]) {
        translate([x, 0, 0]) 
            square([half_step , face_diameter], center = true);
    }
}

/*
   `step_size / 2`-wide rectangles that will become the off-axis 
   slits of the mask. We only want full-width slits on the mask, so 
   the module determines how many slits will fit in the available 
   space, and positions the slits so they will fill the +x, +y face 
   area after rotation. If you do the math, you will need to fill a 
   space r*sin(theta) wide before the y-axis, and r*cos(theta) after 
   the y-axis.
*/
module angle_slits(face_radius, shoulder, theta, step_size) {
    r = face_radius - shoulder;
    start = -step_size * floor(r * sin(theta) / step_size);
    end = step_size * floor(r * cos(theta) / step_size);
    for (x = [start:step_size:end]) {
        translate([x, 0, 0]) square([step_size / 2, face_radius]);
    }
}

/*
   Half circle, above the x-axis.
*/
module half_circle(radius) {
    intersection() {
        circle(radius);
        translate([-(radius), 0, 0]) square([2 * radius, radius]);
    }
}

/*
   Quarter circle, in the +x, +y quadrant.
*/
module quarter_circle(radius) {
    intersection() {
        circle(radius);
        square(radius);
    }
}

/*
   On-axis slits mask.
*/
module horizontal_mask(radius, shoulder, step) {
    union() {
        difference() {
            half_circle(radius);
            slits(2 * radius, shoulder, step);
        }
        translate([0, step / 4, 0]) 
            square([2 * radius, step / 2], center = true);
    }
}

/*
   Off-axis slits mask.
*/
module angle_mask(radius, shoulder, theta, step) {
    union() {
        union() {
            square([step / 2, radius]);
            square([radius, step / 2]);
        }
        difference() {
            quarter_circle(radius);
            rotate([0, 0, -theta]) 
                angle_slits(radius, shoulder, theta, step);
        }
    }
}

/*
   Slits mask.
*/
module mask(diameter, shoulder, theta, step) {
    radius = diameter / 2;
    union() {
        // on-axis slits.
        horizontal_mask(radius, shoulder, step);
        // +theta off-axis slits.
        mirror([0, -1, 0]) 
            angle_mask(radius, shoulder, theta, step);
        // -theta off-axis slits.
        mirror([1, 0, 0]) 
            mirror([0, 1, 0]) 
                angle_mask(radius, shoulder, theta, step);
    }
}

/*
   The bit between the wall and the mask.
*/
module face_ring(id, od) {
    difference() {
        circle(d = od);
        circle(d = id);
    }
}

/*
   Entire face of the Bahtinov Mask.
*/
module face(diameter, step, shoulder, theta, thickness) {
    linear_extrude(height = thickness) {
        union() {
            face_ring(diameter - shoulder, diameter);
            mask(diameter, shoulder, theta, step); 
        }
    }
}

/*
   The bit that holds the mask to the OTA.
*/
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
    face(outer_diameter, s, shoulder, theta, face_thickness);
    wall(inner_diameter, outer_diameter, wall_height);
}
