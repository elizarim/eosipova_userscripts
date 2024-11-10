import Foundation

struct Points {
    var first: Point?
    var second: Point?
}

extension Points {
    static func + (a: Points, b: Point) -> Points {
        Points(first: a.first.map { $0 + b }, second: a.second.map { $0 + b })
    }
}
