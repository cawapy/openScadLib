
camBarrel(
    camCount=3,
    innerRadius = 17,
    outerRadius = 20,
    camHeight = 2,
    thickness = 5,
    div = 2,
    camsInside=true
);

module camBarrel(camCount, innerRadius, outerRadius, camHeight, div = 2, camsInside=false, ahead) {

    angles=[0 : 1 : 360];
    camBaseRadius = camsInside ? innerRadius : outerRadius;
    camHeight = camsInside ? -camHeight : camHeight;

    function camRadius(angle) =
        let (virtualAngle = (((angle * camCount)+(ahead?90:0))%360))
        let (halfHeight = camHeight/2)
        let (centerRadius = camBaseRadius + halfHeight)
        let (topRadius = camBaseRadius + camHeight)

        div == 2 ? (
            virtualAngle < 90 ?
                centerRadius - halfHeight*cos(4*virtualAngle) :
            // else
                camBaseRadius) : 
        div == 3 ? (
            virtualAngle < 90/3*1 ?
                centerRadius - halfHeight*cos(6*virtualAngle) :
            virtualAngle < 90/3*2 ?
                topRadius : 
            virtualAngle < 90/3*3 ?
                centerRadius + halfHeight*cos(6*virtualAngle) :
            // else
                camBaseRadius) : 
        div == 4 ? (
            virtualAngle < 90/4*1 ?
                centerRadius - halfHeight*cos(8*virtualAngle) :
            virtualAngle < 90/4*3 ?
                topRadius : 
            virtualAngle < 90/4*4 ?
                centerRadius - halfHeight*cos(8*virtualAngle) :
            // else
                camBaseRadius) : 
        // else
            centerRadius;

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

