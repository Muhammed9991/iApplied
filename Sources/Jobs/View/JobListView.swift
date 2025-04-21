//  Created by Muhammed Mahmood on 19/04/2025.

import ComposableArchitecture
import SharingGRDB
import SwiftUI
import SwiftUINavigation
import Theme

public struct JobsListView: View {
    @Bindable var store: StoreOf<JobsListLogic>
    
    @Dependency(\.defaultDatabase) var database
    
    /// Animation configuration used across job-related actions
    private var jobAnimation: Animation {
        .spring(response: 0.4, dampingFraction: 0.8)
    }
    
    private func updateJobStatus(_ job: JobApplication, to status: ApplicationStatus) {
        withAnimation(jobAnimation) {
            var updatedJob = job
            updatedJob.status = status.rawValue
            do {
                try database.write { db in
                    try updatedJob.update(db)
                }
            } catch {
                print("Failed to update job status in database")
            }
        }
    }
    
    private func saveJob(_ job: JobApplication) {
        withAnimation(jobAnimation) {
            if store.jobApplications.firstIndex(where: { $0.id == job.id }) != nil {
                // Update existing job
                do {
                    try database.write { db in
                        try job.update(db)
                    }
                } catch {
                    print("Failed to update job in database")
                }
            } else {
                // Add new job
                do {
                    var newJob = job
                    try database.write { db in
                        try newJob.insert(db)
                    }
                } catch {
                    print("Failed to insert new job to database")
                }
            }
        }
    }
    
    private func deleteJob(_ job: JobApplication) {
        withAnimation(jobAnimation) {
            do {
                _ = try database.write { db in
                    try job.delete(db)
                }
            } catch {
                print("Failed to delete job in database")
            }
        }
    }
    
    private func archiveJob(_ job: JobApplication) {
        updateJobStatus(job, to: .archived)
    }
    
    private func restoreJob(_ job: JobApplication) {
        updateJobStatus(job, to: .applied)
    }
    
    private func setDeleteJobConfirmationDialog() {
//        destination = .confirmationDialog("Are you sure you want to delete this job application?")
    }
    
    // MARK: - Main Body

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if store.jobApplications.isEmpty {
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
                JobFormView(
                    store: store,
                    onSave: { savedJob in
                        if let savedJob {
                            saveJob(savedJob)
                        }
                    }
                )
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
            
            // Archived job applications
            if hasArchivedJobs {
                archivedJobsSection
            }
        }
        .padding(.horizontal)
        .listStyle(.plain)
        .background(AppColors.background)
    }
    
    private var activeJobsSection: some View {
        ForEach(activeJobs) { job in
            jobCardView(for: job, isArchived: false)
        }
    }
    
    private var archivedJobsSection: some View {
        Section(header: archivedSectionHeader) {
            ForEach(archivedJobs) { job in
                jobCardView(for: job, isArchived: true)
            }
        }
    }
    
    private var archivedSectionHeader: some View {
        Text("Archived Applications")
            .font(AppTypography.title)
            .foregroundColor(AppColors.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
    }
    
    private func jobCardView(for job: JobApplication, isArchived: Bool) -> some View {
        JobCardView(
            store: Store(
                initialState: JobCardLogic.State(
                    job: job,
                    isCompact: store.isCompact
                ),
                reducer: { JobCardLogic() }
            ),
            onEdit: {
                store.send(.onEditButtonTapped(job))
            },
            onDelete: {
                store.send(.onDeleteButtonTapped(job))
            }
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
            leadingSwipeAction(for: job, isArchived: isArchived)
        }
    }
    
    private func trailingSwipeActions(for job: JobApplication) -> some View {
        Group {
            Button(role: .destructive) {
                setDeleteJobConfirmationDialog()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                store.send(.onEditButtonTapped(job))
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(AppColors.accent)
        }
    }
    
    private func leadingSwipeAction(for job: JobApplication, isArchived: Bool) -> some View {
        Group {
            if isArchived {
                Button {
                    restoreJob(job)
                } label: {
                    Label("Restore", systemImage: "arrow.uturn.left")
                }
                .tint(.blue)
            } else {
                Button {
                    archiveJob(job)
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                .tint(.gray)
            }
        }
    }
    
    private var leadingToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                store.send(.toggleViewMode)
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
    
    private var activeJobs: [JobApplication] {
        store.jobApplications.filter { $0.status != ApplicationStatus.archived.rawValue }
    }
    
    private var archivedJobs: [JobApplication] {
        store.jobApplications.filter { $0.status == ApplicationStatus.archived.rawValue }
    }
    
    private var hasArchivedJobs: Bool {
        !archivedJobs.isEmpty
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 70))
                .foregroundColor(AppColors.accent)
            
            Text("No Job Applications Yet")
                .font(AppTypography.title)
                .foregroundColor(AppColors.primary)
            
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
                .background(AppColors.accent)
                .cornerRadius(10)
        }
        .padding(.top, 10)
    }
}

// MARK: - Preview

#Preview {
    JobsListView(
        store: Store(
            initialState: JobsListLogic.State(),
            reducer: { JobsListLogic() }
        )
    )
}

// MARK: - Reducer

@Reducer
struct JobsListLogic: Reducer {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case jobForm(JobFormLogic)
    }
    
    @ObservableState
    struct State: Equatable, Sendable {
        @SharedReader(.fetchAll(sql: "SELECT * FROM jobApplications")) var jobApplications: [JobApplication]
        var isCompact: Bool = true
        var jobApplication: JobApplication?
        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<Action.Alert>?
        
        var viewMode: ViewMode = .compact
        enum ViewMode: Equatable, Sendable {
            case full
            case compact
        }
    }

    enum Action: Equatable, Sendable, BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case toggleViewMode
        case onEditButtonTapped(JobApplication)
        case onAddApplicationTapped
        case onDeleteButtonTapped(JobApplication)
        
        case alert(PresentationAction<Alert>)
        @CasePathable
        enum Alert {
            case confirmDeleteJob
        }
    }
    
    @Dependency(\.defaultDatabase) var database

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .alert(.presented(.confirmDeleteJob)):
                state.alert = nil
                // TODO: Delete job
                return .none
                
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
                
            case .binding, .destination, .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
}
