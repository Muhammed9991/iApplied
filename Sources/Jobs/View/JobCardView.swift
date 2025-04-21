//  Created by Muhammed Mahmood on 19/04/2025.

import ComposableArchitecture
import SwiftUI
import Theme

struct JobCardView: View {
    let job: JobApplication
    @Binding var isCompact: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.company)
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.primary)
                    
                    if !isCompact {
                        Text(job.title)
                            .font(AppTypography.body)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                
                Spacer()
                
                StatusBadgeView(status: job.status)
                    .animation(.spring(response: 0.3), value: isCompact)
            }
            
            if !isCompact {
                VStack {
                    Divider()
                    
                    HStack {
                        Text("Applied \(job.daysSinceApplied) day\(job.daysSinceApplied == 1 ? "" : "s") ago")
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
                    Text("\(job.daysSinceApplied)d")
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
        .background(AppColors.cardBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isCompact)
        .padding(.bottom, 8)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Text("Normal")
            .bold()
        JobCardView(
            job: JobApplication.mock,
            isCompact: .constant(false),
            onEdit: {},
            onDelete: {}
        )
        
        Text("Compact")
            .bold()
        JobCardView(
            job: JobApplication.mock,
            isCompact: .constant(true),
            onEdit: {},
            onDelete: {}
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
