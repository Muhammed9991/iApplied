import ComposableArchitecture
import DependenciesTestSupport
import Foundation
@testable import Jobs
import Models
import SharingGRDB
import Testing

// swiftformat:disable hoistTry

@MainActor
@Suite(.dependency(\.defaultDatabase, try testDatabase()))
struct JobsListLogicTests {
    // MARK: - Active filter

    @Test
    func activeTab_shows_all_nonArchived_jobs() async {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        await store.send(.binding(.set(\.selectedTab, .active)))
        await store.send(.binding(.set(\.activeFilter, .all)))

        #expect(store.state.jobApplications.count == 4)
    }

    @Test
    func activeTab_filters_applied_jobs() async {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        await store.send(.binding(.set(\.selectedTab, .active)))
        await store.send(.binding(.set(\.activeFilter, .applied))) {
            $0.activeFilter = .applied
        }

        #expect(store.state.jobApplications.count == 1)
        #expect(store.state.jobApplications.first?.status == .applied)
    }

    @Test
    func activeTab_filters_declined_jobs() async {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        await store.send(.binding(.set(\.selectedTab, .active)))
        await store.send(.binding(.set(\.activeFilter, .declined))) {
            $0.activeFilter = .declined
        }

        #expect(store.state.jobApplications.count == 0)
    }

    @Test
    func activeTab_filters_interview_jobs() async {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        await store.send(.binding(.set(\.selectedTab, .active)))
        await store.send(.binding(.set(\.activeFilter, .interview))) {
            $0.activeFilter = .interview
        }

        #expect(store.state.jobApplications.count == 1)
        #expect(store.state.jobApplications.first?.status == .interview)
    }

    @Test
    func activeTab_filters_offer_jobs() async {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        await store.send(.binding(.set(\.selectedTab, .active)))
        await store.send(.binding(.set(\.activeFilter, .offer))) {
            $0.activeFilter = .offer
        }

        #expect(store.state.jobApplications.count == 2)
        #expect(store.state.jobApplications.allSatisfy { $0.status == .offer })
    }

    @Test
    func archivedTab_shows_all_archived_jobs() async {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        await store.send(.binding(.set(\.selectedTab, .archived))) {
            $0.selectedTab = .archived
        }
        await store.send(.binding(.set(\.activeFilter, .all)))

        #expect(store.state.jobApplications.count == 2)
        #expect(try store.state.jobApplications.allSatisfy(\.isArchived))
    }

    @Test
    func archivedTab_filters_offer_jobs() async {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        await store.send(.binding(.set(\.selectedTab, .archived))) {
            $0.selectedTab = .archived
        }
        await store.send(.binding(.set(\.activeFilter, .offer))) {
            $0.activeFilter = .offer
        }

        #expect(store.state.jobApplications.count == 1)
        #expect(store.state.jobApplications.first?.status == .offer)
        #expect(store.state.jobApplications.first?.isArchived == true)
    }

    @Test
    func archivedTab_filters_declined_jobs() async {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        await store.send(.binding(.set(\.selectedTab, .archived))) {
            $0.selectedTab = .archived
        }
        await store.send(.binding(.set(\.activeFilter, .declined))) {
            $0.activeFilter = .declined
        }

        #expect(store.state.jobApplications.count == 1)
        #expect(store.state.jobApplications.first?.status == .declined)
        #expect(store.state.jobApplications.first?.isArchived == true)
    }

    // MARK: - Selected tab

    @Test
    func activeTab_loads_nonArchived_jobs_and_counts() async {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        await store.send(.binding(.set(\.selectedTab, .active)))

        #expect(store.state.jobApplications.count == 4)
        #expect(store.state.jobApplications.allSatisfy { $0.isArchived == false })

        let counts = store.state.jobApplicationStatusCounts
        #expect(counts?.appliedCount == 1)
        #expect(counts?.interviewCount == 1)
        #expect(counts?.offerCount == 2)
        #expect(counts?.declinedCount == 0)
    }

    @Test
    func archivedTab_loads_archived_jobs_and_counts() async {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        await store.send(.binding(.set(\.selectedTab, .archived))) {
            $0.selectedTab = .archived
        }

        #expect(store.state.jobApplications.count == 2)
        #expect(store.state.jobApplications.allSatisfy { $0.isArchived == true })

        let counts = store.state.jobApplicationStatusCounts
        #expect(counts?.appliedCount == 0)
        #expect(counts?.interviewCount == 0)
        #expect(counts?.offerCount == 1)
        #expect(counts?.declinedCount == 1)
    }

