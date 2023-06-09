/********************************************************
 * Hook Clip - vsergeev
 * https://github.com/vsergeev/3d-hook-clip
 * CC-BY-4.0
 *
 * Release Notes
 *  * v1.0 - 06/20/2023
 *      * Initial release.
 ********************************************************/

/* [Basic] */

hook_capacity = 5;

clip_profile = "ewg_pitch3"; // [ewg_pitch3, size2_pitch6p5, size6_pitch5, custom]

/* [Custom Profile] */

// in mm
custom_hook_gap = 22.5;
// in mm
custom_hooks_pitch = 3;
// in mm
custom_hook_slot_length = 4;
// in mm
custom_hook_holder_length = 2;
// in mm
custom_hook_holder_diameter = 1.25;
// in mm
custom_hook_slot_diameter = 1;
// in mm
custom_clip_thickness = 3;
// in mm
custom_clip_radius = 2;
// in degrees
custom_hook_slot_angle = 45;

/* [Clearances] */

// in mm
hook_holder_gap = 0.25;

/* [Hidden] */

$fn = 100;

overlap_epsilon = 0.01;

/******************************************************************************/
/* Profiles */
/******************************************************************************/

{}

/* Gamakatsu Offset EWG 1/0 and 2/0 */
ewg_pitch3_profile = [
    12,     // hook_gap (mm)
    3,      // hooks_pitch (mm)
    /*******************************/
    4.50,   // hook_slot_length (mm)
    4.00,   // hook_holder_length (mm)
    1.25,   // hook_holder_diameter (mm)
    0.50,   // hook_slot_diameter (mm)
    2.5,    // clip_thickness (mm)
    2,      // clip_radius (mm)
    0,      // hook_slot_angle (degrees)
];

/* 1/16 oz Jighead */
size2_pitch6p5_profile = [
    6,      // hook_gap (mm)
    7,      // hooks_pitch (mm)
    /*******************************/
    4.50,   // hook_slot_length (mm)
    4.00,   // hook_holder_length (mm)
    1.25,   // hook_holder_diameter (mm)
    0.50,   // hook_slot_diameter (mm)
    2.5,    // clip_thickness (mm)
    2,      // clip_radius (mm)
    0,      // hook_slot_angle (degrees)
];

/* 1/32 oz Jighead */
size6_pitch5_profile = [
    4,      // hook_gap (mm)
    5,      // hooks_pitch (mm)
    /*******************************/
    4.00,   // hook_slot_length (mm)
    3.50,   // hook_holder_length (mm)
    1.00,   // hook_holder_diameter (mm)
    0.40,   // hook_slot_diameter (mm)
    2.5,    // clip_thickness (mm)
    2,      // clip_radius (mm)
    0,      // hook_slot_angle (degrees)
];

custom_profile = [
    custom_hook_gap,
    custom_hooks_pitch,
    custom_hook_slot_length,
    custom_hook_holder_length,
    custom_hook_holder_diameter,
    custom_hook_slot_diameter,
    custom_clip_thickness,
    custom_clip_radius,
    custom_hook_slot_angle,
];

/******************************************************************************/
/* Derived Parameters */
/******************************************************************************/

/* Choose profile */
profile = (clip_profile == "ewg_pitch3")        ? ewg_pitch3_profile :
          (clip_profile == "size2_pitch6p5")    ? size2_pitch6p5_profile :
          (clip_profile == "size6_pitch5")      ? size6_pitch5_profile :
                                                  custom_profile;

/* Extract profile parameters */
hook_gap = profile[0];
hooks_pitch = profile[1];
hook_slot_length = profile[2];
hook_holder_length = profile[3];
hook_holder_diameter = profile[4];
hook_slot_diameter = profile[5];
clip_thickness = profile[6];
clip_radius = profile[7];
hook_slot_angle = profile[8];

/* Compute overall width and height of the clip */
overall_width = (hook_capacity - 1) * hooks_pitch + hook_holder_diameter + min(max(hooks_pitch + hook_slot_diameter, 5), 5);
overall_height = hook_gap + hook_slot_length + hook_holder_length;

/******************************************************************************/
/* 2D Profiles */
/******************************************************************************/

module profile_hook_holder() {
    translate([0, -hook_holder_diameter / 2]) {
        union() {
            /* Hook Holder */
            circle(d=hook_holder_diameter);

            /* Wall Gap */
            translate([0, -(hook_holder_length - hook_holder_diameter / 2 + overlap_epsilon) / 2])
                square([hook_holder_gap, hook_holder_length - hook_holder_diameter / 2 + overlap_epsilon], center=true);
        }
    }
}

module profile_hook_slot() {
    translate([0, hook_slot_diameter / 2]) {
        union() {
            /* Circle */
            circle(d=hook_slot_diameter);

            /* Extension */
            translate([-hook_slot_diameter / 2, 0])
                square([hook_slot_diameter, hook_slot_length - hook_slot_diameter / 2 + overlap_epsilon]);
        }
    }
}

module profile_hook_clip() {
    hook_offset = (hooks_pitch - hook_holder_diameter);

    difference() {
        /* Base */
        offset(r=clip_radius)
            offset(delta=-clip_radius)
                square([overall_width, overall_height], center=true);

        /* Hook Slots */
        for (i = [0 : hook_capacity - 1]) {
            translate([i * hooks_pitch - ((hook_capacity - 1) * hooks_pitch) / 2, overall_height / 2 - hook_slot_length])
                    profile_hook_slot();
        }

        /* Hook Holders */
        for (i = [0 : hook_capacity - 1]) {
            translate([i * hooks_pitch - ((hook_capacity - 1) * hooks_pitch) / 2, -overall_height / 2 + hook_holder_length])
                profile_hook_holder();
        }
    }
}

/******************************************************************************/
/* 3D Extrusions */
/******************************************************************************/

module hook_clip() {
    difference() {
        /* Clip Body */
        linear_extrude(clip_thickness, convexity=hook_capacity + 1)
            profile_hook_clip();

        /* Angled Rear */
        translate([0, overall_height / 2 + overlap_epsilon, clip_thickness + overlap_epsilon])
            rotate([0, 90, 180])
                linear_extrude(overall_width + overlap_epsilon, center=true)
                    polygon([[0, 0], [clip_thickness + overlap_epsilon, 0],
                             [0, clip_thickness * tan(hook_slot_angle) + overlap_epsilon]]);
    }
}

/******************************************************************************/
/* Top-level */
/******************************************************************************/

hook_clip();
