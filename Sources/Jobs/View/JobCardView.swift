//  Created by Muhammed Mahmood on 19/04/2025.

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
                        
                        HStack(spacing: 12) {
                            Button(action: onEdit) {
                                Image(systemName: "pencil")
                                    .foregroundColor(AppColors.accent)
                            }
                            
                            Button(action: onDelete) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
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
                    
                    Menu {
                        Button(action: onEdit) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(AppColors.primary)
                            .padding(5)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isCompact)
    }
}

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
