import ComposableArchitecture
import Models
import SharingGRDB

extension SharedReaderKey where Self == AppStorageKey<Bool> {
    static var isCompact: Self { .appStorage("isCompact") }
}

enum FilterType: String, CaseIterable, Hashable, Equatable, Sendable {
    case all = "All"
    case applied = "Applied"
    case interview = "Interview"
    case offer = "Offer"
    case declined = "Declined"
}

extension FilterType {
    var emptyStateMessage: String {
        switch self {
        case .all: "" // Not shown using this
        case .applied: "You haven’t applied to any jobs yet."
        case .interview: "You don’t have any interviews scheduled yet."
        case .offer: "You haven’t received any job offers yet."
        case .declined: "You haven’t declined any jobs yet."
        }
    }
}

@Reducer
public struct JobsListLogic: Reducer, Sendable {
    public init() {}
    
    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    public enum Destination {
        case jobForm(JobFormLogic)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        public init(
            jobApplication: JobApplication? = nil,
            destination: JobsListLogic.Destination.State? = nil,
            alert: AlertState<JobsListLogic.Action.Alert>? = nil,
            selectedTab: Tab = .active
        ) {
            self.selectedTab = selectedTab
            
            self._jobApplications = FetchAll(JobApplication.all.where { !$0.isArchived }.order { $0.dateApplied.desc() })
            
            let isArchived = selectedTab == .archived
            
            self._tabCount = FetchOne(wrappedValue: nil, Select.tabCount(isArchivedTab: isArchived))
            self._jobApplicationStatusCounts = FetchOne(wrappedValue: nil, Select.jobApplicationStatusCounts(isArchivedTab: isArchived))
            
            self.jobApplication = jobApplication
            self.destination = destination
            self.alert = alert
        }
        
        @ObservationStateIgnored
        @FetchAll(JobApplication.all)
        var allJobApplications
        
        @ObservationStateIgnored
        @FetchAll var jobApplications: [JobApplication]

        @ObservationStateIgnored
        @FetchOne var tabCount: TabCount?
        
        @ObservationStateIgnored
        @FetchOne var jobApplicationStatusCounts: JobApplicationStatusCounts?
        
        var selectedTab: Tab = .active
        @Shared(.isCompact) var isCompact: Bool = false
        var jobApplication: JobApplication?
        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<Action.Alert>?
        var activeFilter: FilterType = .all

        public enum Tab: Equatable, Sendable {
            case active
            case archived
        }
        
        // Queries
        var jobApplicationQuery: some SelectStatementOf<JobApplication> {
            JobApplication
                .where {
                    switch selectedTab {
                    case .active: !$0.isArchived
                    case .archived: $0.isArchived
                    }
                }
                .where {
                    let isArchivedTab = selectedTab == .archived
                    switch activeFilter {
                    case .all: $0.isArchived == isArchivedTab
                    case .applied: $0.isArchived == isArchivedTab && $0.status == ApplicationStatus.applied
                    case .interview: $0.isArchived == isArchivedTab && $0.status == ApplicationStatus.interview
                    case .offer: $0.isArchived == isArchivedTab && $0.status == ApplicationStatus.offer
                    case .declined: $0.isArchived == isArchivedTab && $0.status == ApplicationStatus.declined
                    }
                }
                .order { $0.dateApplied.desc() }
        }
    }

    public enum Action: Equatable, Sendable, BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case onEditButtonTapped(JobApplication)
        case onAddApplicationTapped
        case onDeleteButtonTapped(JobApplication)
        case archiveJob(job: JobApplication)
        case unArchiveJob(job: JobApplication)
        case updateJobStatus(job: JobApplication, status: ApplicationStatus)
        
