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
                    store.send(.addProfessionalLinkButtonTapped)
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
        .padding(.top, 12)
        .sheet(item: $store.scope(state: \.destination?.professionalLink, action: \.destination.professionalLink)) { professionalLinkStore in
            ProfessionalLinkView(store: professionalLinkStore)
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
    
    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    public enum Destination {
        case professionalLink(ProfessionalLinkLogic)
    }
    
    @ObservableState
    public struct State: Equatable {
        var cvLinks: IdentifiedArrayOf<CVLinkItemLogic.State> = []
        var linkBeingAdded: UUID? = nil
        @Presents var destination: Destination.State?
        
        public init(
            cvLinks: IdentifiedArrayOf<CVLinkItemLogic.State> = [],
            linkBeingAdded: UUID? = nil,
            destination: Destination.State? = nil
        ) {
            self.cvLinks = cvLinks
            self.linkBeingAdded = linkBeingAdded
            self.destination = destination
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case cvLinks(IdentifiedActionOf<CVLinkItemLogic>)
        case destination(PresentationAction<Destination.Action>)
        case addProfessionalLinkButtonTapped
    }
    
    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .addProfessionalLinkButtonTapped:
                state.destination = .professionalLink(.init(viewMode: .add))
                return .none
                
            case .binding, .cvLinks, .destination:
                return .none
            }
        }
        .forEach(\.cvLinks, action: \.cvLinks) {
            CVLinkItemLogic()
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

// TODO: needs to be removed see CVLinkLogic
public struct CVLink: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    var title: String
    var url: String
    var iconName: String
    
    static let defaultLinks = [
        CVLink(id: UUID(), title: "GitHub", url: "https://github.com", iconName: "terminal"),
        CVLink(id: UUID(), title: "LinkedIn", url: "https://linkedin.com", iconName: "network"),
        CVLink(id: UUID(), title: "Portfolio", url: "https://portfolio.com", iconName: "doc.text")
    ]
    
    static var example: CVLink {
        CVLink(id: UUID(), title: "GitHub", url: "https://github.com/johndoe", iconName: "terminal")
    }
}
