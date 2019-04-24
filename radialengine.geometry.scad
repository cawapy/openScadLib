
use <intersections.scad>

function calculateRadialEngineGeometry(count, center, stroke, crankShaftAngle, mainRodLength, subRodLength) =
    let (cylinderAxisAngles = [ for (i = [0 : count-1]) i * 360 / count ])
    let (cylinderAxisVectors = [ for (i = cylinderAxisAngles) rotVec([0, 1], i) ])
    let (crankPinPosition = center + rotVec([0, stroke / 2], crankShaftAngle))
    let (mainRodEnd = CircleLineIntersections(crankPinPosition, mainRodLength, center, cylinderAxisVectors[0])[0])
    let (mainRodAngle = angle(crankPinPosition, mainRodEnd))
    let (subRodOffset = mainRodLength - subRodLength)
    let (rodStarts = [ for (i = [0 : count - 1])
        i == 0 ?
        crankPinPosition :
        (crankPinPosition + rotVec([0, subRodOffset], cylinderAxisAngles[i] - 90 + mainRodAngle)) ])
    let (rodEnds = [ for (i = [0 : count - 1])
        i == 0 ?
        mainRodEnd :
        CircleLineIntersections(rodStarts[i], subRodLength, center, cylinderAxisVectors[i])[0]])
    let (rodAngles = [ for (i = [0 : count - 1]) angle(rodStarts[i], rodEnds[i]) ])
    [ [ "radialEngineGeometry", "v0.1" ], ["metaData", ["cylinders", count]], [
        for (i = [0 : count - 1]) [
            ["index", i],
            ["axis", [ [ "angle", cylinderAxisAngles[i]], ["vector", cylinderAxisVectors[i] ]]],
            ["rod", [ "start", rodStarts[i]], ["end", rodEnds[i]], ["angle", rodAngles[i]] ]
        ]
        ]
    ];

function getAxisAngles(geometry) = isGeometry(geometry) ? [ for (k = geometry[2]) k[1][1][0][1] ] : undef;
function getAxisVectors(geometry) = isGeometry(geometry) ? [ for (k = geometry[2]) k[1][1][1][1] ] : undef;
function getRodStarts(geometry) = isGeometry(geometry) ? [ for (k = geometry[2]) k[2][1][1] ] : undef;
function getRodEnds(geometry) = isGeometry(geometry) ?  [ for (k = geometry[2]) k[2][2][1] ] : undef;
function getRodAngles(geometry) = isGeometry(geometry) ?  [ for (k = geometry[2]) k[2][3][1] ] : undef;

function isGeometry(geometry) = geometry[0][0] == "radialEngineGeometry";

function rotVec(P, alpha) =
    P * [ [cos(alpha), sin(alpha)], [-sin(alpha), cos(alpha)] ];

