import Foundation

/// Represents line in general form A\*x + B\*y + C = 0.
struct Line {
    let a: FloatType
    let b: FloatType
    let c: FloatType

    init(a: FloatType, b: FloatType, c: FloatType) {
        precondition(abs(a) > 0 || abs(b) > 0)
        self.a = a
        self.b = b
        self.c = c
    }

    /// Locates collision points with circle which center is located at the origin of coordinates.
    func collideCircle(with radius: CircleRadius) -> Points {
        let aabb = a*a + b*b
        let cc = c*c
        let rr = radius*radius
        let x0 = -a*c/aabb
        let y0 = -b*c/aabb
        if cc - rr*aabb > .epsilon {
            return Points(first: nil, second: nil)
        } else if abs(cc - rr*aabb) < .epsilon {
            return Points(first: Point(x: x0, y: y0), second: nil)
        }
        let d = rr - cc/aabb
        let k = sqrt(d/aabb)
        let ax = x0 + b*k;
        let bx = x0 - b*k;
        let ay = y0 - a*k;
        let by = y0 + a*k;
        return Points(first: Point(x: ax, y: ay), second: Point(x: bx, y: by))
    }
}
