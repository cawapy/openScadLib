
module rod(length, baseWidth, topWidth, depth, topDepth=undef, baseDepth=undef, wall, baseBearingDiameter, topBearingDiameter, baseBearingDepth, topBearingDepth) {
    my = .001;
    _topDepth = topDepth == undef ? depth : topDepth;
    _baseDepth = baseDepth == undef ? depth : baseDepth;

    difference() {
        hull() {
            cylinder(h=_baseDepth, d=baseWidth, center=true);
            translate([length, 0, 0]) cylinder(h=_topDepth, d=topWidth, center=true);
        }
        translate([0, 0,  wall/2]) cutout();
        translate([0, 0, -wall/2]) rotate([180,0,0]) cutout();
    }

    // upper bearing
    translate([length, 0, 0]) cylinder(h=topBearingDepth, d=topBearingDiameter, center=true, $fn=32);

    // lower bearing
    cylinder(h=baseBearingDepth, d=baseBearingDiameter, center=true, $fn=32);

    module cutout() hull() {
        cutDiameterBase = baseWidth-2*wall;
        cutDiameterTop = topWidth-2*wall;
        _depth = max(_topDepth, _baseDepth);
        translate([baseBearingDiameter/2+wall+cutDiameterBase/2, 0, 0]) cylinder(h=_depth, d=cutDiameterBase, center=false);
        translate([length-topBearingDiameter/2-wall-cutDiameterTop/2, 0, 0]) cylinder(h=_depth, d=topWidth-2*wall, center=false);
    }
}
