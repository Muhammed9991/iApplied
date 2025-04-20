//  Created by Muhammed Mahmood on 19/04/2025.

import SharingGRDB
import SwiftUI
import SwiftUINavigation
import Theme

@CasePathable
enum Destination {
    case confirmationDialog(String)
    case jobForm(JobApplication?)
}

public struct JobsListView: View {
    @SharedReader(.fetchAll(sql: "SELECT * FROM jobApplications")) var jobApplications: [JobApplication]
    
    @Dependency(\.defaultDatabase) var database

    @State private var viewMode: ViewMode = .compact
    @State private var isCompact: Bool = true
    @State private var jobApplication: JobApplication?
    @State var destination: Destination?
    enum ViewMode {
        case full
        case compact
    }
    
    public init() {}
    
    private func toggleViewMode() {
        viewMode = viewMode == .full ? .compact : .full
    }
    
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
            if jobApplications.firstIndex(where: { $0.id == job.id }) != nil {
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
        destination = .confirmationDialog("Are you sure you want to delete this job application?")
    }
    
    // MARK: - Main Body

    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if jobApplications.isEmpty {
                    emptyStateView
                } else {
                    jobListContent
                }
            }
            .onChange(of: viewMode) { _, newValue in
                isCompact = newValue == .compact
            }
            .navigationTitle("Applications")
            .toolbar {
                leadingToolbarItems
                trailingToolbarItems
            }
            .alert(item: $destination.confirmationDialog) { text in
                Text(text)
            } actions: { _ in
                deleteConfirmationButtons
            }
            .sheet(item: $destination.jobForm, id: \.self) { job in
                JobFormView(job: job) { savedJob in
                    if let savedJob {
                        saveJob(savedJob)
                    }
                    destination = nil
                }
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
            job: job,
            isCompact: $isCompact,
            onEdit: {
                jobApplication = job
                destination = .jobForm(job)
            },
            onDelete: {
                jobApplication = job
                destination = .confirmationDialog("Are you sure you want to delete this job application?")
            }
        )
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .contentShape(Rectangle())
        .onTapGesture {
            jobApplication = job
            destination = .jobForm(job)
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
                destination = .jobForm(job)
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
    
    private var deleteConfirmationButtons: some View {
        Group {
            Button("Delete", role: .destructive) {
                if let job = jobApplication {
                    withAnimation {
                        deleteJob(job)
                        destination = nil
                    }
                }
            }
            
            Button("Cancel", role: .cancel) {
                destination = nil
            }
        }
    }
    
    private var leadingToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                toggleViewMode()
            } label: {
                Image(systemName: viewMode == .full ? "list.bullet" : "rectangle.grid.1x2")
            }
        }
    }
    
    private var trailingToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                destination = .jobForm(jobApplication)
            } label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var activeJobs: [JobApplication] {
        jobApplications.filter { $0.status != ApplicationStatus.archived.rawValue }
    }
    
    private var archivedJobs: [JobApplication] {
        jobApplications.filter { $0.status == ApplicationStatus.archived.rawValue }
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
            destination = .jobForm(jobApplication)
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
    JobsListView()
}
