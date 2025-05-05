import SnapshotTesting
import SwiftUI
import Theme

struct DeviceBottomSheetPreview<SnapshotContent, Description>: View where Description: View, SnapshotContent: View {
    let backgroundColor: Color
    let description: () -> Description
    @Environment(\.colorScheme) var colorScheme
    let snapshotContent: () -> SnapshotContent
    let snapshotting: Snapshotting<AnyView, UIImage>
    
    // Control the height of the bottom sheet
    @State private var bottomSheetHeight: CGFloat = UIScreen.main.bounds.height * 0.9
    
    // Control the vertical position of the bottom sheet and background element
    private let sheetYOffset: CGFloat = 35
    private let backgroundYAdjustment: CGFloat = -10 // How much higher the background should be
    
    init(
        _ snapshotting: Snapshotting<AnyView, UIImage>,
        description: @escaping () -> Description,
        backgroundColor: Color,
        @ViewBuilder _ snapshotContent: @escaping () -> SnapshotContent
    ) {
        self.backgroundColor = backgroundColor
        self.description = description
        self.snapshotContent = snapshotContent
        self.snapshotting = snapshotting
    }
    
    var body: some View {
        ZStack {
            Group {
                Snapshot(snapshotting) {
                    ZStack(alignment: .top) {
                        // Background for the main phone screen
                        (colorScheme == .dark ? Color.black : Color.white)
                            .edgesIgnoringSafeArea(.all)
                        
                        // Status bar and notch at the top
                        ZStack(alignment: .bottom) {
                            HStack {
                                Text("9:41")
                                    .frame(width: 85)
                                Spacer()
                                HStack(spacing: 2) {
                                    CellularBars()
                                        .frame(height: 10)
                                    Image(systemName: "wifi")
                                    Image(systemName: "battery.100")
                                }
                                .frame(width: 85)
                            }
                            .font(Font.system(size: 14).monospacedDigit().bold())
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .offset(x: 0, y: 2)
                            .padding(.top, .grid(2))
                            .padding(.horizontal, .grid(3))
                            
                            Notch()
                                .fill(Color.black)
                                .frame(height: 25)
                        }
                        .ignoresSafeArea()
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(colorScheme == .dark
                                ? Color.gray.opacity(0.3)
                                : Color.gray.opacity(0.2))
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: bottomSheetHeight + 30)
                            .offset(y: sheetYOffset + backgroundYAdjustment) // Position relative to sheet offset
                            .zIndex(0.5)
                        
                        // Bottom sheet with proper rounded corners
                        VStack(spacing: 0) {
                            // Only add snapshot content, but it will be clipped by the container
                            snapshotContent()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: bottomSheetHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(colorScheme == .dark ? Color.gray : Color.white)
                        )
                        // Apply the clip shape to the entire VStack containing the content
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        // Add shadow separately to avoid clipping it
                        .shadow(color: Color.gray.opacity(0.2), radius: 12, x: 0, y: -5)
                        .offset(y: sheetYOffset)
                        .zIndex(1)
                    }
                }
                .background(backgroundColor.ignoresSafeArea())
            }
            .clipShape(
                RoundedRectangle(cornerRadius: .grid(10), style: .continuous)
            )
            .clipped()
            .padding(.grid(4))
            .background(Color.black)
            .clipShape(
                RoundedRectangle(cornerRadius: .grid(14), style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: .grid(14), style: .continuous)
                    .stroke(Color.gray, style: StrokeStyle(lineWidth: .grid(1) / 2))
            )
            .scaleEffect(0.9)
            .offset(y: .grid(60))
            .shadow(color: Color.black.opacity(0.25), radius: 15, x: 0, y: 0)
            
            VStack(spacing: .grid(7)) {
                VStack(spacing: .grid(7)) {
                    Image(systemName: "briefcase.fill")
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .font(.system(size: 30))
                    
                    description()
                        .font(AppTypography.title)
                        .multilineTextAlignment(.center)
                }
                .foreground(
                    backgroundColor == AppColors.background(for: colorScheme)
                        ? LinearGradient(
                            gradient: Gradient(colors: [AppColors.accent(for: colorScheme), AppColors.primary(for: colorScheme)]),
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                        : nil
                )
                
                Spacer()
            }
            .padding(.horizontal, .grid(10))
            .padding(.vertical, .grid(4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor.ignoresSafeArea())
    }
}
