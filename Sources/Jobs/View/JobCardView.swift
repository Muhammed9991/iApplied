import ComposableArchitecture
import Models
import SwiftUI
import Theme

struct JobCardView: View {
    @Bindable var store: StoreOf<JobCardLogic>
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.job.company)
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.primary(for: colorScheme))
                    
                    if !store.isCompact {
                        Text(store.job.title)
                            .font(AppTypography.body)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                
                Spacer()
                
                StatusBadgeView(status: store.job.status)
                    .animation(.spring(response: 0.3), value: store.isCompact)
            }
            
            if !store.isCompact {
                VStack {
                    Divider()
                    
                    HStack {
                        Text("Applied \(store.job.daysSinceApplied) day\(store.job.daysSinceApplied == 1 ? "" : "s") ago")
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                    Text("\(store.job.daysSinceApplied)d")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Spacer()
                        .frame(width: 30)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(AppColors.cardBackground(for: colorScheme))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.isCompact)
        .padding(.bottom, 8)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Text("Normal")
            .bold()
        JobCardView(
            store: Store(
                initialState: JobCardLogic.State(
                    job: JobApplication.mock,
                    isCompact: false
                ),
                reducer: { JobCardLogic() }
            )
        )
        
        Text("Compact")
            .bold()
        JobCardView(
            store: Store(
                initialState: JobCardLogic.State(
                    job: JobApplication.mock,
                    isCompact: true
                ),
                reducer: { JobCardLogic() }
            )
        )
    }
    .padding()
}

// MARK: - Reducer

@Reducer
struct JobCardLogic: Reducer {
    @ObservableState
    struct State: Equatable, Sendable {
        var job: JobApplication
        var isCompact: Bool = true
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
