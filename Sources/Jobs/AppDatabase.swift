import Dependencies
import Foundation
import GRDB

public func appDatabase() throws -> any DatabaseWriter {
    let database: any DatabaseWriter
    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    configuration.prepareDatabase { db in
        #if DEBUG
            db.trace(options: .profile) {
                print($0.expandedDescription)
            }
        #endif
    }
    @Dependency(\.context) var context
    if context == .live {
        let path = URL.documentsDirectory.appending(component: "db.sqlite").path()
        print("open", path)
        database = try DatabasePool(path: path, configuration: configuration)
    } else {
        database = try DatabaseQueue(configuration: configuration)
    }
    var migrator = DatabaseMigrator()
    #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
    #endif
    migrator.registerMigration("Add job applications lists table") { db in
        try db.create(table: JobApplication.databaseTableName) { table in
            table.autoIncrementedPrimaryKey("id")
            table.column("createdAt", .datetime).defaults(sql: "CURRENT_TIMESTAMP")
            table.column("title", .text).notNull()
            table.column("company", .text).notNull()
            table.column("dateApplied", .datetime).notNull()
            table.column("status", .text)
            table.column("notes", .text)
            table.column("lastFollowUpDate", .datetime)
        }
    }
    #if DEBUG
        migrator.registerMigration("Add mock data") { db in
            try db.createMockData()
        }
    #endif
    try migrator.migrate(database)

    return database
}

#if DEBUG
    extension Database {
        func createMockData() throws {
            try createDebugJobApplications()
        }

        func createDebugJobApplications() throws {
            let currentDate = Date()
            let calendar = Calendar.current

            let applications: [(Date, String, String, String)] = [
                (calendar.date(byAdding: .day, value: -14, to: currentDate)!, "iOS Developer", "Apple Inc.", "Applied"),
                (calendar.date(byAdding: .day, value: -10, to: currentDate)!, "Senior Swift Developer", "Microsoft", "Interview"),
                (calendar.date(byAdding: .day, value: -7, to: currentDate)!, "Mobile Engineer", "Google", "Offer"),
                (calendar.date(byAdding: .day, value: -3, to: currentDate)!, "Software Engineer", "Meta", "Declined"),
                (currentDate, "Swift Developer", "Amazon", "Archived")
            ]

            for (dateApplied, title, company, status) in applications {
                _ = try JobApplication(
                    title: title,
                    company: company,
                    dateApplied: dateApplied,
                    status: status,
                    notes: "Applied for \(title) position at \(company). Waiting for response."
                )
                .inserted(self)
            }
        }
    }
#endif
