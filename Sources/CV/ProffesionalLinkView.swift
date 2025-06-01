import ComposableArchitecture
import Models
import SwiftUI
import Theme

struct ProfessionalLinkView: View {
    @Bindable var store: StoreOf<ProfessionalLinkLogic>
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                ValidatedTextField(
                    title: "Title",
                    text: $store.title,
                    error: $store.titleTextFieldError,
                    isRequired: true
                )

                ValidatedTextField(
                    title: "URL",
                    text: $store.urlString,
                    error: $store.linkFieldError,
                    isRequired: true,
                    keyboardType: .URL,
                    autocapitalization: .never,
                    autocorrectionDisabled: true
                )

                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                        ForEach(store.iconOptions, id: \.self) { icon in
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(store.iconName == icon ? AppColors.accent(for: colorScheme).opacity(0.2) : Color.clear)
                                    .frame(width: 50, height: 50)

                                Image(systemName: icon)
                                    .font(AppTypography.title)
                                    .foregroundColor(
                                        store.iconName == icon
                                            ? AppColors.accent(for: colorScheme)
                                            : AppColors.primary(for: colorScheme)
                                    )
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                store.iconName = icon // TODO: move to reducer
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(store.viewMode == .add ? "Add Link" : "Edit link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(store.viewMode == .add ? "Add" : "Save") {
                        store.send(.onButtonTapped)
                    }
                }
            }
        }
    }
}

#Preview("Add Link View") {
    ProfessionalLinkView(
        store: Store(
            initialState: ProfessionalLinkLogic.State(viewMode: .add),
            reducer: { ProfessionalLinkLogic() }
        )
    )
}

#Preview("Edit Link View") {
    ProfessionalLinkView(
        store: Store(
            initialState: ProfessionalLinkLogic.State(viewMode: .edit),
            reducer: { ProfessionalLinkLogic() }
        )
    )
}
