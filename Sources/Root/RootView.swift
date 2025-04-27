//  Created by Muhammed Mahmood on 27/04/2025.

import AppDatabase
import ComposableArchitecture
import Jobs
import SwiftUI

public struct RootView: View {
    public init() {
        prepareDependencies {
            $0.defaultDatabase = try! AppDatabase.appDatabase()
        }
    }

    public var body: some View {
        JobsListView(store: Store(
            initialState: JobsListLogic.State(),
            reducer: { JobsListLogic() }
        ))
    }
}
