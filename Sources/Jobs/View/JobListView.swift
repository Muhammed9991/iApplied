//  Created by Muhammed Mahmood on 19/04/2025.

import ComposableArchitecture
import SharingGRDB
import SwiftUI
import SwiftUINavigation
import Theme

public struct JobsListView: View {
    @Bindable var store: StoreOf<JobsListLogic>
    @Environment(\.colorScheme) var colorScheme
    
    public init(store: StoreOf<JobsListLogic>) {
        self.store = store
    }
        
    /// Animation configuration used across job-related actions
    private var jobAnimation: Animation {
        .interactiveSpring(duration: 0.3, extraBounce: 0.3, blendDuration: 0.8)
    }
    
    // MARK: - Main Body

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                if store.activeJobApplications.isEmpty {
                    emptyStateView
                } else {
                    jobListContent
                }
            }
            .navigationTitle("Applications")
            .toolbar {
                leadingToolbarItems
                trailingToolbarItems
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .sheet(item: $store.scope(state: \.destination?.jobForm, action: \.destination.jobForm)) { store in
                JobFormView(store: store)
                    .interactiveDismissDisabled()
            }
        }
    }
    
    // MARK: - View Components
    
    /// List with all job applications
    private var jobListContent: some View {
        List {
            // Active job applications
            activeJobsSection
        }
        .padding(.horizontal)
        .listStyle(.plain)
        .background(AppColors.background(for: colorScheme))
    }
    
    private var activeJobsSection: some View {
        ForEach(store.activeJobApplications) { job in
            jobCardView(for: job)
        }
    }
    
    private func jobCardView(for job: JobApplication) -> some View {
        JobCardView(
            store: Store(
                initialState: JobCardLogic.State(
                    job: job,
                    isCompact: store.isCompact
                ),
                reducer: { JobCardLogic() }
            )
        )
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .contentShape(Rectangle())
        .onTapGesture {
            store.send(.onEditButtonTapped(job))
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)).combined(with: .move(edge: .trailing)))
        .id(job.id)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            trailingSwipeActions(for: job)
        }
        .swipeActions(edge: .leading) {
            leadingSwipeAction(for: job, isArchived: job.status == ApplicationStatus.archived.rawValue)
        }
    }
    
    private func trailingSwipeActions(for job: JobApplication) -> some View {
        Group {
            Button(role: .destructive) {
                store.send(.onDeleteButtonTapped(job))
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                store.send(.onEditButtonTapped(job))
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(AppColors.accent(for: colorScheme))
        }
    }
    
    private func leadingSwipeAction(for job: JobApplication, isArchived: Bool) -> some View {
        Button {
            store.send(.updateJobStatus(job: job, status: isArchived ? .applied : .archived), animation: jobAnimation)
        } label: {
            if isArchived {
                Label("Restore", systemImage: "arrow.uturn.left")
            } else {
                Label("Archive", systemImage: "archivebox")
            }
        }
        .tint(isArchived ? .blue : .gray)
    }
    
    private var leadingToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                store.send(.toggleViewMode, animation: jobAnimation)
            } label: {
                Image(systemName: store.viewMode == .full ? "list.bullet" : "rectangle.grid.1x2")
            }
        }
    }
    
    private var trailingToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                store.send(.onAddApplicationTapped)
            } label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 70))
                .foregroundColor(AppColors.accent(for: colorScheme))
            
            Text("No Job Applications Yet")
                .font(AppTypography.title)
                .foregroundColor(AppColors.primary(for: colorScheme))
            
            Text("Tap + to add your first job application")
                .font(AppTypography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            addApplicationButton
        }
        .padding()
    }
    
    private var addApplicationButton: some View {
        Button {
            store.send(.onAddApplicationTapped)
        } label: {
            Text("Add Application")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(AppColors.accent(for: colorScheme))
                .cornerRadius(10)
        }
        .padding(.top, 10)
    }
}

// MARK: - Preview

#Preview {
    _ = try! prepareDependencies {
        $0.defaultDatabase = try appDatabase()
    }
    
    return NavigationStack {
        JobsListView(
            store: Store(
                initialState: JobsListLogic.State(),
                reducer: { JobsListLogic() }
            )
        )
    }
}

// MARK: - Reducer

@Reducer
public struct JobsListLogic: Reducer, Sendable {
    public init() {}
    
    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    public enum Destination {
        case jobForm(JobFormLogic)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @ObservationStateIgnored
        @FetchAll(
            JobApplication
                .all
                .where { $0.status != ApplicationStatus.archived.rawValue }
                .order { $0.dateApplied.desc() }
        )
        var activeJobApplications
        
        var isCompact: Bool = true
        var jobApplication: JobApplication?
        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<Action.Alert>?
        
        var viewMode: ViewMode = .compact
        public enum ViewMode: Equatable, Sendable {
            case full
            case compact
        }
    }

    public enum Action: Equatable, Sendable, BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case toggleViewMode
        case onEditButtonTapped(JobApplication)
        case onAddApplicationTapped
        case onDeleteButtonTapped(JobApplication)
        case updateJobStatus(job: JobApplication, status: ApplicationStatus)
        case saveJob(job: JobApplication)
        case scheduleNotification(JobApplication)
        
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
                        try JobApplication.delete().execute(db)
                    }
                    
                    if let id = jobApplication?.id {
                        notificationManager.cancelNotification("\(id)")
                    }
                }
                
            case .toggleViewMode:
                state.viewMode = state.viewMode == .full ? .compact : .full
                state.isCompact = state.viewMode == .compact
                return .none
                
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
                        updatedJob.status = status.rawValue
                        try JobApplication.update(updatedJob).execute(db)
                    }
                    
                    if let id = job.id, status == .declined || status == .archived {
                        notificationManager.cancelNotification("\(id)")
                    }
                    
                    let wasArchived = job.status == ApplicationStatus.archived.rawValue
                    
                    if wasArchived { try await notificationManager.scheduleFollowUpNotification(job) }
                }
                
            case let .saveJob(job: job):
                return .run { [jobApplications = state.activeJobApplications] send in
                    
                    guard jobApplications.firstIndex(where: { $0.id == job.id }) != nil else {
                        // Add new job
                        try await database.write { db in
                            try JobApplication.insert(job).execute(db)
                        }
                        await send(.scheduleNotification(job))
                        return
                    }
                    
                    // Update existing job
                    try await database.write { db in
                        try JobApplication.update(job).execute(db)
                    }
                    await send(.scheduleNotification(job))
                }
                
            case let .scheduleNotification(jobApplication):
                return .run { _ in
                    try await notificationManager.scheduleFollowUpNotification(jobApplication)
                }
                
            case let .destination(.presented(.jobForm(.delegate(.onSaveButtonTapped(job))))):
                
                return .send(.saveJob(job: job))
                
            case .binding, .destination, .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: JobsListLogic.State initialisers

public extension JobsListLogic.State {
    init(
        isCompact: Bool = true,
        jobApplication: JobApplication? = nil,
        destination: JobsListLogic.Destination.State? = nil,
        alert: AlertState<JobsListLogic.Action.Alert>? = nil,
        viewMode: ViewMode = .compact
    ) {
        self.isCompact = isCompact
        self.jobApplication = jobApplication
        self.destination = destination
        self.alert = alert
        self.viewMode = viewMode
    }
}
