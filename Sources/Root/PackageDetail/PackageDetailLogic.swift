import Foundation
import ComposableArchitecture

@Reducer
public struct PackageDetailLogic {
    public init() {}
    
    @ObservableState
    public struct State: Equatable, Sendable {
        var package: Package
    }
    
    public enum Action: Equatable, Sendable {
        public enum Delegate: Equatable, Sendable {
            case on
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
