import SwiftUI

struct Shadow {
    static let subtle = (color: Color.black.opacity(0.08), radius: CGFloat(4), y: CGFloat(1))
    static let medium = (color: Color.black.opacity(0.15), radius: CGFloat(8), y: CGFloat(2))
    static let prominent = (color: Color.black.opacity(0.25), radius: CGFloat(16), y: CGFloat(4))
    static let accentGlow = (color: Color.black.opacity(0.3), radius: CGFloat(8), y: CGFloat(2))
}
