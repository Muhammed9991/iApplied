import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!

    static let appDatabase = Logger(subsystem: subsystem, category: "appDatabase")
}
