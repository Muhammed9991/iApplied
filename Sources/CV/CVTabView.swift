import AppDatabase
import ComposableArchitecture
import Models
import SharingGRDB
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
            
            if store.professionalLinks.isEmpty {
                ScrollView {
                    Text("Add your professional links using the + button")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                        .padding()
                }
            } else {
                List {
                    ForEach(store.professionalLinks) { link in
                        CVLinkItem(
                            professionalLink: link,
                            onItemTapped: { link in
                                store.send(.onLinkTapped(link))
                            }, onDeleteButtonTapped: { professionalLink in
                                store.send(.onDeleteLinkItemTapped(professionalLink))
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(AppColors.background(for: colorScheme))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AppColors.background(for: colorScheme))
            }
        }
        .padding(.top, 12)
        .sheet(item: $store.scope(state: \.destination?.professionalLink, action: \.destination.professionalLink)) { professionalLinkStore in
            ProfessionalLinkView(store: professionalLinkStore)
        }
        .background(AppColors.background(for: colorScheme))
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    _ = try! prepareDependencies {
        $0.defaultDatabase = try AppDatabase.appDatabase()
    }
    
    return NavigationStack {
        CVTabView(store: Store(
            initialState: CVLogic.State(),
            reducer: { CVLogic() }
        ))
    }
}

@Reducer
public struct CVLogic: Sendable {
    public init() {}
    
    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    public enum Destination {
        case professionalLink(ProfessionalLinkLogic)
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        
        @ObservationStateIgnored
        @FetchAll(ProfessionalLink.all)
        var professionalLinks
        
        var professionalLink: ProfessionalLink?
        @Presents var alert: AlertState<Action.Alert>?
        
        public init(destination: Destination.State? = nil) {
            self.destination = destination
        }
    }
    
    public enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case addProfessionalLinkButtonTapped
        case onLinkTapped(ProfessionalLink)
        case onDeleteLinkItemTapped(ProfessionalLink)
        case alert(PresentationAction<Alert>)
        @CasePathable
        public enum Alert: Equatable, Sendable {
            case confirmDeleteLink
        }
    }
    
    @Dependency(\.defaultDatabase) var database
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .addProfessionalLinkButtonTapped:
                state.destination = .professionalLink(.init(viewMode: .add))
                return .none
                
            case let .onLinkTapped(professionalLink):
                state.destination = .professionalLink(.init(
                    viewMode: .edit,
                    id: professionalLink.id,
                    createdAt: professionalLink.createdAt,
                    title: professionalLink.title,
                    urlString: professionalLink.link,
                    iconName: professionalLink.image
                ))
                return .none
                
            case let .onDeleteLinkItemTapped(professionalLink):
                state.professionalLink = professionalLink
                state.alert = AlertState {
                    TextState("Are you sure you want to delete this link?")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                    ButtonState(role: .destructive, action: .confirmDeleteLink) {
                        TextState("Delete")
                    }
                }
                return .none
                
            case .alert(.presented(.confirmDeleteLink)):
                state.alert = nil
                return .run { [professionalLink = state.professionalLink] _ in
                    precondition(professionalLink != nil, "How can this even be nil at this point?")
                    try database.write { db in
                        try ProfessionalLink.delete(professionalLink!).execute(db)
                    }
                }
                
            case let .destination(.presented(.professionalLink(.delegate(delegate)))):
                
                switch delegate {
                case let .onSaveLink(professionalLink):
                    return .run { _ in
                        try await database.write { db in
                            try ProfessionalLink.insert(professionalLink).execute(db)
                        }
                    }
                    
                case let .onEditLink(professionalLink):
                    return .run { _ in
                        try await database.write { db in
                            try ProfessionalLink.update(professionalLink).execute(db)
                        }
                    }
                }
                
            case .binding, .destination, .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
}
