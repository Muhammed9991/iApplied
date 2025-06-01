import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!

    static let jobs = Logger(subsystem: subsystem, category: "jobs")
}
