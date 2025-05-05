//  Created by Muhammed Mahmood on 27/04/2025.

import AppDatabase
import ComposableArchitecture
import CV
import Jobs
import Models
import OSLog
import SharingGRDB
import SwiftUI
import Theme

public struct RootView: View {
    @Environment(\.colorScheme) var colorScheme
    @Bindable var store: StoreOf<RootLogic>

    public init(store: StoreOf<RootLogic>) {
        self.store = store
    }

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

#Preview {
    _ = prepareDependencies {
        $0.defaultDatabase = try! appDatabase()
    }
    return RootView(store: .init(
        initialState: RootLogic.State(currentTab: .jobList),
        reducer: { RootLogic() }
    ))
}

@Reducer
public struct RootLogic: Reducer {
    public init() {}
    public enum Tab: Equatable, Sendable { case jobList, cv, settings }

    @ObservableState
    public struct State: Equatable {
        var currentTab = Tab.jobList
        public var jobList = JobsListLogic.State()
        var cv = CVLogic.State()
        var isAuthorisedForNotifications: Bool = false

        public init(
            currentTab: Tab = Tab.jobList,
            jobList: JobsListLogic.State = JobsListLogic.State(),
            cv: CVLogic.State = CVLogic.State(),
            isAuthorisedForNotifications: Bool = false
        ) {
            self.currentTab = currentTab
            self.jobList = jobList
            self.cv = cv
            self.isAuthorisedForNotifications = isAuthorisedForNotifications
        }
    }

    public enum Action: Equatable, Sendable {
        case jobList(JobsListLogic.Action)
        case cv(CVLogic.Action)
        case selectTab(Tab)
        case checNotificationkAuthorisation
        case setNotificationAuthorisation(Bool)
    }

    public var body: some Reducer<State, Action> {
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
                return .none
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
        ._printChanges()
    }
}

private func testDatabase() throws -> any DatabaseWriter {
    let database: any DatabaseWriter
    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    configuration.prepareDatabase { db in
        db.trace(options: .profile) {
            print("\($0.expandedDescription)")
        }
    }
    database = try DatabaseQueue(configuration: configuration)

    try database.write { db in

        try db.create(table: JobApplication.tableName) { table in
            table.autoIncrementedPrimaryKey("id")
            table.column("createdAt", .datetime).defaults(sql: "CURRENT_TIMESTAMP")
            table.column("title", .text).notNull()
            table.column("company", .text).notNull()
            table.column("dateApplied", .datetime).notNull()
            table.column("status", .text)
            table.column("notes", .text)
            table.column("lastFollowUpDate", .datetime)
            table.column("isArchived", .boolean).defaults(to: false).notNull()
        }
        try db.create(table: ProfessionalLink.tableName) { table in
            table.autoIncrementedPrimaryKey("id")
            table.column("createdAt", .datetime).defaults(sql: "CURRENT_TIMESTAMP")
            table.column("title", .text).notNull()
            table.column("link", .text).notNull()
            table.column("image", .text).notNull()
        }

        try db.createMockData()

        try dump(JobApplication.all.fetchAll(db))
        try dump(ProfessionalLink.all.fetchAll(db))
    }

    return database
}

extension Database {
    func createMockData() throws {
        try createDebugJobApplications()
        try createMockProfessionalLinksData()
    }

    func createDebugJobApplications() throws {
        let currentDate = Date()
        let calendar = Calendar.current

        let applications: [(Date, String, String, String)] = [
            (calendar.date(byAdding: .minute, value: 1, to: currentDate)!, "iOS Developer", "Apple Inc.", "Applied"),
            (calendar.date(byAdding: .day, value: -10, to: currentDate)!, "Senior Swift Developer", "Microsoft", "Interview"),
            (calendar.date(byAdding: .day, value: -7, to: currentDate)!, "Mobile Engineer", "Google", "Offer"),
            (calendar.date(byAdding: .day, value: -3, to: currentDate)!, "Software Engineer", "Meta", "Declined"),
            (currentDate, "Swift Developer", "Amazon", "Declined")
        ]

        for (dateApplied, title, company, status) in applications {
            try seed {
                JobApplication(
                    title: title,
                    company: company,
                    createdAt: Date(),
                    dateApplied: dateApplied,
                    status: status,
                    notes: "Applied for \(title) position at \(company). Waiting for response.",
                    isArchived: false
                )
            }
        }
    }

    func createMockProfessionalLinksData() throws {
        let currentDate = Date()

        let links: [(Date, String, String, String)] = [
            (currentDate, "GitHub", "https://github.com/Muhammed9991", "terminal"),
            (currentDate, "LinkedIn", "https://www.linkedin.com/in/muhammed-mahmood/", "briefcase")
        ]

        for (createdAt, title, link, image) in links {
            try seed {
                ProfessionalLink(
                    createdAt: createdAt,
                    title: title,
                    link: link,
                    image: image
                )
            }
        }
    }
}
