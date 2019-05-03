

camBarrel_example($fn=360);

module camBarrel_example() {
    thickness = 5;
    camCount = 4;
    innerRadius = 17;
    outerRadius = 20;
    camHeight = 1;
    div = 3;
    camInside = true;
    translate([0,0,-3*thickness/2]) camBarrel( camCount=camCount, innerRadius = innerRadius, outerRadius = outerRadius, camHeight = camHeight, thickness = thickness, div = div, camsInside=true, ahead=false);
    translate([0,0,-1*thickness/2]) camBarrel( camCount=camCount, innerRadius = innerRadius, outerRadius = outerRadius, camHeight = camHeight, thickness = thickness, div = div, camsInside=true, ahead=true);
    translate([0,0, 1*thickness/2]) camBarrel( camCount=camCount, innerRadius = innerRadius, outerRadius = outerRadius, camHeight = camHeight, thickness = thickness, div = div, camsInside=false, ahead=false);
    translate([0,0, 3*thickness/2]) camBarrel( camCount=camCount, innerRadius = innerRadius, outerRadius = outerRadius, camHeight = camHeight, thickness = thickness, div = div, camsInside=false, ahead=true);
}

function camBarrel_relativeCamStroke(angle, camCount, div = 2, ahead) =
    let (virtualAngle = (((angle * camCount)+(ahead?90:0))%360))
    div == 0 ? (
        virtualAngle < 90 ?
            1 :
        // else
            0) :
    div == 2 ? (
        virtualAngle < 90 ?
            0.5 - 0.5*cos(4*virtualAngle) :
        // else
            0) :
    div == 3 ? (
        virtualAngle < 90/3*1 ?
            0.5 - 0.5*cos(6*virtualAngle) :
        virtualAngle < 90/3*2 ?
            1 :
        virtualAngle < 90/3*3 ?
            0.5 + 0.5*cos(6*virtualAngle) :
        // else
            0) :
    div == 4 ? (
        virtualAngle < 90/4*1 ?
            0.5 - 0.5*cos(8*virtualAngle) :
        virtualAngle < 90/4*3 ?
            1 :
        virtualAngle < 90/4*4 ?
            0.5 - 0.5*cos(8*virtualAngle) :
        // else
            0) :
    // else
        0.5;

module camBarrel(camCount, innerRadius, outerRadius, camHeight, div = 2, camsInside=false, ahead) {

    angles=[0 : 1 : 360];

    function camRadius(angle) =
        let (camBaseRadius = camsInside ? innerRadius : outerRadius)
        let (camHeight = camsInside ? -camHeight : camHeight)
        camBaseRadius + camHeight * camBarrel_relativeCamStroke(angle, camCount, div, ahead);

    xy = [ for (angle = angles)
        [camRadius(angle)*cos(angle), camRadius(angle)*sin(angle)]
    ];

    if (!camsInside)
        difference() {
            linear_extrude(height=thickness, center=true) polygon(xy);
            cylinder(h=thickness+.0123, center=true, r=innerRadius);
        }
    if (camsInside)
        difference() {
            cylinder(h=thickness, center=true, r=outerRadius);
            linear_extrude(height=thickness+.0123, center=true) polygon(xy);
        }
}

