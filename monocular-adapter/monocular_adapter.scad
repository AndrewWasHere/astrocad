/* Values in mm */
eyepiece_d = 39.5;
eyepiece_h = 5;
eye_relief = 7;

lens_offset_x = 27.5;
lens_offset_x_bottom = 50;
lens_offset_y = 22;

phone_thickness = 11;

bracket_x = 50;
bracket_x_bottom = 74;
bracket_x_full = 78;
bracket_y = 45;
bracket_z = 5 + eye_relief;
bracket_wall_thickness = 2.5;
bracket_wall_height = bracket_z + phone_thickness;

$fn = 100;

module eyepiece() {
    cylinder(h=eyepiece_h, d=eyepiece_d);
    translate([0, 0, eyepiece_h]) {
        cylinder(h=eye_relief, d1=eyepiece_d, d2=eyepiece_d - 5);
    }
}

module phone_bracket() {
    cube([bracket_x, bracket_y, bracket_z]);
    translate([0, -bracket_wall_thickness, 0]) {
        cube([bracket_x, bracket_wall_thickness, bracket_wall_height]);
    }
    translate([-bracket_wall_thickness, 0, 0]) {
        cube([bracket_wall_thickness, bracket_y, bracket_wall_height]);
    }
    translate([-bracket_wall_thickness, -bracket_wall_thickness, 0]) {
        cube([bracket_wall_thickness, bracket_wall_thickness, bracket_wall_height]);
    }
}

module phone_bracket_bottom() {
    cube([bracket_x_bottom, bracket_y, bracket_z]);
    translate([0, -bracket_wall_thickness, 0]) {
        cube([bracket_x_bottom, bracket_wall_thickness, bracket_wall_height]);
    }
    translate([bracket_x_bottom, 0, 0]) {
        cube([bracket_wall_thickness, bracket_y, bracket_wall_height]);
    }
    translate([bracket_x_bottom, -bracket_wall_thickness, 0]) {
        cube([bracket_wall_thickness, bracket_wall_thickness, bracket_wall_height]);
    }
}

module phone_bracket_full() {
    cube([bracket_x_full, bracket_y, bracket_z]);
    translate([0, -bracket_wall_thickness, 0]) {
        cube([bracket_x_full, bracket_wall_thickness, bracket_wall_height]);
    }
    translate([bracket_x_full, 0, 0]) {
        cube([bracket_wall_thickness, bracket_y, bracket_wall_height]);
    }
    translate([-bracket_wall_thickness, 0, 0]) {
        cube([bracket_wall_thickness, bracket_y, bracket_wall_height]);
    }        
    translate([bracket_x_full, -bracket_wall_thickness, 0]) {
        cube([bracket_wall_thickness, bracket_wall_thickness, bracket_wall_height]);
    }
    translate([-bracket_wall_thickness, -bracket_wall_thickness, 0]) {
        cube([bracket_wall_thickness, bracket_wall_thickness, bracket_wall_height]);
    }
}


module top_mount_bracket() {
    difference() {
        phone_bracket();
        translate([lens_offset_x, lens_offset_y, 0]) {
            eyepiece();
        }
    }
}

module bottom_mount_bracket() {
    difference() {
        phone_bracket_bottom();
        translate([bracket_x_bottom - lens_offset_x_bottom, lens_offset_y, 0]) {
            eyepiece();
        }
    }
}

module full_bracket() {
    difference() {
        phone_bracket_full();
        translate([lens_offset_x, lens_offset_y, 0]) {
            eyepiece();
        }
    }
}

full_bracket();