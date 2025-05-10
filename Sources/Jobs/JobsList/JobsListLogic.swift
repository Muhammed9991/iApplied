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

@Reducer
public struct JobsListLogic: Reducer, Sendable {
    public init() {}
    
    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    public enum Destination {
        case jobForm(JobFormLogic)
    }
    
    @Selection
    struct JobApplicationStatusCounts: QueryRepresentable, Equatable, Sendable {
        var appliedCount: Int
        var interviewCount: Int
        var offerCount: Int
        var declinedCount: Int
        var activeCount: Int
        var archivedCount: Int
        
        func countForFilter(_ filterType: FilterType) -> Int {
            switch filterType {
            case .all:
                appliedCount + interviewCount + offerCount + declinedCount
            case .applied:
                appliedCount
            case .interview:
                interviewCount
            case .offer:
                offerCount
            case .declined:
                declinedCount
            }
        }
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @ObservationStateIgnored
        @FetchAll(
            JobApplication
                .all
                .where { !$0.isArchived }
                .order { $0.dateApplied.desc() }
        )
        var activeJobApplications
        
        @ObservationStateIgnored
        @FetchAll(
            JobApplication
                .all
                .where(\.isArchived)
                .order { $0.dateApplied.desc() }
        )
        var archivedJobApplications
        
        @ObservationStateIgnored
        @FetchOne(
            wrappedValue: nil,
            #sql("""
            SELECT 
            COUNT(CASE WHEN status = 'Applied' THEN 1 END) AS appliedCount,
            COUNT(CASE WHEN status = 'Interview' THEN 1 END) AS interviewCount,
            COUNT(CASE WHEN status = 'Offer' THEN 1 END) AS offerCount,
            COUNT(CASE WHEN status = 'Declined' THEN 1 END) AS declinedCount,
            
            COUNT(CASE WHEN isArchived = 0 THEN 1 END) AS activeCount,
            COUNT(CASE WHEN isArchived = 1 THEN 1 END) AS archivedCount
            FROM jobApplications
            """, as: JobApplicationStatusCounts?.self)
        )
        var jobApplicationStatusCounts: JobApplicationStatusCounts?

        var selectedTab: Tab = .active
        @Shared(.isCompact) var isCompact: Bool = false
        var jobApplication: JobApplication?
        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<Action.Alert>?
        var activeFilter: FilterType? = .all

        public enum Tab: Equatable, Sendable {
            case active
            case archived
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
            case .alert(.presented(.confirmDeleteJob)):
                state.alert = nil
                return .run { [jobApplication = state.jobApplication] _ in
                    precondition(jobApplication != nil, "How can this even be nil at this point?")
                    try database.write { db in
                        try JobApplication.delete(jobApplication!).execute(db)
                    }
                    
                    if let id = jobApplication?.id {
                        notificationManager.cancelNotification("\(id)")
                    }
                }
                
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
                    
                    try await database.write { db in
                        var updatedJob = job
                        updatedJob.status = status
                        try JobApplication.update(updatedJob).execute(db)
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
                    
                    try await database.write { db in
                        var updatedJob = job
                        updatedJob.isArchived = true
                        try JobApplication.update(updatedJob).execute(db)
                    }
                    
                    if let id = job.id {
                        notificationManager.cancelNotification("\(id)")
                    }
                }
                
            case let .unArchiveJob(job: job):
                return .run { _ in
                    try await database.write { db in
                        var updatedJob = job
                        updatedJob.isArchived = false
                        try JobApplication.update(updatedJob).execute(db)
                    }
                    
                    if job.status == ApplicationStatus.applied {
                        try await notificationManager.scheduleFollowUpNotification(job)
                    }
                }
                
            case let .destination(.presented(.jobForm(.delegate(.onSaveButtonTapped(job))))):
                
                return .run { [jobApplications = state.activeJobApplications] _ in
                    
                    guard jobApplications.firstIndex(where: { $0.id == job.id }) != nil else {
                        // Add new job
                        try await database.write { db in
                            try JobApplication.insert(job).execute(db)
                        }
                        try await rescheduleAllNotifications(jobApplications: jobApplications)
                        return
                    }
                    
                    // Update existing job
                    try await database.write { db in
                        try JobApplication.update(job).execute(db)
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

public extension JobsListLogic.State {
    init(
        jobApplication: JobApplication? = nil,
        destination: JobsListLogic.Destination.State? = nil,
        alert: AlertState<JobsListLogic.Action.Alert>? = nil,
        selectedTab: Tab = .active
    ) {
        self.jobApplication = jobApplication
        self.destination = destination
        self.alert = alert
        self.selectedTab = selectedTab
    }
}
