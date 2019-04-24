
module piston(diameter, height, depth, wall, ground, ringRelPos, ringHeight, ringDepth, pinDiameter) {
    my = .001;
    difference() {

        // piston base
        translate([0, 0, -depth]) cylinder(d=diameter, h=height+depth);

        // cut piston inner
        translate([0, 0, -depth-my]) cylinder(d=diameter-2*wall, h=height+depth-ground);

        // cut sphere into ground
        translate([0, 0, height+diameter/3]) sphere(d=diameter);

        // cut rings
        for (ringPos = ringRelPos) translate([0, 0, height*ringPos]) difference() {
            cylinder(d=diameter+1, h=ringHeight, center=true);
            cylinder(d=diameter-ringDepth, h=2*ringHeight, center=true);
        }

        // cut pin hole
        rotate([90, 0, 0]) cylinder(d=pinDiameter, h=2*diameter, center=true);
    }

    // pin
    rotate([90, 0, 0]) cylinder(d=pinDiameter, h=diameter-1, center=true);
}

