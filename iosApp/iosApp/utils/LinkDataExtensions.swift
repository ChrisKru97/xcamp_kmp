import shared

protocol LinkData {
    var icon: String { get }
    var title: String { get }
    var url: String { get }
}

extension InfoLink: LinkData {
    var icon: String {
        IconProvider.iconName(for: self)
    }
}

extension MediaLink: LinkData {
    var icon: String {
        IconProvider.iconName(for: self)
    }
}
