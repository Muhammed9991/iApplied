import ComposableArchitecture
import SwiftUI
import Theme

@Reducer
struct NewLinkLogic: Reducer {
    @ObservableState
    struct State: Equatable, Sendable {
        var title: String = ""
        var urlString: String = "https://"
        var iconName: String = "link"
        var iconOptions = ["link", "network", "terminal", "doc.text", "briefcase", "globe", "person.circle"]
    }
    
    enum Action: Equatable, Sendable, BindableAction {
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce<State, Action> { _, action in
            switch action {
            case .binding:
                .none
            }
        }
    }
}

struct NewLinkView: View {
    @Bindable var store: StoreOf<NewLinkLogic>
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    let onCreate: (CVLink) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $store.title)
                TextField("URL", text: $store.urlString)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
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
            .navigationTitle("Add Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let url = URL(string: store.urlString) {
                            // TODO: needs to be moved to reducer
                            let newLink = CVLink(
                                id: UUID(),
                                title: store.title,
                                url: url,
                                iconName: store.iconName
                            )
                            onCreate(newLink)
                            dismiss()
                        }
                    }
                    .disabled(store.title.isEmpty || store.urlString.isEmpty || !isValidURL(store.urlString))
                }
            }
        }
    }
    
    private func isValidURL(_ string: String) -> Bool {
        // Simple validation to check if the URL is potentially valid
        if let url = URL(string: string), url.scheme != nil, url.host != nil {
            return true
        }
        return false
    }
}

#Preview {
    NewLinkView(
        store: Store(
            initialState: NewLinkLogic.State(),
            reducer: { NewLinkLogic() }
        )
    ) { _ in
    }
}
