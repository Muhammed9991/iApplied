//  Created by Muhammed Mahmood on 19/04/2025.

import Models
import SwiftUI

struct StatusBadgeView: View {
    let status: String
    var applicationStatus: ApplicationStatus { ApplicationStatus.toApplicationStatus(from: status) }

    var body: some View {
        Text(applicationStatus.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(applicationStatus.color.opacity(0.2))
            .foregroundColor(applicationStatus.color)
            .cornerRadius(8)
    }
}
