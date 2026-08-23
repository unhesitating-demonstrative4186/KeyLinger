import SwiftUI

enum AccentTheme: String, CaseIterable, Identifiable, Sendable {
    case system
    case mint
    case blue
    case indigo
    case purple

    var id: String { rawValue }

    var localizationKey: String {
        "theme." + rawValue
    }

    var tintColor: Color? {
        switch self {
        case .system:
            return nil
        case .mint:
            return .mint
        case .blue:
            return .blue
        case .indigo:
            return .indigo
        case .purple:
            return .purple
        }
    }
}
