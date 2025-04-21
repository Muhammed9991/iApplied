//  Created by Muhammed Mahmood on 19/04/2025.

import Foundation
import GRDB

public struct JobApplication: Identifiable, Codable, Hashable, FetchableRecord, MutablePersistableRecord, Sendable, Equatable {
    public static let databaseTableName = "jobApplications"

    public var id: Int64?
    var title: String
    var company: String
    var createdAt: Date
    var dateApplied: Date
    var status: String
    var notes: String?
    var lastFollowUpDate: Date?

    public init(
        id: Int64? = nil,
        createdAt: Date = Date(),
        title: String,
        company: String,
        dateApplied: Date,
        status: String,
        notes: String? = nil,
        lastFollowUpDate: Date? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.company = company
        self.dateApplied = dateApplied
        self.status = status
        self.notes = notes
        self.lastFollowUpDate = lastFollowUpDate
    }

    var daysSinceApplied: Int { Calendar.current.dateComponents([.day], from: dateApplied, to: Date()).day ?? 0 }

    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

public extension JobApplication {
    static var mock: JobApplication {
        JobApplication(
            title: "iOS Developer",
            company: "Tech Corp",
            dateApplied: Date().addingTimeInterval(-7*24*60*60), // 7 days ago
            status: ApplicationStatus.applied.rawValue,
            notes: "Applied through company website. Contact: john@techcorp.com"
        )
    }
}
