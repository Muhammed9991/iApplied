//  Created by Muhammed Mahmood on 19/04/2025.

import Foundation
import GRDB
import SharingGRDB

@Table
public struct JobApplication: Identifiable, Sendable, Equatable {
    public var id: Int64?
    var title: String
    var company: String
    @Column(as: Date.ISO8601Representation.self) var createdAt: Date
    @Column(as: Date.ISO8601Representation.self) var dateApplied: Date
    var status: String
    var notes: String?
    @Column(as: Date.ISO8601Representation?.self) var lastFollowUpDate: Date?

    var daysSinceApplied: Int { Calendar.current.dateComponents([.day], from: dateApplied, to: Date()).day ?? 0 }
}

public extension JobApplication {
    static var mock: JobApplication {
        JobApplication(
            title: "iOS Developer",
            company: "Tech Corp",
            createdAt: Date(),
            dateApplied: Date().addingTimeInterval(-7*24*60*60), // 7 days ago
            status: ApplicationStatus.applied.rawValue,
            notes: "Applied through company website. Contact: john@techcorp.com"
        )
    }
}
