//  Created by Muhammed Mahmood on 27/04/2025.

import ComposableArchitecture
import SwiftUI
import Theme

public struct CVTabView: View {
    @Bindable var store: StoreOf<CVLogic>
    @Environment(\.colorScheme) var colorScheme
    
    public init(store: StoreOf<CVLogic>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Professional Links")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.primary(for: colorScheme))
                
                Spacer()
                
                Button {
                    // TODO: Handle adding new link
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(AppColors.primary(for: colorScheme))
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                if store.cvLinks.isEmpty {
                    Text("Add your professional links using the + button")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                        .padding()
                } else {
                    List {
                        ForEach(store.scope(state: \.cvLinks, action: \.cvLinks)) { store in
                            CVLinkItem(store: store)
                        }
                        .listStyle(.plain)
                        .padding(.horizontal, -16)
                    }
                    .listRowSeparator(.visible)
                    .listRowBackground(Color.clear)
                }
            }
        }
    }
}

#Preview {
    CVTabView(store: Store(
        initialState: CVLogic.State(),
        reducer: { CVLogic() }
    ))
}

@Reducer
public struct CVLogic {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var cvLinks: IdentifiedArrayOf<CVLinkItemLogic.State> = []
        var linkBeingAdded: UUID? = nil
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case cvLinks(IdentifiedActionOf<CVLinkItemLogic>)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .binding, .cvLinks:
                .none
            }
        }
        .forEach(\.cvLinks, action: \.cvLinks) {
            CVLinkItemLogic()
        }
    }
}

// TODO: needs to be removed see CVLinkLogic
public struct CVLink: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    var title: String
    var url: URL
    var iconName: String
    
    static let defaultLinks = [
        CVLink(id: UUID(), title: "GitHub", url: URL(string: "https://github.com")!, iconName: "terminal"),
        CVLink(id: UUID(), title: "LinkedIn", url: URL(string: "https://linkedin.com")!, iconName: "network"),
        CVLink(id: UUID(), title: "Portfolio", url: URL(string: "https://portfolio.com")!, iconName: "doc.text")
    ]
    
    static var example: CVLink {
        CVLink(id: UUID(), title: "GitHub", url: URL(string: "https://github.com/johndoe")!, iconName: "terminal")
    }
}

@Reducer
public struct CVLinkLogic: Reducer {
    @ObservableState
    public struct State: Equatable, Sendable, Identifiable {
        public var id: UUID
        var title: String
        var url: URL
        var iconName: String
    }
    
    public enum Action: Equatable, Sendable {}
    
    public var body: some Reducer<State, Action> {
        Reduce { _, _ in
//            switch action {
            .none
//            }
        }
    }
}
