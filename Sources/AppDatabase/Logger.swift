//  Created by Muhammed Mahmood on 03/05/2025.
import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!

    static let appDatabase = Logger(subsystem: subsystem, category: "appDatabase")
}
