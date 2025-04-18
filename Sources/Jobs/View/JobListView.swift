//  Created by Muhammed Mahmood on 19/04/2025.

import SwiftUI
import Theme

enum ViewMode {
    case full
    case compact
}

public struct JobsListView: View {
    @State var jobApplications: [JobApplication] = []
    @State var viewMode: ViewMode = .compact
    @State private var showingAddSheet = false
    @State private var editingJob: JobApplication?
    @State private var confirmingDelete: JobApplication?
    
    public init() {}
    
    func toggleViewMode() {
        viewMode = viewMode == .full ? .compact : .full
    }
    
    func deleteJob(_ job: JobApplication) {
        jobApplications.removeAll { $0.id == job.id }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if jobApplications.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(jobApplications.filter { $0.status != .archived }) { job in
                                JobCardView(
                                    job: job,
                                    isCompact: viewMode == .compact,
                                    onEdit: { editingJob = job },
                                    onDelete: {
                                        confirmingDelete = job
                                    }
                                )
                            }
                            
                            // TODO: needs to show an archive button which shows you previously applied jobs
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
                                            isCompact: viewMode == .compact,
                                            onEdit: { editingJob = job },
                                            onDelete: { confirmingDelete = job }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
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
