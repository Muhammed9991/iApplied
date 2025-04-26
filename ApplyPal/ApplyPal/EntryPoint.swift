//  Created by Muhammed Mahmood on 19/04/2025.

import AppDatabase
import ComposableArchitecture
import Dependencies
import Jobs
import SwiftUI

@main
struct ApplyPalApp: App {
    init() {
        prepareDependencies {
            $0.defaultDatabase = try! AppDatabase.appDatabase()
        }
    }

    var body: some Scene {
        WindowGroup {
            JobsListView(store: Store(
                initialState: JobsListLogic.State(),
                reducer: { JobsListLogic() }
            ))
        }
    }
}
