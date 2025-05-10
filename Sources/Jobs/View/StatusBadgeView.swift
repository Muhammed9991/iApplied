//  Created by Muhammed Mahmood on 19/04/2025.

import Models
import SwiftUI
import Theme

struct StatusBadgeView: View {
    let status: ApplicationStatus
    var count: Int?
    var onToggle: ((Bool) -> Void)? = nil

    @State private var isActive: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    private var backgroundColor: Color {
        if onToggle != nil, isActive {
            status.color
        } else {
            status.color.opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
    }

    private var textColor: Color {
        if isActive {
            AppColors.onSurface(for: .dark)
        } else {
            colorScheme == .dark ? status.color : status.color
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            if let count {
                Text("\(count)")
            }
            Text(status.rawValue)
        }
        .font(.caption)
        .fontWeight(.medium)
        .padding(8)
        .background(backgroundColor)
        .foregroundColor(textColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? status.color : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            if let onToggle {
                isActive.toggle()
                onToggle(isActive)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Light Mode")
        HStack(spacing: 10) {
            StatusBadgeView(status: .applied, count: 3) { _ in }
            StatusBadgeView(status: .interview, count: 2) { _ in }
            StatusBadgeView(status: .offer, count: 1) { _ in }
            StatusBadgeView(status: .declined)
        }
        .preferredColorScheme(.light)

        Text("Dark Mode")
        HStack(spacing: 10) {
            StatusBadgeView(status: .applied, count: 3) { _ in }
            StatusBadgeView(status: .interview, count: 2) { _ in }
            StatusBadgeView(status: .offer, count: 1) { _ in }
            StatusBadgeView(status: .declined)
        }
        .preferredColorScheme(.dark)

        Text("Active State Examples")
        VStack(spacing: 10) {
            let activeStatus = StatusBadgeView(status: .applied, count: 5) { _ in }
            let inactiveStatus = StatusBadgeView(status: .applied, count: 5) { _ in }

            HStack {
                activeStatus
                inactiveStatus
            }
            .preferredColorScheme(.light)

            HStack {
                activeStatus
                inactiveStatus
            }
            .preferredColorScheme(.dark)
        }
    }
    .padding()
}
