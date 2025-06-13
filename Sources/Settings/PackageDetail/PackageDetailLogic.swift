import ComposableArchitecture
import Foundation

@Reducer
public struct PackageDetailLogic {
    public init() {}

    @ObservableState
    public struct State: Equatable, Sendable {
        var package: Package
    }
}
