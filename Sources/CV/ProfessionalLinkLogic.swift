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
