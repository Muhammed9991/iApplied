import ComposableArchitecture
import SwiftUI
import Theme

struct AcknowledgementsView: View {
    @Environment(\.colorScheme) var colorScheme
    let store: StoreOf<AcknowledgementsLogic>

    var body: some View {
        NavigationView {
            VStack {
                if store.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accent(for: colorScheme)))
                        Text("Loading Acknowledgements...")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(store.packages) { package in

                            Button {
                                store.send(.delegate(.onPackageTapped(package)))
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(package.name)
                                            .font(AppTypography.subtitle)
                                            .foregroundColor(AppColors.textPrimary(for: colorScheme))

                                        if let version = package.version {
                                            Text("v\(version)")
                                                .font(AppTypography.caption)
                                                .foregroundColor(AppColors.textSecondary(for: colorScheme))
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .background(AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all))
            .task { store.send(.onAppear) }
        }
    }
}
