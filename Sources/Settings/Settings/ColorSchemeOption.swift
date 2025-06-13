import Foundation

enum ColorSchemeOption: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: "sun.max.circle"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }
}
