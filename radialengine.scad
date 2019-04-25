use <engine.piston.scad>
use <engine.rod.scad>
use <radialengine.geometry.scad>

$fn=32;

Zylinder = 7;
Hub=15;
Bohrung=15;
PleuelLaenge0=31;
PleuelVerkuerzung=5;
MutterPleuelScheibenDicke=1;
KolbenLaenge=7;
KolbenUnterLaenge=4;
KolbenWand=1;
KolbenBoden=3;
KolbenRingHoehe=.5;
KolbenRingTiefe=.5;
KolbenRingRelPos=[.75, .5, -.45];
RestRaumLaenge=2;
HubzapfenDurchmesser=5;
PleuelAuge=4;
ZylinderWand=2;
KurbelLaenge = Hub/2;
KurbelZentrum = [0,0];
KurbelWinkel = $t * 360;
HauptPleuelScheibenRadius=PleuelVerkuerzung+2;
PleuelLaenge=PleuelLaenge0-PleuelVerkuerzung;

geometry = calculateRadialEngineGeometry(
    count=Zylinder,
    center=KurbelZentrum,
    stroke=Hub,
    crankShaftAngle=KurbelWinkel,
    mainRodLength=PleuelLaenge0,
    subRodLength=PleuelLaenge);

BahnWinkel = getAxisAngles(geometry);
BahnVektoren = getAxisVectors(geometry);
PleuelStarts = getRodStarts(geometry);
PleuelEnden = getRodEnds(geometry);
PleuelWinkel = getRodAngles(geometry);

pleuelDicke=3;
pleuelBreiteBasis=3.5;
pleuelBreiteSpitze=3;
pleuelBasisDicke=3.5;
pleuelBasisDurchmesser=4;
pleuelBasisBohrung=pleuelBasisDurchmesser-1.5;
pleuelBasisGesamtDicke=pleuelBasisDicke+2*MutterPleuelScheibenDicke;
pleuelSpitzeDicke=3.5;
pleuelSpitzeDurchmesser=PleuelAuge+2;
kurbelDicke=5;
kurbelRadius=Hub/2;


for (i = [0 : 1 : Zylinder-1])
    translate(PleuelStarts[i])
        rotate(PleuelWinkel[i])
            if (i==0)
                HauptPleuel(mainColor=.6*[1,1,1], pinColor=.4*[1,1,1]);
            else
                color(.5*[1,1,1])
                    Pleuel();

for (i = [0 : 1 : Zylinder-1])
    translate(PleuelEnden[i])
        rotate([-90,0,BahnWinkel[i]])
            color(.75*[1,1,1])
                Kolben();

// zylinder
color(.3*[1,1,1]) for (i = [0 : 1 : Zylinder-1]) {
    translate(KurbelZentrum+(PleuelLaenge0-KurbelLaenge-KolbenUnterLaenge)*BahnVektoren[i]) rotate([-90,0,BahnWinkel[i]])
        difference() {
            cylinder(d=Bohrung+2*ZylinderWand, h=KolbenUnterLaenge+KolbenLaenge+Hub+RestRaumLaenge+ZylinderWand);
            translate([0,0,-.001]) cylinder(d=Bohrung+.001, h=KolbenUnterLaenge+KolbenLaenge+Hub+RestRaumLaenge);
            translate([-Bohrung/2-2*ZylinderWand,-Bohrung/2-2*ZylinderWand,-.001]) cube([Bohrung+4*ZylinderWand, Bohrung/2+2*ZylinderWand, 3*Hub]);
        }
}

// kurbel
color(.8*[1,1,1]) {
    rotate(90+KurbelWinkel) Kurbel(true);
    //rotate(90+KurbelWinkel) Kurbel(false);
}

module Kurbel(isLeft) {
    len=7;
    shift=9;
    translate([kurbelRadius,0,0])
        rotate([180,0,0]) cylinder(h=10, d=HubzapfenDurchmesser, center=false);
    if (!isLeft) {
        translate([0,0,shift]) cylinder(d=7, h=len, center=true);
        translate([0,0,5.5]) HalbKurbel();
    }
    if (isLeft) {
        translate([0,0,-shift]) cylinder(d=7, h=len, center=true);
        translate([0,0,-5.5]) rotate([180,0,0]) HalbKurbel();
    }
}

module HalbKurbel() {
    difference() {
        hull() {
            translate([0,0,2]) cylinder(d=7, h=kurbelDicke, center=true);
            translate([kurbelRadius,0,0]) cylinder(d=4, h=kurbelDicke, center=true);
            translate([0,0,1]) cylinder(r=kurbelRadius+4, h=kurbelDicke, center=true);
        }
        translate([kurbelRadius+4,kurbelRadius+4+3,1.01]) cylinder(r=kurbelRadius+4, h=2*kurbelDicke, center=true);
        translate([kurbelRadius+4,-(kurbelRadius+4+3),1.01]) cylinder(r=kurbelRadius+4, h=2*kurbelDicke, center=true);
    }
}


module Kolben()
    piston(diameter=Bohrung, height=KolbenLaenge, depth=KolbenUnterLaenge,
        wall=KolbenWand, ground=KolbenBoden,
        ringRelPos=KolbenRingRelPos, ringHeight=KolbenRingHoehe, ringDepth=KolbenRingTiefe,
        pinDiameter=PleuelAuge);

module Pleuel()
    rod(length=PleuelLaenge, baseWidth=pleuelBreiteBasis, topWidth=pleuelBreiteSpitze,
        depth=pleuelDicke, wall=.5,
        baseBearingDiameter=pleuelBasisDurchmesser, topBearingDiameter=pleuelSpitzeDurchmesser,
        baseBearingDepth=pleuelBasisDicke, topBearingDepth=pleuelSpitzeDicke);

module HauptPleuel(mainColor, pinColor) {
    color(mainColor)
        difference() {
            rod(length=PleuelLaenge0, baseWidth=pleuelBreiteBasis, topWidth=pleuelBreiteSpitze,
                baseDepth=pleuelBasisDicke+2*MutterPleuelScheibenDicke,
                topDepth=pleuelDicke,
                wall=.5,
                baseBearingDiameter=2*HauptPleuelScheibenRadius, topBearingDiameter=pleuelSpitzeDurchmesser,
                baseBearingDepth=pleuelBasisGesamtDicke, topBearingDepth=pleuelSpitzeDicke);

            // cut holes for child rods
            for (i = [1 : 1 : Zylinder-1])
                rotate([0,0,-PleuelWinkel[0]])
                    translate(PleuelStarts[i]-PleuelStarts[0])
                        cylinder(h=2*pleuelBasisGesamtDicke, d=pleuelBasisBohrung, center=true);

            // cut spacing for child rods
            difference() {
                cylinder(h=pleuelBasisDicke,d=2*HauptPleuelScheibenRadius+.5, center=true);
                hull() {
                    translate([HauptPleuelScheibenRadius,0,0]) cylinder(h=2*pleuelBasisDicke, d=pleuelBasisDurchmesser, center=true);
                    translate([PleuelVerkuerzung,0,0]) cylinder(h=2*pleuelBasisDicke, d=pleuelBasisDurchmesser, center=true);
                }
            }

            // cut hole for crank shaft
            cylinder(h=2*pleuelBasisGesamtDicke, d=5.5, center=true);
        }
    color(pinColor)
        for (i = [1 : 1 : Zylinder-1])
            rotate([0,0,-PleuelWinkel[0]])
                translate(PleuelStarts[i]-PleuelStarts[0])
                    cylinder(h=pleuelBasisGesamtDicke-1, d=pleuelBasisBohrung, center=true);
}
