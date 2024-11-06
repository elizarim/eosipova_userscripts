struct RelativeCoordinate {
    var location: Point
    var viewportOrigin: Point

    func offsetViewport(by offset: Point) -> Self {
        .init(location: location - offset, viewportOrigin: viewportOrigin + offset)
    }
}
