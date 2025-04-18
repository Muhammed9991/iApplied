//  Created by Muhammed Mahmood on 19/04/2025.

import SwiftUI

public enum AppColors {
    public static let primary = Color(hex: "2C3E50") // Midnight Blue
    public static let accent = Color(hex: "1ABC9C") // Aqua Green
    public static let background = Color(hex: "F5F5F5") // Soft Gray
    public static let cardBackground = Color.white

    // Application status colors
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
