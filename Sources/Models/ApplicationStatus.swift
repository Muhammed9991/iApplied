//  Created by Muhammed Mahmood on 19/04/2025.

import SwiftUI
import Theme

public enum ApplicationStatus: String, CaseIterable, Codable, Sendable, Equatable {
    case applied = "Applied"
    case interview = "Interview"
    case offer = "Offer"
    case declined = "Declined"

    public var color: Color {
        switch self {
        case .applied: AppColors.Status.applied
        case .interview: AppColors.Status.interview
        case .offer: AppColors.Status.offer
        case .declined: AppColors.Status.declined
        }
    }

    var needsFollowUp: Bool { self == .applied }

    public static func toApplicationStatus(from string: String) -> Self {
        switch string {
        case "Applied": .applied
        case "Interview": .interview
        case "Offer": .offer
        case "Declined": .declined
        default: fatalError("Unknown status")
        }
    }
}
