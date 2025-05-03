//  Created by Muhammed Mahmood on 03/05/2025.

import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!

    static let jobs = Logger(subsystem: subsystem, category: "jobs")
}
