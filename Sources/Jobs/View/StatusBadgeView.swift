//  Created by Muhammed Mahmood on 19/04/2025.

import Models
import SwiftUI

struct StatusBadgeView: View {
    let status: ApplicationStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.2))
            .foregroundColor(status.color)
            .cornerRadius(8)
    }
}
