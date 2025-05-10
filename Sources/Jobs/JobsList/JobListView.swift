import AppDatabase
import ComposableArchitecture
import Models
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
                
                VStack(spacing: 0) {
                    // Fixed tab selection view at the top
                    tabSelectionView
                        .padding(.bottom, 8)
                    
                    if (store.selectedTab == .active && store.activeJobApplications.isEmpty) ||
                        (store.selectedTab == .archived && store.archivedJobApplications.isEmpty)
                    {
                        emptyStateView
                    } else {
                        jobListContent
                    }
                    
                    Spacer(minLength: 0)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
    
    private var tabSelectionView: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                VStack(spacing: 8) {
                    HStack(spacing: 0) {
                        tabButton(for: .active)
                        tabButton(for: .archived)
                    }
                    
                    // Animated sliding underline
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(AppColors.accent(for: colorScheme))
                            .frame(width: geometry.size.width / 2, height: 3)
                            .cornerRadius(1.5)
                            .offset(x: store.selectedTab == .active ? 0 : geometry.size.width / 2)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: store.selectedTab)
                    }
                    .frame(height: 3)
                }
            }
            .padding(.horizontal)
            
            Divider()
                .background(AppColors.textSecondary(for: colorScheme).opacity(0.3))
        }
        .background(
            Rectangle()
                .fill(AppColors.background(for: colorScheme))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    private func tabButton(for tab: JobsListLogic.State.Tab) -> some View {
        Button {
            store.send(.binding(.set(\.selectedTab, tab)), animation: .spring(response: 0.3, dampingFraction: 0.7))
        } label: {
            VStack(spacing: 8) {
                Text(tab == .active ? "Active" : "Archived")
                    .font(AppTypography.subtitle)
                    .foregroundColor(store.selectedTab == tab
                        ? AppColors.accent(for: colorScheme)
                        : AppColors.primary(for: colorScheme).opacity(0.6))
                    .fontWeight(store.selectedTab == tab ? .semibold : .regular)
                    .padding(.bottom, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
    
    private var jobListContent: some View {
        List {
            if store.selectedTab == .active {
                activeJobsSection
            } else {
                archivedJobsSection
            }
        }
        .padding(.horizontal)
        .padding(.top, 8) // Add top padding to separate from tab bar
        .listStyle(.plain)
        .background(AppColors.background(for: colorScheme))
    }
    
    private var activeJobsSection: some View {
        ForEach(store.activeJobApplications) { job in
            jobCardView(for: job)
        }
    }
    
    private var archivedJobsSection: some View {
        ForEach(store.archivedJobApplications) { job in
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
            leadingSwipeAction(for: job, isArchived: job.isArchived)
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
            store.send(isArchived ? .unArchiveJob(job: job) : .archiveJob(job: job), animation: jobAnimation)
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
        Group {
            if (store.selectedTab == .active && !store.activeJobApplications.isEmpty) ||
                (store.selectedTab == .archived && !store.archivedJobApplications.isEmpty)
            {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        store.isCompact.toggle()
                    } label: {
                        Image(systemName: store.isCompact ? "rectangle.grid.1x2" : "list.bullet")
                    }
                }
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
            Spacer()
            
            Image(systemName: store.selectedTab == .active ? "doc.text.magnifyingglass" : "archivebox")
                .font(.system(size: 70))
                .foregroundColor(AppColors.accent(for: colorScheme))
            
            Text(store.selectedTab == .active ? "No Active Job Applications" : "No Archived Applications")
                .font(AppTypography.title)
                .foregroundColor(AppColors.primary(for: colorScheme))
            
            Text(store.selectedTab == .active ? "Tap + to add your first job application" : "Archived applications will appear here")
                .font(AppTypography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if store.selectedTab == .active {
                addApplicationButton
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        $0.defaultDatabase = try AppDatabase.appDatabase()
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
