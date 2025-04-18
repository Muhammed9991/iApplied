//  Created by Muhammed Mahmood on 19/04/2025.

import SwiftUI
import Theme

struct JobCardView: View {
    let job: JobApplication
    let isCompact: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.title)
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.primary)
                    
                    if !isCompact {
                        Text(job.company)
                            .font(AppTypography.body)
                    }
                }
                
                Spacer()
                
                StatusBadgeView(status: job.status)
            }
            
            if !isCompact {
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
            } else {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                    Text("\(job.daysSinceApplied)d")
                        .font(AppTypography.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: onEdit) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Normal")
            .bold()
        JobCardView(
            job: JobApplication.mock,
            isCompact: false,
            onEdit: {},
            onDelete: {}
        )
        
        Text("Compact")
            .bold()
        JobCardView(
            job: JobApplication.mock,
            isCompact: true,
            onEdit: {},
            onDelete: {}
        )
    }
    .padding()
}
