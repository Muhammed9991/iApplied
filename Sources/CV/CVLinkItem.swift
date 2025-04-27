//  Created by Muhammed Mahmood on 27/04/2025.

import ComposableArchitecture
import Models
import SwiftUI
import Theme

struct CVLinkItem: View {
    let professionalLink: ProfessionalLink
    @Environment(\.colorScheme) var colorScheme
    var onItemTapped: (ProfessionalLink) -> Void
    var onDeleteButtonTapped: (ProfessionalLink) -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: professionalLink.image)
                .foregroundColor(AppColors.accent(for: colorScheme))
                
            VStack(alignment: .leading, spacing: 4) {
                Text(professionalLink.title)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.primary(for: colorScheme))
                    
                Text(professionalLink.link)
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
            }
                
            Spacer()
                
            Button {
                UIPasteboard.general.string = professionalLink.link
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
            onItemTapped(professionalLink)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDeleteButtonTapped(professionalLink)
            } label: {
                Label("Delete", systemImage: "trash")
            }
                
            Button {
                onItemTapped(professionalLink)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(AppColors.accent(for: colorScheme))
        }
    }
}

#Preview {
    CVLinkItem(
        professionalLink: ProfessionalLink(
            id: 1,
            createdAt: Date(),
            title: "Github",
            link: "https/www.github.com",
            image: "terminal"
        ),
        onItemTapped: { _ in },
        onDeleteButtonTapped: { _ in }
    )
}
