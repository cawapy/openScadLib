
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
    [ [ "radialEngineGeometry", "v0.1" ], ["metaData"], [
        for (i = [0 : count - 1]) [
            ["index", i],
            ["axis", [ [ "angle", cylinderAxisAngles[i]], ["vector", cylinderAxisVectors[i] ]]],
            ["rod", [ "start", rodStarts[i]], ["end", rodEnds[i]] ]
        ]
        ]
    ];

function rotVec(P, alpha) =
    P * [ [cos(alpha), sin(alpha)], [-sin(alpha), cos(alpha)] ];

