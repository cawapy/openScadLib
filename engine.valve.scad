
module valve(discDiameter, shaftDiameter, length, discThickness, diameterCutRel=.975, channelCut=false) {

    if (channelCut) {
        cylinder(h=length, d=discDiameter-2*discThickness);
        cone(d=discDiameter, h=discDiameter/2);
    }
    else {
        cylinder(h=length, d=shaftDiameter);
        disc();
    }

    module disc() {
        radius = discDiameter/2;
        torusBigRadius = radius/2 + shaftDiameter/4;
        torusSmallRadius = radius/2 - shaftDiameter/4;
        difference() {
            intersection() {
                cone(d=discDiameter, h=discDiameter/2);
                cylinder(h=discThickness+torusSmallRadius, d=discDiameter*diameterCutRel);
            }
            translate([0,0,discThickness+torusSmallRadius])
                torus(bigR = torusBigRadius, smallR=torusSmallRadius);
            translate([0,0,discThickness]) difference() {
                cylinder(h=discThickness+torusSmallRadius, d=discDiameter);
                cylinder(h=discThickness+torusSmallRadius, r=torusBigRadius);
            }
        }
    }
    module torus(bigR, smallR)
        rotate_extrude() translate([bigR, 0, 0]) circle(r = smallR);
    module cone(h, d)
        cylinder(d1=d, d2=0, h=h);
}
