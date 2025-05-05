import AppDatabase
import ComposableArchitecture
@testable import CV
import Dependencies
import DependenciesTestSupport
@testable import Jobs
import Models
import Root
import SharingGRDB
import SharingGRDBCore
import SnapshotTesting
import StructuredQueries
import SwiftUI
import Testing
import Theme
import UIKit

@MainActor
@Suite(.dependency(\.defaultDatabase, try testDatabase()))
struct AppStoreSnapshotTests {
    // MARK: - Active Job List

    @Test
    func activeJobList_light_mode() async throws {
        let store = Store(
            initialState: JobsListLogic.State(),
            reducer: { JobsListLogic() }
        )
        
        try await store.$activeJobApplications.load(
            JobApplication
                .all
                .where { !$0.isArchived }
                .order { $0.dateApplied.desc() }
        )
        
        assertAppStoreDevicePreviewSnapshots(
            for: JobsListView(store: store),
            description: {
                Text("Easily view your active job applications").foregroundColor(Color.black.opacity(0.6))
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
        
        try await store.$activeJobApplications.load(
            JobApplication
                .all
                .where { !$0.isArchived }
                .order { $0.dateApplied.desc() }
        )
        
        assertAppStoreDevicePreviewSnapshots(
            for: JobsListView(store: store),
            description: {
                Text("Easily view your active job applications").foregroundColor(Color.white)
                    + Text("\n(With Dark Mode)")

            },
            backgroundColor: AppColors.accent(for: .dark),
            colorScheme: .dark
        )
    }
    
    // MARK: - Add Job
    
    // TODO: the background for JobForm needs to be modified
    func addJob_light_mode() async throws {
        let store = Store(
            initialState: JobFormLogic.State(
                jobApplication: .init(
                    title: "iOS Developer",
                    company: "Apple",
                    createdAt: .now,
                    dateApplied: .now,
                    status: "Applied"
                )
            ),
            reducer: { JobFormLogic() }
        )
        
        assertDeviceBottomSheetSnapshots(
            for: JobFormView(store: store),
            description: {
                Text("Easily add a job").foregroundColor(Color.black.opacity(0.6))
            },
            backgroundColor: AppColors.accent(for: .light),
            colorScheme: .light
        )
    }
    
    // TODO: the background for JobForm needs to be modified
    func addJob_dark_mode() async throws {
        let store = Store(
            initialState: JobFormLogic.State(
                jobApplication: .init(
                    title: "iOS Developer",
                    company: "Apple",
                    createdAt: .now,
                    dateApplied: .now,
                    status: "Applied"
                )
            ),
            reducer: { JobFormLogic() }
        )
        
        assertDeviceBottomSheetSnapshots(
            for: JobFormView(store: store),
            description: {
                Text("Easily add a job").foregroundColor(Color.white)
                    + Text("\n(With Dark Mode)")
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
                Text("Save your professional links").foregroundColor(Color.black.opacity(0.6)) + Text("\nCopy with one tap").foregroundColor(Color.black.opacity(0.6))
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
                Text("Save your professional links").foregroundColor(Color.white)
                    + Text("\nCopy with one tap").foregroundColor(Color.white)
                    + Text("\n(With Dark Mode)")
            },
            backgroundColor: AppColors.accent(for: .dark),
            colorScheme: .dark
        )
    }
}