        case alert(PresentationAction<Alert>)
        @CasePathable
        public enum Alert: Equatable, Sendable {
            case confirmDeleteJob
        }
    }
    
    @Dependency(\.defaultDatabase) var database
    @Dependency(NotificationManager.self) var notificationManager
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .binding(\.activeFilter):
                return .run { [
                    jobApplications = state.$jobApplications,
                    jobApplicationQuery = state.jobApplicationQuery
                ] _ in
                    await updateQuery(jobApplications: jobApplications, jobApplicationQuery: jobApplicationQuery)
                }
                
            case .binding(\.selectedTab):
                return .run { [
                    jobApplicationStatusCounts = state.$jobApplicationStatusCounts,
                    jobApplications = state.$jobApplications,
                    selectedTab = state.selectedTab,
                    jobApplicationQuery = state.jobApplicationQuery
                ] _ in
                    
                    await updateQuery(jobApplications: jobApplications, jobApplicationQuery: jobApplicationQuery)
                                        
                    try await jobApplicationStatusCounts.load(
                        Select.jobApplicationStatusCounts(isArchivedTab: selectedTab == .archived),
                        animation: .default
                    )
                }
            
            case .alert(.presented(.confirmDeleteJob)):
                state.alert = nil
                return .run { [jobApplication = state.jobApplication] _ in
                    precondition(jobApplication != nil, "How can this even be nil at this point?")
                    withErrorReporting {
                        try database.write { db in
                            try JobApplication.delete(jobApplication!).execute(db)
                        }
                    }
                    
                    if let id = jobApplication?.id {
                        notificationManager.cancelNotification("\(id)")
                    }
                }
                .animation(.default)
                
            case let .onEditButtonTapped(jobApplication):
                state.jobApplication = jobApplication
                state.destination = .jobForm(JobFormLogic.State(jobApplication: jobApplication))
                return .none
                
            case .onAddApplicationTapped:
                state.destination = .jobForm(JobFormLogic.State())
                return .none
                
            case let .onDeleteButtonTapped(jobApplication):
                state.jobApplication = jobApplication
                state.alert = AlertState {
                    TextState("Are you sure you want to delete this job application?")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                    ButtonState(role: .destructive, action: .confirmDeleteJob) {
                        TextState("Delete")
                    }
                }
                return .none
                
            case let .updateJobStatus(job: job, status: status):
                return .run { _ in
                    await withErrorReporting {
                        try await database.write { db in
                            var updatedJob = job
                            updatedJob.status = status
                            try JobApplication.update(updatedJob).execute(db)
                        }
                    }
                    
                    if let id = job.id {
                        if status == .applied {
                            try await notificationManager.scheduleFollowUpNotification(job)
                        } else {
                            notificationManager.cancelNotification("\(id)")
                        }
                    }
                }
                
            case let .archiveJob(job: job):
                return .run { _ in
                    await withErrorReporting {
                        try await database.write { db in
                            var updatedJob = job
                            updatedJob.isArchived = true
                            try JobApplication.update(updatedJob).execute(db)
                        }
                    }
                    
                    if let id = job.id {
                        notificationManager.cancelNotification("\(id)")
                    }
                }
                
            case let .unArchiveJob(job: job):
                return .run { _ in
                    await withErrorReporting {
                        try await database.write { db in
                            var updatedJob = job
                            updatedJob.isArchived = false
                            try JobApplication.update(updatedJob).execute(db)
                        }
                    }
                    
                    if job.status == ApplicationStatus.applied {
                        try await notificationManager.scheduleFollowUpNotification(job)
                    }
                }
                
            case let .destination(.presented(.jobForm(.delegate(.onSaveButtonTapped(job))))):
                
                return .run { [jobApplications = state.allJobApplications] _ in
                    
                    guard jobApplications.firstIndex(where: { $0.id == job.id }) != nil else {
                        // Add new job
                        try await database.write { db in
                            try JobApplication.insert(job).execute(db)
                        }
                        try await rescheduleAllNotifications(jobApplications: jobApplications)
                        return
                    }
                    
                    // Update existing job
                    await withErrorReporting {
                        try await database.write { db in
                            try JobApplication.update(job).execute(db)
                        }
                    }
                    try await rescheduleAllNotifications(jobApplications: jobApplications)
                }
                
            case .binding, .destination, .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
    
    func rescheduleAllNotifications(jobApplications: [JobApplication]) async throws {
        // HACK: When a new job is saved. We don't have access
        // to its ID. For now cancelling all notifications and
        // then individually re-adding all of them. Definitely
        // needs improving
        
        notificationManager.cancelAllNotifications()
        
        for jobApplication in jobApplications {
            try await notificationManager.scheduleFollowUpNotification(jobApplication)
        }
    }
}

// MARK: JobsListLogic.State initialisers

public extension JobsListLogic.State {}

// MARK: - Queries

extension JobsListLogic {
    func updateQuery(jobApplications: FetchAll<JobApplication>, jobApplicationQuery: some SelectStatementOf<JobApplication>) async {
        await withErrorReporting {
            try await jobApplications.load(jobApplicationQuery, animation: .default)
        }
    }
}
