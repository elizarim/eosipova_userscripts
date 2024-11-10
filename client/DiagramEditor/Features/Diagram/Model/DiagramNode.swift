import SwiftUI

class DiagramNode: ObservableObject, Codable, Hashable, Identifiable {
    let id: UUID
    @Published private(set) var name: String
    private(set) var fillColor: String?
    var isNameHidden: Bool

    var isBranch: Bool { self is BranchDiagramNode }

    var swiftFillColor: Color? {
        get { fillColor.map { Color(hex: $0) } }
        set { self.fillColor = newValue?.hexString }
    }

    var nsFillColor: NSColor? {
        fillColor.map { NSColor(hex: $0) }
    }

    var icon: Image {
        isBranch ? Image(systemName: "circle") : Image(systemName: "circle.fill")
    }

    var nsIcon: NSImage {
        isBranch
            ? NSImage(systemSymbolName: "circle", accessibilityDescription: nil)!
            : NSImage(systemSymbolName: "circle.fill", accessibilityDescription: nil)!
    }

    weak var parent: BranchDiagramNode?
    var isRoot: Bool { parent == nil }

    init(id: UUID = .init(), name: String, parent: BranchDiagramNode? = nil) {
        self.id = id
        self.name = name
        self.parent = parent
        self.isNameHidden = true
    }

    func findNode(by nodeID: ID) -> DiagramNode? {
        id == nodeID ? self : nil
    }

    func rename(newName: String) {
        name = newName
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isNameHidden
        case fillColor
        case cloudStatus
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        fillColor = try container.decode(String?.self, forKey: .fillColor)
        isNameHidden = try container.decode(Bool.self, forKey: .isNameHidden)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(fillColor, forKey: .fillColor)
        try container.encode(isNameHidden, forKey: .isNameHidden)
    }

    // MARK: Equatable

    static func == (lhs: DiagramNode, rhs: DiagramNode) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
