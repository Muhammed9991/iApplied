import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!

    static let root = Logger(subsystem: subsystem, category: "jobs")
}
