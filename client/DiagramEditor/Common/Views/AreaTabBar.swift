import SwiftUI

protocol AreaTab: View, Identifiable, Hashable {
    var title: String { get }
    var systemImage: String { get }
}

struct AreaTabBar<Tab: AreaTab>: View {
    @Binding var items: [Tab]
    @Binding var selection: Tab?

    @State private var tabLocations: [Tab: CGRect] = [:]
    @State private var tabWidth: [Tab: CGFloat] = [:]
    @State private var tabOffsets: [Tab: CGFloat] = [:]

    /// The tab currently being dragged.
    ///
    /// It will be `nil` when there is no tab dragged currently.
    @State private var draggingTab: Tab?

    /// The start location of dragging.
    ///
    /// When there is no tab being dragged, it will be `nil`.
    @State private var draggingStartLocation: CGFloat?

    /// The last location of dragging.
    ///
    /// This is used to determine the dragging direction.
    /// - TODO: Check if I can use `value.translation` instead.
    @State private var draggingLastLocation: CGFloat?

    var body: some View {
        topBody
    }

    var topBody: some View {
        GeometryReader { proxy in
            iconsView(size: proxy.size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.default, value: items)
        }
        .clipped()
        .frame(maxWidth: .infinity, idealHeight: 27)
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    func iconsView(size: CGSize) -> some View {
        AnyLayout(HStackLayout(spacing: 0)) {
            ForEach(items) { tab in
                makeIcon(tab: tab, size: size)
                    .offset(x: tabOffsets[tab] ?? 0, y: 0)
                    .background(makeTabItemGeometryReader(tab: tab))
                    .simultaneousGesture(makeAreaTabDragGesture(tab: tab))
            }
        }
    }

    private func makeIcon(
        tab: Tab,
        scale: Image.Scale = .medium,
        size: CGSize
    ) -> some View {
        Button {
            selection = tab
        } label: {
            Image(systemName: tab.systemImage)
                .font(.system(size: 12.5))
                .symbolVariant(tab == selection ? .fill : .none)
                .help(tab.title)
        }
        .buttonStyle(
            .icon(
                isActive: tab == selection,
                size: CGSize(width: 24, height: size.height)
            )
        )
        .focusable(false)
    }

    private func makeAreaTabDragGesture(tab: Tab) -> some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .global)
            .onChanged({ value in
                if draggingTab != tab {
                    initializeDragGesture(value: value, for: tab)
                }

                // Get the current cursor location
                let currentLocation = value.location.x
                guard let startLocation = draggingStartLocation,
                      let currentIndex = items.firstIndex(of: tab),
                      let currentTabWidth = tabWidth[tab],
                      let lastLocation = draggingLastLocation
                else { return }

                let dragDifference = currentLocation - lastLocation
                tabOffsets[tab] = currentLocation - startLocation

                // Check for swaps between adjacent tabs
                // Left tab
                swapTab(
                    tab: tab,
                    currentIndex: currentIndex,
                    currentLocation: currentLocation,
                    dragDifference: dragDifference,
                    currentTabWidth: currentTabWidth,
                    direction: .previous
                )
                // Right tab
                swapTab(
                    tab: tab,
                    currentIndex: currentIndex,
                    currentLocation: currentLocation,
                    dragDifference: dragDifference,
                    currentTabWidth: currentTabWidth,
                    direction: .next
                )

                // Update the last dragging location if there's enough offset
                let currentLocationOnAxis = value.location.x
                if draggingLastLocation == nil || abs(currentLocationOnAxis - draggingLastLocation!) >= 10 {
                    draggingLastLocation = value.location.x
                }
            })
            .onEnded({ _ in
                draggingStartLocation = nil
                draggingLastLocation = nil
                withAnimation(.easeInOut(duration: 0.25)) {
                    tabOffsets = [:]
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    draggingTab = nil
                }
            })
    }

    private func initializeDragGesture(value: DragGesture.Value, for tab: Tab) {
        draggingTab = tab
        let initialLocation = value.startLocation.x
        draggingStartLocation = initialLocation
        draggingLastLocation = initialLocation
    }

    enum SwapDirection {
        case previous
        case next
    }

    // swiftlint:disable:next function_parameter_count
    private func swapTab(
        tab: Tab,
        currentIndex: Int,
        currentLocation: CGFloat,
        dragDifference: CGFloat,
        currentTabWidth: CGFloat,
        direction: SwapDirection
    ) {
        // Determine the index to swap with based on direction
        var swapIndex: Int?
        if direction == .previous {
            if currentIndex > 0 {
                swapIndex = currentIndex - 1
            }
        } else {
            if currentIndex < items.count - 1 {
                swapIndex = currentIndex + 1
            }
        }

        // Validate the drag direction
        let isValidDragDir = (direction == .previous && dragDifference < 0) ||
                             (direction == .next && dragDifference > 0)
        guard let swapIndex = swapIndex, isValidDragDir else { return }

        // Get info about the tab to swap with
        let swapTab = items[swapIndex]
        guard let swapTabLocation = tabLocations[swapTab],
              let swapTabWidth = tabWidth[swapTab]
        else { return }

        let isWithinBounds: Bool = direction == .previous ?
            isWithinPrevTopBounds(currentLocation, swapTabLocation, swapTabWidth) :
            isWithinNextTopBounds(currentLocation, swapTabLocation, swapTabWidth, currentTabWidth)

        // Swap tab positions
        if isWithinBounds {
            let changing = swapTabWidth - 1
            draggingStartLocation! += direction == .previous ? -changing : changing
            tabOffsets[tab]! += direction == .previous ? changing : -changing
            items.swapAt(currentIndex, swapIndex)
        }
    }

    private func isWithinPrevTopBounds(
        _ curLocation: CGFloat, _ swapLocation: CGRect, _ swapWidth: CGFloat
    ) -> Bool {
        return curLocation < max(
            swapLocation.maxX - swapWidth * 0.1,
            swapLocation.minX + swapWidth * 0.9
        )
    }

    private func isWithinNextTopBounds(
        _ curLocation: CGFloat, _ swapLocation: CGRect, _ swapWidth: CGFloat, _ curWidth: CGFloat
    ) -> Bool {
        return curLocation > min(
            swapLocation.minX + swapWidth * 0.1,
            swapLocation.maxX - curWidth * 0.9
        )
    }

    private func isWithinPrevBottomBounds(
        _ curLocation: CGFloat, _ swapLocation: CGRect, _ swapWidth: CGFloat
    ) -> Bool {
        return curLocation < max(
            swapLocation.maxY - swapWidth * 0.1,
            swapLocation.minY + swapWidth * 0.9
        )
    }

    private func isWithinNextBottomBounds(
        _ curLocation: CGFloat, _ swapLocation: CGRect, _ swapWidth: CGFloat, _ curWidth: CGFloat
    ) -> Bool {
        return curLocation > min(
            swapLocation.minY + swapWidth * 0.1,
            swapLocation.maxY - curWidth * 0.9
        )
    }

    private func makeTabItemGeometryReader(tab: Tab) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .foregroundColor(.clear)
                .onAppear {
                    self.tabWidth[tab] = geometry.size.width
                    self.tabLocations[tab] = geometry.frame(in: .global)
                }
                .onChange(of: geometry.frame(in: .global)) { newFrame in
                    self.tabLocations[tab] = newFrame
                }
                .onChange(of: geometry.size.width) { newWidth in
                    self.tabWidth[tab] = newWidth
                }
        }
    }
}
