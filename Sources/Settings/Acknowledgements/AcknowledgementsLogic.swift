import ComposableArchitecture
import Foundation

private let dependencyPackageJson = "package-list"

@Reducer
public struct AcknowledgementsLogic {
    public init() {}

    @ObservableState
    public struct State: Equatable, Sendable {
        var packages: [Package] = []
        var isLoading = true
    }

    public enum Action: Equatable, Sendable {
        case onAppear
        case setPackages([Package])
        case delegate(Delegate)
        
        public enum Delegate: Equatable, Sendable {
            case onPackageTapped(Package)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await withErrorReporting {
                        if let url = Bundle.module.url(forResource: dependencyPackageJson, withExtension: "json") {
                            let data = try Data(contentsOf: url)
                            let decoder = JSONDecoder()
                            let jsonData = try decoder.decode([Package].self, from: data)
                            await send(.setPackages(jsonData.sorted { $0.name.lowercased() < $1.name.lowercased() }))
                        }
                    }
                }

            case let .setPackages(packages):
                state.isLoading = false
                state.packages = packages
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
