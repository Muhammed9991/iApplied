//  Created by Muhammed Mahmood on 19/04/2025.

import SwiftUI
import Theme

enum ViewMode {
    case full
    case compact
}

public struct JobsListView: View {
    @State private var jobApplications: [JobApplication] = [.mock]
    @State private var viewMode: ViewMode = .compact
    @State private var isCompact: Bool = true
    @State private var showingAddSheet = false
    @State private var editingJob: JobApplication?
    @State private var confirmingDelete: JobApplication?
    
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
            if let index = jobApplications.firstIndex(where: { $0.id == job.id }) {
                var updatedJob = job
                updatedJob.status = status
                jobApplications[index] = updatedJob
            }
        }
    }
    
    private func deleteJob(_ job: JobApplication) {
        withAnimation(jobAnimation) {
            jobApplications.removeAll { $0.id == job.id }
        }
    }
    
    private func archiveJob(_ job: JobApplication) {
        updateJobStatus(job, to: .archived)
    }
    
    private func restoreJob(_ job: JobApplication) {
        updateJobStatus(job, to: .applied)
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
            .confirmationDialog(
                "Are you sure you want to delete this job application?",
                isPresented: .constant(confirmingDelete != nil),
                titleVisibility: .visible
            ) {
                deleteConfirmationButtons
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
            onEdit: { editingJob = job },
            onDelete: { confirmingDelete = job }
        )
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .contentShape(Rectangle())
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
                confirmingDelete = job
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                editingJob = job
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
                if let job = confirmingDelete {
                    withAnimation {
                        deleteJob(job)
                        confirmingDelete = nil
                    }
                }
            }
            
            Button("Cancel", role: .cancel) {
                confirmingDelete = nil
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
            Button(action: {
                showingAddSheet = true
            }) {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var activeJobs: [JobApplication] {
        jobApplications.filter { $0.status != .archived }
    }
    
    private var archivedJobs: [JobApplication] {
        jobApplications.filter { $0.status == .archived }
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
        Button(action: {
            showingAddSheet = true
        }) {
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
