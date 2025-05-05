//  Created by Muhammed Mahmood on 19/04/2025.

import Root
import SwiftUI
import IssueReporting

@main
struct IAppliedApp: App {
    var body: some Scene {
        WindowGroup {
            if !isTesting {
                RootView()
            }
        }
    }
}
