import Dependencies
import Foundation
import GRDB
import Models
import SharingGRDB
import OSLog

public func appDatabase() throws -> any DatabaseWriter {
    let database: any DatabaseWriter
    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    configuration.prepareDatabase { db in
        #if DEBUG
            db.trace(options: .profile) {
                Logger.appDatabase.debug("\($0.expandedDescription)")
            }
        #endif
    }
    @Dependency(\.context) var context
    if context == .live {
        let path = URL.documentsDirectory.appending(component: "db.sqlite").path()
        Logger.appDatabase.debug("sqlite3 \(path)")
        Logger.appDatabase.debug("open \(path)")
        database = try DatabasePool(path: path, configuration: configuration)
    } else {
        database = try DatabaseQueue(configuration: configuration)
    }
    var migrator = DatabaseMigrator()
    #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
    #endif
    migrator.registerMigration("Add job applications lists table") { db in
        try db.create(table: JobApplication.tableName) { table in
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

    migrator.registerMigration("Add isArchived column to job applications table") { db in
        try db.alter(table: JobApplication.tableName) { table in
            table.add(column: "isArchived", .boolean).defaults(to: false).notNull()
        }
    }

    #if DEBUG
        migrator.registerMigration("Add mock data") { db in
            try db.createMockData()
        }
    #endif

    migrator.registerMigration("Add professionalLink table") { db in
        try db.create(table: ProfessionalLink.tableName) { table in
            table.autoIncrementedPrimaryKey("id")
            table.column("createdAt", .datetime).defaults(sql: "CURRENT_TIMESTAMP")
            table.column("title", .text).notNull()
            table.column("link", .text).notNull()
            table.column("image", .text).notNull()
        }
    }

    #if DEBUG
        migrator.registerMigration("Add mock professional links data") { db in
            try db.createMockProfessionalLinksData()
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

            let applications: [(Date, String, String, ApplicationStatus)] = [
                (calendar.date(byAdding: .minute, value: 1, to: currentDate)!, "iOS Developer", "Apple Inc.", .applied),
                (calendar.date(byAdding: .day, value: -10, to: currentDate)!, "Senior Swift Developer", "Microsoft", .interview),
                (calendar.date(byAdding: .day, value: -7, to: currentDate)!, "Mobile Engineer", "Google", .offer),
                (calendar.date(byAdding: .day, value: -3, to: currentDate)!, "Software Engineer", "Meta", .declined),
                (currentDate, "Swift Developer", "Amazon", .declined)
            ]

            for (dateApplied, title, company, status) in applications {
                try seed {
                    JobApplication(
                        title: title,
                        company: company,
                        createdAt: Date(),
                        dateApplied: dateApplied,
                        status: status,
                        notes: "Applied for \(title) position at \(company). Waiting for response.",
                        isArchived: false
                    )
                }
            }
        }

        func createMockProfessionalLinksData() throws {
            let currentDate = Date()

            let links: [(Date, String, String, String)] = [
                (currentDate, "GitHub", "https://github.com", "terminal")
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
#endif
