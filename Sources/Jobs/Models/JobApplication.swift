//  Created by Muhammed Mahmood on 19/04/2025.

import Foundation

public struct JobApplication: Identifiable, Codable {
    public var id: UUID
    var title: String
    var company: String
    var dateApplied: Date
    var status: ApplicationStatus
    var notes: String?
    var lastFollowUpDate: Date?

    public init(
        id: UUID = UUID(),
        title: String,
        company: String,
        dateApplied: Date,
        status: ApplicationStatus,
        notes: String? = nil,
        lastFollowUpDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.company = company
        self.dateApplied = dateApplied
        self.status = status
        self.notes = notes
        self.lastFollowUpDate = lastFollowUpDate
    }

    var daysSinceApplied: Int { Calendar.current.dateComponents([.day], from: dateApplied, to: Date()).day ?? 0 }
}

public extension JobApplication {
    static var mock: JobApplication {
        JobApplication(
            title: "iOS Developer",
            company: "Tech Corp",
            dateApplied: Date().addingTimeInterval(-7*24*60*60), // 7 days ago
            status: .applied,
            notes: "Applied through company website. Contact: john@techcorp.com"
        )
    }
}
