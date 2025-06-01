import SwiftUI
import Theme

struct AllFilterBadgeView: View {
    var isActive: Bool = false
    var onToggle: ((Bool) -> Void)? = nil

    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        if onToggle != nil, isActive {
            Color.purple // Using purple for "All" to differentiate it
        } else {
            Color.purple.opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
    }
    
    private var textColor: Color {
        if isActive {
            AppColors.onSurface(for: .dark)
        } else {
            colorScheme == .dark ? Color.purple : Color.purple
        }
    }

    var body: some View {
        Text("All")
            .font(.caption)
            .fontWeight(.medium)
            .padding(8)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? Color.purple : Color.clear, lineWidth: 1)
            )
            .onTapGesture {
                if let onToggle {
                    onToggle(!isActive)
                }
            }
            .fixedSize()
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Light Mode")
        AllFilterBadgeView { _ in }
            .preferredColorScheme(.light)
        
        Text("Dark Mode")
        AllFilterBadgeView { _ in }
            .preferredColorScheme(.dark)
        
        Text("Active State Examples")
        VStack(spacing: 10) {
            HStack {
                AllFilterBadgeView(isActive: true) { _ in }
                AllFilterBadgeView(isActive: false) { _ in }
            }
            .preferredColorScheme(.light)
            
            HStack {
                AllFilterBadgeView(isActive: true) { _ in }
                AllFilterBadgeView(isActive: false) { _ in }
            }
            .preferredColorScheme(.dark)
        }
    }
    .padding()
}
