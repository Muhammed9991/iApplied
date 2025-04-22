//  Created by Muhammed Mahmood on 19/04/2025.

import ComposableArchitecture
import Dependencies
import Jobs
import SwiftUI

struct ContentView: View {
    init() {
        prepareDependencies {
            $0.defaultDatabase = try! Jobs.appDatabase()
        }
    }

    var body: some View {
        JobsListView(store: Store(
            initialState: JobsListLogic.State(),
            reducer: { JobsListLogic() }
        ))
        .colorScheme(.light)
    }
}

#Preview {
    ContentView()
}
