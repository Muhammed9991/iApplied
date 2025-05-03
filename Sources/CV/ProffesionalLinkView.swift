//  Created by Muhammed Mahmood on 27/04/2025.

import ComposableArchitecture
import Models
import SwiftUI
import Theme

@Reducer
public struct ProfessionalLinkLogic: Reducer, Sendable {
    enum Viewmode: Equatable, Sendable {
        case add
        case edit
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        var viewMode: Viewmode
        var id: Int64?
        var createdAt: Date?
        var titleTextFieldError: TextFieldError?
        var linkFieldError: TextFieldError?
        var title: String = ""
        var urlString: String = "https://"
        var iconName: String = "link"
        var iconOptions = ["link", "network", "terminal", "doc.text", "briefcase", "globe", "person.circle"]
    }

    public enum Action: Equatable, Sendable, BindableAction {
        case binding(BindingAction<State>)
        case onButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case onSaveLink(ProfessionalLink)
            case onEditLink(ProfessionalLink)
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.date.now) var now

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .onButtonTapped:
                guard !state.title.isEmpty else {
                    state.titleTextFieldError = .requiredField
                    return .none
                }

                guard !state.urlString.isEmpty else {
                    state.linkFieldError = .requiredField
                    return .none
                }
                state.titleTextFieldError = nil
                state.linkFieldError = nil

                let newLink = ProfessionalLink(
                    id: state.id,
                    createdAt: state.createdAt ?? now,
                    title: state.title,
                    link: state.urlString,
                    image: state.iconName
                )

                return .run { [viewMode = state.viewMode] send in

                    switch viewMode {
                    case .add: await send(.delegate(.onSaveLink(newLink)))

                    case .edit: await send(.delegate(.onEditLink(newLink)))
                    }

                    await dismiss()
                }

            case .binding, .delegate:
                return .none
            }
        }
    }
}

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
