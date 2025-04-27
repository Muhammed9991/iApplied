//  Created by Muhammed Mahmood on 27/04/2025.

import AppDatabase
import ComposableArchitecture
import Jobs
import SwiftUI
import Theme

public struct RootView: View {
    @Environment(\.colorScheme) var colorScheme
    @Bindable var store: StoreOf<RootLogic>

    public init() {
        prepareDependencies {
            $0.defaultDatabase = try! AppDatabase.appDatabase()
        }
        store = Store(initialState: RootLogic.State()) {
            RootLogic()
        }
    }

    public var body: some View {
        TabView(selection: $store.currentTab.sending(\.selectTab)) {
            JobsListView(
                store: store.scope(state: \.jobList, action: \.jobList)
            )
            .tag(RootLogic.Tab.jobList)
            .tabItem {
                Label("Jobs", systemImage: "briefcase")
            }

            CVTabView(
                store: store.scope(state: \.cv, action: \.cv)
            )
            .tag(RootLogic.Tab.cv)
            .tabItem {
                Label("CV", systemImage: "doc.text")
            }
        }
        .accentColor(AppColors.accent(for: colorScheme))
        .onAppear {
            // TODO: Request notification permissions when the app appears
//            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
//                if let error = error {
//                    print("Error requesting notification permissions: \(error)")
//                }
//            }
        }
    }
}

@Reducer
struct RootLogic: Reducer {
    enum Tab: Equatable { case jobList, cv }

    @ObservableState
    struct State: Equatable {
        var currentTab = Tab.jobList
        var jobList = JobsListLogic.State()
        var cv = CVLogic.State()
    }

    enum Action {
        case jobList(JobsListLogic.Action)
        case cv(CVLogic.Action)
        case selectTab(Tab)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.jobList, action: \.jobList) {
            JobsListLogic()
        }
        Scope(state: \.cv, action: \.cv) {
            CVLogic()
        }

        Reduce<State, Action> { state, action in
            switch action {
            case .jobList:
                return .none
            case let .selectTab(tab):
                state.currentTab = tab
                return .none
            }
        }
    }
}

// TODO: move to its own library in another ticket
struct CVTabView: View {
    let store: StoreOf<CVLogic>
    var body: some View {
        Text("Hello World")
    }
}

@Reducer
struct CVLogic {}
