//  Created by Muhammed Mahmood on 19/04/2025.

import SwiftUI
import Theme

public enum ApplicationStatus: String, CaseIterable, Codable {
    case applied = "Applied"
    case interview = "Interview"
    case offer = "Offer"
    case declined = "Declined"
    case archived = "Archived"

    public var color: Color {
        switch self {
        case .applied: AppColors.Status.applied
        case .interview: AppColors.Status.interview
        case .offer: AppColors.Status.offer
        case .declined: AppColors.Status.declined
        case .archived: AppColors.Status.archived
        }
    }

    var needsFollowUp: Bool { self == .applied }
}
