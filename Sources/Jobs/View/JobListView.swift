//  Created by Muhammed Mahmood on 19/04/2025.

import SwiftUI
import Theme

enum ViewMode {
    case full
    case compact
}

public struct JobsListView: View {
    @State var jobApplications: [JobApplication] = [.mock]
    @State var viewMode: ViewMode = .compact
    @State var isCompact: Bool = true
    @State private var showingAddSheet = false
    @State private var editingJob: JobApplication?
    @State private var confirmingDelete: JobApplication?
    
    public init() {}
    
    func toggleViewMode() {
        viewMode = viewMode == .full ? .compact : .full
    }
    
    func deleteJob(_ job: JobApplication) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            jobApplications.removeAll { $0.id == job.id }
        }
    }
    
    func archiveJob(_ job: JobApplication) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let index = jobApplications.firstIndex(where: { $0.id == job.id }) {
                var updatedJob = job
                updatedJob.status = .archived
                jobApplications[index] = updatedJob
            }
        }
    }
    
    func restoreJob(_ job: JobApplication) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let index = jobApplications.firstIndex(where: { $0.id == job.id }) {
                var updatedJob = job
                updatedJob.status = .applied // Restore to "Applied" status
                jobApplications[index] = updatedJob
            }
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if jobApplications.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(jobApplications.filter { $0.status != .archived }) { job in
                            JobCardView(
                                job: job,
                                isCompact: $isCompact,
                                onEdit: { editingJob = job },
                                onDelete: {
                                    confirmingDelete = job
                                }
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .contentShape(Rectangle())
                            .transition(.opacity.combined(with: .scale(scale: 0.9)).combined(with: .move(edge: .trailing)))
                            .id(job.id)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
                            .swipeActions(edge: .leading) {
                                Button {
                                    archiveJob(job)
                                } label: {
                                    Label("Archive", systemImage: "archivebox")
                                }
                                .tint(.gray)
                            }
                        }
                        
                        // Archived section
                        if !jobApplications.filter({ $0.status == .archived }).isEmpty {
                            Section(header:
                                Text("Archived Applications")
                                    .font(AppTypography.title)
                                    .foregroundColor(AppColors.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 20)
                            ) {
                                ForEach(jobApplications.filter { $0.status == .archived }) { job in
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
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            restoreJob(job)
                                        } label: {
                                            Label("Restore", systemImage: "arrow.uturn.left")
                                        }
                                        .tint(.blue)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .listStyle(.plain)
                    .background(AppColors.background)
                }
            }
            .onChange(of: viewMode) { _, newValue in
                isCompact = newValue == .compact
            }
            .navigationTitle("Applications")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        toggleViewMode()
                    } label: {
                        Image(systemName: viewMode == .full ? "list.bullet" : "rectangle.grid.1x2")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete this job application?",
                isPresented: .constant(confirmingDelete != nil),
                titleVisibility: .visible
            ) {
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
        .padding()
    }
}

// Preview
#Preview {
    JobsListView()
}
