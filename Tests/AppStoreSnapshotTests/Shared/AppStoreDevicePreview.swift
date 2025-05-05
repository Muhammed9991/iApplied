import SnapshotTesting
import SwiftUI
import Theme
import UIKit

struct AppStoreDevicePreview<SnapshotContent, Description>: View where Description: View, SnapshotContent: View {
    let backgroundColor: Color
    let description: () -> Description
    @Environment(\.colorScheme) var colorScheme
    let snapshotContent: () -> SnapshotContent
    let snapshotting: Snapshotting<AnyView, UIImage>

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
                        snapshotContent()
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
                    }
                }
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

extension View {
    @ViewBuilder
    func foreground(_ view: (some View)?) -> some View {
        if let view {
            overlay(view).mask(self)
        } else {
            self
        }
    }
}

struct Notch: Shape {
    func path(in rect: CGRect) -> Path {
        Path {
            let notchInset = rect.size.width * 0.23
            let smallNotchRadius: CGFloat = 7
            let scaleFactor: CGFloat = 1.6
            let notchRadius = rect.maxY / scaleFactor

            $0.move(to: .init(x: 0, y: 0))
            $0.addLine(to: .init(x: notchInset, y: 0))
            $0.addArc(
                center: .init(x: notchInset - smallNotchRadius, y: smallNotchRadius),
                radius: smallNotchRadius,
                startAngle: .init(degrees: -90),
                endAngle: .init(degrees: 0),
                clockwise: false
            )
            $0.addArc(
                center: .init(x: notchInset + notchRadius, y: notchRadius * (scaleFactor - 1)),
                radius: notchRadius,
                startAngle: .init(degrees: 180),
                endAngle: .init(degrees: 90),
                clockwise: true
            )
            $0.addLine(to: .init(x: rect.width - notchInset - notchRadius, y: rect.height))
            $0.addArc(
                center: .init(x: rect.width - notchInset - notchRadius, y: notchRadius * (scaleFactor - 1)),
                radius: notchRadius,
                startAngle: .init(degrees: 90),
                endAngle: .init(degrees: 0),
                clockwise: true
            )
            $0.addLine(to: .init(x: rect.width - notchInset, y: 0))
            $0.addArc(
                center: .init(x: rect.width - notchInset + smallNotchRadius, y: smallNotchRadius),
                radius: smallNotchRadius,
                startAngle: .init(degrees: 180),
                endAngle: .init(degrees: 270),
                clockwise: false
            )
            $0.addLine(to: .init(x: rect.width, y: 0))
            $0.closeSubpath()
        }
    }
}

struct CellularBars: View {
    let barsCount = 4
    let minimumHeightRatio = CGFloat(0.5)

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .bottom, spacing: 1) {
                ForEach(0 ... barsCount - 1, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .frame(height: proxy.size.height * heightRatio(at: index))
                }
            }
        }
        .aspectRatio(1.71, contentMode: .fit)
    }

    private func heightRatio(at index: Int) -> CGFloat {
        let leftover = 1.0 - minimumHeightRatio
        let step = leftover / CGFloat(barsCount - 1)
        return minimumHeightRatio + CGFloat(index) * step
    }
}

extension CGFloat {
    static func grid(_ multiplier: CGFloat) -> CGFloat {
        multiplier * 4
    }
}
