//  Created by Muhammed Mahmood on 19/04/2025.

import SwiftUI

public enum AppColors {
    public enum Light {
        public static let primary = Color(hex: "2C3E50") // Dark blue
        public static let accent = Color(hex: "1ABC9C") // Teal
        public static let background = Color(hex: "F5F5F5") // Light gray
        public static let cardBackground = Color.white
        public static let textPrimary = Color.black
        public static let textSecondary = Color(hex: "555555") // Gray
    }

    public enum Dark {
        public static let primary = Color(hex: "ECF0F1") // Light blue
        public static let accent = Color(hex: "2ECC71") // Brighter green
        public static let background = Color(hex: "1A1A1A") // Dark gray
        public static let cardBackground = Color(hex: "2A2A2A") // Dark card background
        public static let textPrimary = Color.white
        public static let textSecondary = Color(hex: "BBBBBB") // Light gray
    }

    public static func primary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Dark.primary : Light.primary
    }

    public static func accent(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Dark.accent : Light.accent
    }

    public static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Dark.background : Light.background
    }

    public static func cardBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Dark.cardBackground : Light.cardBackground
    }

    public static func textPrimary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Dark.textPrimary : Light.textPrimary
    }

    public static func textSecondary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Dark.textSecondary : Light.textSecondary
    }

    // Application status colors (more visible in dark mode)
    public enum Status {
        public static let applied = Color.blue
        public static let interview = Color.orange
        public static let offer = Color.green
        public static let declined = Color.red
        public static let archived = Color.gray
    }
}

public enum AppTypography {
    public static let title = Font.system(.title2, design: .default).weight(.semibold)
    public static let body = Font.system(.body, design: .default)
    public static let caption = Font.system(.caption, design: .default).weight(.light)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
