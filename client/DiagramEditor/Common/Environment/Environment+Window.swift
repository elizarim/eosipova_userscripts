import SwiftUI

struct WindowBox {
    weak var value: NSWindow?
}

struct NSWindowEnvironmentKey: EnvironmentKey {
    typealias Value = WindowBox
    static var defaultValue = WindowBox(value: nil)
}

extension EnvironmentValues {
    var window: WindowBox {
        get { self[NSWindowEnvironmentKey.self] }
        set { self[NSWindowEnvironmentKey.self] = newValue }
    }
}
