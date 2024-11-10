import AppKit

final class CirclePackingView: BaseView {
    var rootCircle: DiagramCircleNode? {
        get { contentView.rootCircle }
        set {
            contentView.rootCircle = newValue
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: NSSize {
        contentView.intrinsicContentSize
    }

    var contentBackgroundColor: NSColor? {
        get {
            contentView.backgroundColor
        }
        set {
            contentView.backgroundColor = newValue
            layer?.backgroundColor = newValue?.cgColor
        }
    }

    var marginSize: Distance {
        get { contentView.marginSize }
        set { contentView.marginSize = newValue }
    }

    var delegate: CirclePackingViewDelegate? {
        get { contentView.delegate }
        set { contentView.delegate = newValue }
    }

    var magnification: CGFloat {
        get { contentView.magnification }
        set { contentView.magnification = newValue }
    }

    private lazy var contentView: ContentView = {
        let view = ContentView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        return view
    }()

    private lazy var contentInteractionView: ContentInteractionView = {
        let view = ContentInteractionView(frame: frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentView = contentView
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        wantsLayer = true
        setupLayout()
    }

    func setNeedsRedrawContent() {
        contentView.setNeedsDisplay()
    }

    private func setupLayout() {
        addSubview(contentView)
        addSubview(contentInteractionView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentInteractionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentInteractionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentInteractionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentInteractionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
