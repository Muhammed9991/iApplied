import Foundation
import Models
import SharingGRDB

func testDatabase() throws -> any DatabaseWriter {
    let database: any DatabaseWriter
    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    configuration.prepareDatabase { db in
        db.trace(options: .profile) {
            print("\($0.expandedDescription)")
        }
    }
    database = try DatabaseQueue(configuration: configuration)

    try database.write { db in

        try db.create(table: JobApplication.tableName) { table in
            table.autoIncrementedPrimaryKey("id")
            table.column("createdAt", .datetime).defaults(sql: "CURRENT_TIMESTAMP")
            table.column("title", .text).notNull()
            table.column("company", .text).notNull()
            table.column("dateApplied", .datetime).notNull()
            table.column("status", .text)
            table.column("notes", .text)
            table.column("lastFollowUpDate", .datetime)
            table.column("isArchived", .boolean).defaults(to: false).notNull()
        }
        try db.create(table: ProfessionalLink.tableName) { table in
            table.autoIncrementedPrimaryKey("id")
            table.column("createdAt", .datetime).defaults(sql: "CURRENT_TIMESTAMP")
            table.column("title", .text).notNull()
            table.column("link", .text).notNull()
            table.column("image", .text).notNull()
        }

        try db.createMockData()

        try dump(JobApplication.all.fetchAll(db))
        try dump(ProfessionalLink.all.fetchAll(db))
    }

    return database
}

private extension Database {
    func createMockData() throws {
        try createDebugJobApplications()
        try createMockProfessionalLinksData()
    }

    func createDebugJobApplications() throws {
        let currentDate = Date()
        let calendar = Calendar.current

        let applications: [(Date, String, String, ApplicationStatus, Bool)] = [
            (calendar.date(byAdding: .minute, value: 1, to: currentDate)!, "iOS Developer", "Apple Inc.", .applied, false),
            (calendar.date(byAdding: .day, value: -10, to: currentDate)!, "Senior Swift Developer", "Microsoft", .interview, false),
            (calendar.date(byAdding: .day, value: -7, to: currentDate)!, "Mobile Engineer", "Google", .offer, false),
            (calendar.date(byAdding: .day, value: -3, to: currentDate)!, "Software Engineer", "Meta", .declined, false),
            (currentDate, "Swift Developer", "Amazon", .declined, false),
            (calendar.date(byAdding: .day, value: -4, to: currentDate)!, "Swift Developer", "Deliveroo", .offer, true)
        ]

        for (dateApplied, title, company, status, isArchived) in applications {
            try seed {
                JobApplication(
                    title: title,
                    company: company,
                    createdAt: Date(),
                    dateApplied: dateApplied,
                    status: status,
                    notes: "Applied for \(title) position at \(company). Waiting for response.",
                    isArchived: isArchived
                )
            }
        }
    }

    func createMockProfessionalLinksData() throws {
        let currentDate = Date()

        let links: [(Date, String, String, String)] = [
            (currentDate, "GitHub", "https://github.com/Muhammed9991", "terminal"),
            (currentDate, "LinkedIn", "https://www.linkedin.com/in/muhammed-mahmood/", "briefcase")
        ]

        for (createdAt, title, link, image) in links {
            try seed {
                ProfessionalLink(
                    createdAt: createdAt,
                    title: title,
                    link: link,
                    image: image
                )
            }
        }
    }
}
