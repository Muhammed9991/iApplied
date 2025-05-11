import AppDatabase
import ComposableArchitecture
@testable import CV
import DependenciesTestSupport
@testable import Jobs
import Models
import StructuredQueries
import SwiftUI
import Testing
import Theme

@MainActor
@Suite(.dependency(\.defaultDatabase, try testDatabase()), .snapshots(record: .all))
struct AppStoreSnapshotTests {
    // MARK: - Active Job List

    @Test
    func activeJobList_light_mode() async throws {
        let store = Store(
            initialState: JobsListLogic.State(),
            reducer: { JobsListLogic() }
        )
        
        try await store.$jobApplications.load(
            JobApplication
                .all
                .where { !$0.isArchived }
                .order { $0.dateApplied.desc() }
        )
        
        assertAppStoreDevicePreviewSnapshots(
            for: JobsListView(store: store),
            description: {
                Text("Track every job application in one place").foregroundColor(Color.black.opacity(0.6))
            },
            backgroundColor: AppColors.accent(for: .light),
            colorScheme: .light
        )
    }
    
    @Test
    func activeJobList_dark_mode() async throws {
        let store = Store(
            initialState: JobsListLogic.State(),
            reducer: { JobsListLogic() }
        )
        
        try await store.$jobApplications.load(
            JobApplication
                .all
                .where { !$0.isArchived }
                .order { $0.dateApplied.desc() }
        )
        
        assertAppStoreDevicePreviewSnapshots(
            for: JobsListView(store: store),
            description: {
                Text("Track every job application in one place").foregroundColor(Color.white)
                    + Text("\nFully supports light and dark themes").foregroundColor(Color.white.opacity(0.8))
            },
            backgroundColor: AppColors.accent(for: .dark),
            colorScheme: .dark
        )
    }
    
    // MARK: - Add Job
    
    @Test
    func addJob_light_mode() async throws {
        let store = Store(
            initialState: JobFormLogic.State(
                jobApplication: .init(
                    title: "iOS Developer",
                    company: "Apple",
                    createdAt: .now,
                    dateApplied: .now,
                    status: .applied
                )
            ),
            reducer: { JobFormLogic() }
        )
        
        assertDeviceBottomSheetSnapshots(
            for: JobFormView(store: store),
            description: {
                Text("Log applications with all important details").foregroundColor(Color.black.opacity(0.6))
            },
            backgroundColor: AppColors.accent(for: .light),
            colorScheme: .light
        )
    }
    
    @Test
    func addJob_dark_mode() async throws {
        let store = Store(
            initialState: JobFormLogic.State(
                jobApplication: .init(
                    title: "iOS Developer",
                    company: "Apple",
                    createdAt: .now,
                    dateApplied: .now,
                    status: .applied
                )
            ),
            reducer: { JobFormLogic() }
        )
        
        assertDeviceBottomSheetSnapshots(
            for: JobFormView(store: store),
            description: {
                Text("Log applications with all important details").foregroundColor(Color.white)
                    + Text("\nEasy on the eyes with dark mode support").foregroundColor(Color.white.opacity(0.8))
            },
            backgroundColor: AppColors.accent(for: .dark),
            colorScheme: .dark
        )
    }

    // MARK: - Proffesional Links
    
    @Test
    func proffesionalLinks_light_mode() async throws {
        let store = Store(
            initialState: CVLogic.State(),
            reducer: { CVLogic() }
        )
        
        try await store.$professionalLinks.load(ProfessionalLink.all)
        
        assertAppStoreDevicePreviewSnapshots(
            for: CVTabView(store: store),
            description: {
                Text("Keep your professional profile links organised").foregroundColor(Color.black.opacity(0.6)) + Text("\nOne-tap copying for quick sharing").foregroundColor(Color.black.opacity(0.6))
            },
            backgroundColor: AppColors.accent(for: .light),
            colorScheme: .light
        )
    }
    
    @Test
    func proffesionalLinks_dark_mode() async throws {
        let store = Store(
            initialState: CVLogic.State(),
            reducer: { CVLogic() }
        )
        
        try await store.$professionalLinks.load(ProfessionalLink.all)
        
        assertAppStoreDevicePreviewSnapshots(
            for: CVTabView(store: store),
            description: {
                Text("Keep your professional profile links organised").foregroundColor(Color.white)
                    + Text("\nOne-tap copying for quick sharing").foregroundColor(Color.white)
                    + Text("\nAdapts to your preferred theme").foregroundColor(Color.white.opacity(0.8))
            },
            backgroundColor: AppColors.accent(for: .dark),
            colorScheme: .dark
        )
    }
}
