
// Calculate angle between horizontal line (y=c) and BA
//  A, B : 2d coordinates [x, y] of BA start and end
// Result: angle (degrees)
function angle(A, B) =
    let(BA = B - A)
    let(alpha = asin(BA.y / norm(BA)))
    BA.x >= 0 ? alpha : 180 - alpha;


// Calculate intersection points of two circles.
// Parameters:
//  A, B                 : 2d centers [x, y] of circles
//  a, b                 : radiuses r of circles
// Result: one of...
//  []                   : no specific intersections
//  [[x, y]]             : 2d coordinates of single intersection Q (circles touch each other)
//  [[x1, y1], [x2, y2]] : 2d coordinates of two intersections Q1, Q2
function CircleIntersections(A, a, B, b) =
    let(AB = B - A)
    let(c = norm(AB))
    c == 0 ?
        [] :
        let(aa = a*a)
        let(x = (aa + c*c - b*b) / (2*c))
        let(yy = aa - x*x)
        yy < 0 ? [] :
            let(ex = AB/c)
            let(Q1 = A + x*ex)
            yy == 0 ?
                [Q1] :
                let(y = sqrt(yy))
                let(ey = [-ex[1], ex[0]])
                [Q1 + y*ey, Q1 - y*ey];

// Calculate intersection points of circle and line
// Parameters:
//  A, P                 : 2d coordinates of circle center and point on line
//  r                    : radius of circle
//  u                    : vector along line
// Result: one of ...
//  []                   : no intersections
//  [[x, y]]             : 2d coordinates of single intersection Q (line is tangent of circle)
//  [[x1, y1], [x2, y2]] : 2d coordinates of two intersections Q1, Q2
function CircleLineIntersections(A, r, P, u) =
    let(a = -u.y)
    let(b = u.x)
    let(c = P.x*a + P.y*b)
    let(d = c - a*A.x - b*A.y)
    let(q = pow(a, 2) + pow(b, 2))
    let(p = pow(r, 2) * q)
    p < pow(d, 2) ?
        [] :
        let(m = sqrt(p - pow(d, 2)))
        m == 0 ?
            [A + [(a*d      )/q, (b*d      )/q]] :
            [A + [(a*d + b*m)/q, (b*d - a*m)/q],
             A + [(a*d - b*m)/q, (b*d + a*m)/q]];


