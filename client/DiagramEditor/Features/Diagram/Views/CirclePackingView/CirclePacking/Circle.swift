import Foundation

public typealias CircleRadius = Distance

public protocol Circle {
    var radius: CircleRadius { get set }
    var center: Point { get set }
}

extension Circle {
    /// Returns true when the point lies inside the circle.
    public func contains(_ point: Point) -> Bool {
        center.distance(to: point) < radius
    }
}

// MARK: - Internal

// MARK: - Movement -

extension Circle {
    /// Places that circle to the right of the source circle.
    mutating func put(nextTo peer: some Circle, padding: Distance = .zero) {
        center = Point(x: peer.center.x + peer.radius + padding + radius, y: peer.center.y)
    }

    /// Makes that circle tangent to source circles.
    mutating func put(between a: some Circle, _ b: some Circle, padding: Distance = .zero) {
        let c1 = FlatCircle(radius: a.radius + padding + radius, center: a.center)
        let c2 = FlatCircle(radius: b.radius + padding + radius, center: b.center)
        guard let collisionPoint = c2.collide(with: c1).first else {
            assertionFailure("Source circles are too far from each other.")
            return
        }
        center = collisionPoint
    }
}

// MARK: - Location -

extension Circle {
    /// Finds the circle whose far side is the most distant.
    func findMostDistantCircle<C: Circle>(in circles: [C]) -> (C, Distance) {
        precondition(!circles.isEmpty)
        var distantCircle: C!
        var maxDistance = -Distance.infinity
        for circle in circles {
            let distance = distanceToFarSide(of: circle)
            if distance > maxDistance {
                distantCircle = circle
                maxDistance = distance
            }
        }
        return (distantCircle, maxDistance)
    }

    /// Returns the minimal distance to the far side of the source circle.
    func distanceToFarSide(of circle: some Circle) -> Distance {
        center.distance(to: circle.center) + circle.radius - radius
    }

    /// Returns the distance between far sides of both that and source circles.
    func maxDistance(to circle: some Circle) -> Distance {
        center.distance(to: circle.center) + circle.radius + radius
    }
}

// MARK: - Collision -

extension Circle {
    /// Returns the minimal index of the circle in the source range who collides with that circle.
    func firstCollisionIndex<C: Circle>(
        in circles: [C],
        between lower: Int, _ upper: Int,
        padding: Distance = .zero
    ) -> Int? {
        guard lower < circles.count else {
            return nil
        }
        var current = lower
        while current <= upper {
            if collides(with: circles[current], padding: padding) {
                return current
            } else {
                current += 1
            }
        }
        return nil
    }

    /// Determines whether or not source circle has collision points with that circle.
    func collides(with circle: some Circle, padding: Distance = .zero) -> Bool {
        center.distance(to: circle.center) - radius - circle.radius < padding - .epsilon
    }

    /// Determines shared points for both that and source circles.
    func collide(with circle: some Circle) -> Points {
        let r1 = radius
        let r2 = circle.radius
        let c = circle.center - center // Shift origin of coordinates to the center of that circle
        let line = Line(
            a: -2*c.x,
            b: -2*c.y,
            c: c.x*c.x + c.y*c.y + r1*r1 - r2*r2
        )
        return line.collideCircle(with: radius) + center // Shift back origin of coordinates
    }

    /// Returns the points where the line constructed using both that and source circles's centers collides with them.
    func sharedDiameterCollisionPoints(_ other: some Circle) -> [Point] {
        let bPoints = other.diameterCollisionPoints(passing: center)
        let aPoints = diameterCollisionPoints(passing: other.center)
        return [bPoints.first!, bPoints.second!, aPoints.first!, aPoints.second!]
    }

    /// Returns the points where the line constructed using both circle's center and external point collides with that circle.
    func diameterCollisionPoints(passing externalPoint: Point) -> Points {
        let p = externalPoint - center
        return Line(a: p.y, b: -p.x, c: 0).collideCircle(with: radius) + center
    }
}
