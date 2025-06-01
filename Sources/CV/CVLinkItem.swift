
import ComposableArchitecture
import Models
import SwiftUI
import Theme

struct CVLinkItem: View {
    let professionalLink: ProfessionalLink
    @Environment(\.colorScheme) var colorScheme
    @State private var hasCopied = false
    var onItemTapped: (ProfessionalLink) -> Void
    var onDeleteButtonTapped: (ProfessionalLink) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack {
                HStack {
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
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onItemTapped(professionalLink)
            }
                
            Button {
                UIPasteboard.general.string = professionalLink.link
                withAnimation {
                    hasCopied = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        hasCopied = false
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: hasCopied ? "checkmark" : "doc.on.doc")
                    Text(hasCopied ? "Copied!" : "Copy")
                        .font(AppTypography.caption)
                        .frame(minWidth: 42)
                }
                .frame(height: 28)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(hasCopied ?
                    AppColors.success(for: colorScheme).opacity(0.15) :
                    AppColors.accent(for: colorScheme).opacity(0.15))
                .foregroundColor(AppColors.onSurface(for: colorScheme))
                .cornerRadius(4)
            }
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
