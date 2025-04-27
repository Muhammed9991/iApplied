//  Created by Muhammed Mahmood on 27/04/2025.

import ComposableArchitecture
import SwiftUI
import Theme

@Reducer
public struct CVLinkItemLogic: Reducer {
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

struct CVLinkItem: View {
    let store: StoreOf<CVLinkItemLogic>
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: store.iconName)
                .foregroundColor(AppColors.accent(for: colorScheme))
                
            VStack(alignment: .leading, spacing: 4) {
                Text(store.title)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.primary(for: colorScheme))
                    
                Text(store.url.absoluteString)
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
            }
                
            Spacer()
                
            Button {
                UIPasteboard.general.string = store.url.absoluteString
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "doc.on.doc")
                    Text("Copy")
                        .font(AppTypography.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.accent(for: colorScheme).opacity(0.1))
                .foregroundColor(AppColors.accent(for: colorScheme))
                .cornerRadius(4)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // TODO: Open EditLinkView
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                // TODO: Handle delete
            } label: {
                Label("Delete", systemImage: "trash")
            }
                
            Button {
                // TODO: Open EditLinkView
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(AppColors.accent(for: colorScheme))
        }
    }
}
