import ComposableArchitecture
import SwiftUI
import Theme

public struct Package: Decodable, Identifiable, Equatable, Sendable {
    public var id: String { identity }

    let identity: String
    let kind: String
    let license: String
    let location: String
    let name: String
    let revision: String
    let version: String?
}

struct PackageDetailView: View {
    let store: StoreOf<PackageDetailLogic>
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.package.name)
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary(for: colorScheme))

                    if let version = store.package.version {
                        Text("Version \(version)")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    }
                }

                Divider()

                if let url = URL(string: store.package.location) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Repository")
                            .font(AppTypography.subtitle)
                            .foregroundColor(AppColors.textPrimary(for: colorScheme))

                        Link(destination: url) {
                            Text(store.package.location)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.accent(for: colorScheme))
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("License")
                        .font(AppTypography.subtitle)
                        .foregroundColor(AppColors.textPrimary(for: colorScheme))

                    Text(store.package.license)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(store.package.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all))
    }
}