    // MARK: - Editing job application

    @Test
    func onEditButtonTapped_setsJobAndNavigatesToForm() async {
        let job = JobApplication(
            id: 123,
            title: "iOS Developer",
            company: "Apple",
            createdAt: Date(),
            dateApplied: Date(),
            status: .applied,
            notes: "Initial note",
            isArchived: false
        )

        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        await store.send(.onEditButtonTapped(job)) {
            $0.jobApplication = job
            $0.destination = .jobForm(JobFormLogic.State(jobApplication: job))
        }
    }

    // MARK: - Adding application

    @Test
    func onAddApplicationTapped_setsDestinationToNewJobForm() async {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        } withDependencies: {
            $0.date.now = Date(timeIntervalSince1970: 1_234_456)
        }

        await store.send(.onAddApplicationTapped) {
            $0.destination = .jobForm(JobFormLogic.State())
        }
    }

    // MARK: - Deleting jobs

    @Test
    func onDeleteButtonTapped_setsJobAndShowsAlert() async {
        let job = JobApplication(
            id: 1,
            title: "iOS Engineer",
            company: "Spotify",
            createdAt: Date(),
            dateApplied: Date(),
            status: .applied,
            notes: "Follow up soon",
            isArchived: false
        )

        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        await store.send(.onDeleteButtonTapped(job)) {
            $0.jobApplication = job
            $0.alert = AlertState {
                TextState("Are you sure you want to delete this job application?")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
                ButtonState(role: .destructive, action: .confirmDeleteJob) {
                    TextState("Delete")
                }
            }
        }
    }

    // MARK: - Tab counts

    @Test
    func tabCount_shows_active_and_archived_counts() async throws {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        // From testDatabase() we know:
        // - 4 active jobs (non-archived)
        // - 2 archived jobs
        try await store.state.$tabCount.load()
        
        #expect(store.state.tabCount?.activeCount == 4)
        #expect(store.state.tabCount?.archivedCount == 2)
    }

    @Test
    func tabCount_updates_when_switching_tabs() async throws {
        let store = TestStore(initialState: JobsListLogic.State()) {
            JobsListLogic()
        }

        try await store.state.$tabCount.load()
        // Initial state (active tab)
        #expect(store.state.tabCount?.activeCount == 4)
        #expect(store.state.tabCount?.archivedCount == 2)

        // Switch to archived tab
        await store.send(.binding(.set(\.selectedTab, .archived))) {
            $0.selectedTab = .archived
        }

        try await store.state.$tabCount.load()
        #expect(store.state.tabCount?.activeCount == 4)
        #expect(store.state.tabCount?.archivedCount == 2)
    }
}

func testDatabase() throws -> any DatabaseWriter {
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

private extension Database {
    func createMockData() throws {
        try createDebugJobApplications()
        try createMockProfessionalLinksData()
    }

    func createDebugJobApplications() throws {
        let currentDate = Date()
        let calendar = Calendar.current

        let applications: [(Date, String, String, ApplicationStatus, Bool)] = [
            (calendar.date(byAdding: .minute, value: 1, to: currentDate)!, "iOS Developer", "Apple Inc.", .applied, false),
            (calendar.date(byAdding: .day, value: -10, to: currentDate)!, "Senior Swift Developer", "Microsoft", .interview, false),
            (calendar.date(byAdding: .day, value: -7, to: currentDate)!, "Mobile Engineer", "Google", .offer, false),
            (calendar.date(byAdding: .day, value: -3, to: currentDate)!, "Software Engineer", "Meta", .offer, false),
            (currentDate, "Swift Developer", "Amazon", .declined, true),
            (calendar.date(byAdding: .day, value: -4, to: currentDate)!, "Swift Developer", "Deliveroo", .offer, true)
        ]

        for (dateApplied, title, company, status, isArchived) in applications {
            try seed {
                JobApplication(
                    title: title,
                    company: company,
                    createdAt: Date(),
                    dateApplied: dateApplied,
                    status: status,
                    notes: "Applied for \(title) position at \(company). Waiting for response.",
                    isArchived: isArchived
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
