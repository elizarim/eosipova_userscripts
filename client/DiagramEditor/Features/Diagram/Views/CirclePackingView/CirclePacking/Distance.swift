import Foundation

public typealias FloatType = Double
public typealias Distance = FloatType

extension FloatType: Measurable {
    public var size: FloatType { self }
}

extension FloatType {
    static let epsilon = FloatType(Float.ulpOfOne)
}
