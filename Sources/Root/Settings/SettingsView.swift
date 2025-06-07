import ComposableArchitecture
import SwiftUI
import Theme

private var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
}

private var buildNumber: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
}

public struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Bindable var store: StoreOf<SettingsLogic>

    public init(store: StoreOf<SettingsLogic>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                Section {
                    Button {
                        store.send(.onAcknowledgementsButtonTapped)
                    } label: {
                        HStack {
                            Text("Acknowledgements")
                                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textSecondary(for: colorScheme))
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(AppColors.textPrimary(for: colorScheme))
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .background(AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all))
        } destination: { store in
            switch store.case {
            case let .acknowledgements(acknowledgementsStore):
                AcknowledgementsView(store: acknowledgementsStore)
                    .navigationTitle("Acknowledgements")
                    .navigationBarTitleDisplayMode(.inline)
            case let .packageDetaill(packageDetaillStore):
                PackageDetailView(store: packageDetaillStore)
            }
        }
    }
}

#Preview {
    SettingsView(store: Store(
        initialState: SettingsLogic.State(),
        reducer: { SettingsLogic() }
    ))
}
