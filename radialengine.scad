use <engine.piston.scad>
use <engine.rod.scad>
use <engine.valve.scad>
use <radialengine.geometry.scad>
use <cambarrel.scad>

$fn=32;

ventilRollenRadius=2;
ventilRollenLaenge=3;
Zylinder = 7;
NockenZahl = floor(Zylinder/2);
ventilHub=4;
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
KurbelWinkel = $t * 360 * 2;
nockenWinkel = -KurbelWinkel/2/NockenZahl;
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

color(.8*[1,1,1]) rotate([0,0,nockenWinkel+90]) {
    translate([0,0,-Bohrung/4]) camBarrel(camCount=NockenZahl,
        innerRadius = 64.5,
        outerRadius = 66,
        camHeight = ventilHub,
        thickness = 3.11,
        div = 2,
        camsInside=true,
        ahead=true
    );
    translate([0,0,Bohrung/4]) camBarrel(camCount=NockenZahl,
        innerRadius = 64.5,
        outerRadius = 66,
        camHeight = ventilHub,
        thickness = 3.11,
        div = 2,
        camsInside=true,
        ahead=false
    );
}

ArbeitsWinkel = [ for (i = [0 : 1 : Zylinder-1])
    let(even=i%2==0)
    let(w=(360 + KurbelWinkel - i*360/Zylinder + (even ? 360 : 0)))
    w%(2*360)
];

VentilHuebe = [ for (i = [0 : 1 : Zylinder-1])
    let(w=ArbeitsWinkel[i])
    let(intake=(w<180))
    let(exhaust=(w>((360+180))))
    [intake?(.5-.5*cos(2*w)):0,exhaust?(.5-.5*cos(2*w)):0]];

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
        rotate([-90,0,BahnWinkel[i]]) {
            arbeitsTakt = (ArbeitsWinkel[i]>360) && (ArbeitsWinkel[i]<360+180);
            color(arbeitsTakt ? [.5,1,.5] : [.75,.75,.75])
                Kolben();
        }

// zylinder
for (i = [0 : 1 : Zylinder-1]) {
    translate(KurbelZentrum+(PleuelLaenge0-KurbelLaenge-KolbenUnterLaenge)*BahnVektoren[i]) rotate([-90,0,BahnWinkel[i]]) {
        color(.3*[1,1,1]) difference() {
            cylinder(d=Bohrung+2*ZylinderWand, h=KolbenUnterLaenge+KolbenLaenge+Hub+RestRaumLaenge+4*ZylinderWand);
            translate([0,0,-.001]) cylinder(d=Bohrung+.001, h=KolbenUnterLaenge+KolbenLaenge+Hub+RestRaumLaenge);
            translate([-Bohrung/2-2*ZylinderWand,-Bohrung/2-2*ZylinderWand,-.001]) cube([Bohrung+4*ZylinderWand, Bohrung/2+2*ZylinderWand, 3*Hub]);
            Ventil(sign=1, cut=true, enlarge=1.01);
            Ventil(sign=-1, cut=true, enlarge=1.01);
        }
        color([.6,.8,1]) Ventil(sign=1, cut=false, hubRel=VentilHuebe[i][0]);
        color([1,.8,.6]) Ventil(sign=-1, cut=false, hubRel=VentilHuebe[i][1]);
    }
}
module Ventil(sign, cut, enlarge=1, hubRel=0) {
    translate([0,-sign*Bohrung/4,-.01+KolbenUnterLaenge+KolbenLaenge+Hub+RestRaumLaenge-hubRel*ventilHub]) {
        valve(discDiameter=enlarge*Bohrung/2.2, shaftDiameter=Bohrung/2/4, length=15, discThickness=.8, channelCut=cut);
        translate([0,0,15]) rotate([90,0,0]) cylinder(r=ventilRollenRadius, h=ventilRollenLaenge, center=true);
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
