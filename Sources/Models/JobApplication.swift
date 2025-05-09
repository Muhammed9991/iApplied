//  Created by Muhammed Mahmood on 19/04/2025.

import Foundation
import GRDB
import SharingGRDB

@Table
public struct JobApplication: Identifiable, Sendable, Equatable {
    public var id: Int64?
    public var title: String
    public var company: String
    @Column(as: Date.ISO8601Representation.self) public var createdAt: Date
    @Column(as: Date.ISO8601Representation.self) public var dateApplied: Date
    public var status: ApplicationStatus
    public var notes: String?
    @Column(as: Date.ISO8601Representation?.self) public var lastFollowUpDate: Date?
    public var isArchived: Bool = false

    public init(
        id: Int64? = nil,
        title: String,
        company: String,
        createdAt: Date,
        dateApplied: Date,
        status: ApplicationStatus,
        notes: String? = nil,
        lastFollowUpDate: Date? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.company = company
        self.createdAt = createdAt
        self.dateApplied = dateApplied
        self.status = status
        self.notes = notes
        self.lastFollowUpDate = lastFollowUpDate
        self.isArchived = isArchived
    }

    public var daysSinceApplied: Int { Calendar.current.dateComponents([.day], from: dateApplied, to: Date()).day ?? 0 }
}

public extension JobApplication {
    static var mock: JobApplication {
        JobApplication(
            title: "iOS Developer",
            company: "Tech Corp",
            createdAt: Date(),
            dateApplied: Date().addingTimeInterval(-7*24*60*60), // 7 days ago
            status: ApplicationStatus.applied,
            notes: "Applied through company website. Contact: john@techcorp.com"
        )
    }
}
