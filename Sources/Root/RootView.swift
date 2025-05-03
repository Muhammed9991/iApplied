//  Created by Muhammed Mahmood on 27/04/2025.

import AppDatabase
import ComposableArchitecture
import CV
import Jobs
import OSLog
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
            JobsListView(store: store.scope(state: \.jobList, action: \.jobList))
                .tag(RootLogic.Tab.jobList)
                .tabItem {
                    Label("Jobs", systemImage: "briefcase")
                }

            CVTabView(store: store.scope(state: \.cv, action: \.cv))
                .tag(RootLogic.Tab.cv)
                .tabItem {
                    Label("CV", systemImage: "doc.text")
                }

            SettingsView()
                .tag(RootLogic.Tab.settings)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(AppColors.accent(for: colorScheme))
        .task {
            store.send(.checNotificationkAuthorisation)
        }
    }
}

@Reducer
struct RootLogic: Reducer {
    enum Tab: Equatable { case jobList, cv, settings }

    @ObservableState
    struct State: Equatable {
        var currentTab = Tab.jobList
        var jobList = JobsListLogic.State()
        var cv = CVLogic.State()
        var isAuthorisedForNotifications: Bool = false
    }

    enum Action: Equatable, Sendable {
        case jobList(JobsListLogic.Action)
        case cv(CVLogic.Action)
        case selectTab(Tab)
        case checNotificationkAuthorisation
        case setNotificationAuthorisation(Bool)
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
            case .checNotificationkAuthorisation:
                // TODO: Ideally this should have better check. If .notDetermined only then it should continue
                guard !state.isAuthorisedForNotifications else {
                    return .none
                }
                return .run { send in
                    // TODO: this should be moved to a dependency
                    let center = UNUserNotificationCenter.current()
                    let settings = await center.notificationSettings()

                    var isAuthorisedForNotifications = false
                    switch settings.authorizationStatus {
                    case .authorized, .provisional:
                        isAuthorisedForNotifications = true
                    case .notDetermined:
                        do {
                            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                            isAuthorisedForNotifications = granted
                        } catch {
                            isAuthorisedForNotifications = false
                            Logger.root.debug("Authorization request failed: \(error)")
                        }
                    case .denied, .ephemeral:
                        isAuthorisedForNotifications = false
                    @unknown default:
                        isAuthorisedForNotifications = false
                    }

                    await send(.setNotificationAuthorisation(isAuthorisedForNotifications))
                }

            case let .setNotificationAuthorisation(isAuthorisedForNotifications):
                state.isAuthorisedForNotifications = isAuthorisedForNotifications
                return .none

            case .cv, .jobList:
                return .none

            case let .selectTab(tab):
                state.currentTab = tab
                return .none
            }
        }
    }
}
