import ComposableArchitecture
import Foundation

@Reducer
public struct SettingsLogic: Reducer {
    public init() {}
    
    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    public enum Path {
        case acknowledgements(AcknowledgementsLogic)
        case packageDetaill(PackageDetailLogic)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public init(path: StackState<Path.State> = StackState<Path.State>()) {
            self.path = path
        }
        
        var path = StackState<Path.State>()
    }
    
    public enum Action: Equatable, Sendable, BindableAction {
        case binding(BindingAction<SettingsLogic.State>)
        case onAcknowledgementsButtonTapped
        case path(StackActionOf<Path>)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .onAcknowledgementsButtonTapped:
                state.path.append(.acknowledgements(.init()))
                return .none
                
            case let .path(action):
                switch action {
                case let .element(id: _, action: .acknowledgements(.delegate(.onPackageTapped(package)))):
                    state.path.append(.packageDetaill(.init(package: package)))
                    return .none
                    
                default:
                    return .none
                }

            case .binding:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
