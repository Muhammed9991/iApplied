//  Created by Muhammed Mahmood on 19/04/2025.

import ComposableArchitecture
import Models
import SwiftUI
import Theme

struct JobFormView: View {
    @Environment(\.colorScheme) var colorScheme
    @Bindable var store: StoreOf<JobFormLogic>

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionHeader("Job Details")

                    ValidatedTextField(title: "Job Title", text: $store.title, hasError: $store.titleHasError, isRequired: true)
                    ValidatedTextField(title: "Company", text: $store.company, hasError: $store.companyHasError, isRequired: true)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Text("Date Applied")
                                .font(AppTypography.subtitle)
                                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                            DatePicker("", selection: $store.dateApplied, displayedComponents: .date)
                                .labelsHidden()
                                .accentColor(AppColors.accent(for: colorScheme))
                        }

                        HStack(spacing: 8) {
                            Text("Status")
                                .font(AppTypography.subtitle)
                                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                            Picker("", selection: $store.status) {
                                ForEach(ApplicationStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(AppColors.accent(for: colorScheme))
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader("Notes")

                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.cardBackground(for: colorScheme))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.textSecondary(for: colorScheme).opacity(0.3), lineWidth: 1.5)
                                )

                            AutoSizingTextEditor(text: $store.notes, height: $store.dynamicHeight)
                                .frame(height: store.dynamicHeight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                        }
                    }
                }
                .padding(.horizontal)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppColors.background(for: colorScheme))
            .navigationTitle(store.jobApplication == nil ? "Add Application" : "Edit Application")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        store.send(.onCancelButtonTapped)
                    }
                    .foregroundColor(AppColors.accent(for: colorScheme))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        store.send(.onSaveButtonTappedValidation)
                    }
                    .foregroundColor(AppColors.accent(for: colorScheme))
                }
            }
        }
    }
}

private struct ValidatedTextField: View {
    let title: String
    @Binding var text: String
    @Binding var hasError: Bool
    let isRequired: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(AppTypography.subtitle)
                    .foregroundColor(AppColors.textPrimary(for: colorScheme))
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                        .font(AppTypography.subtitle)
                }
            }

            TextField("", text: $text)
                .padding()
                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                .background(RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.cardBackground(for: colorScheme)))
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(hasError && text.isEmpty ? Color.red : AppColors.textSecondary(for: colorScheme).opacity(0.3), lineWidth: 1.5))

            if hasError, text.isEmpty {
                Text("This field is required")
                    .foregroundColor(.red)
                    .font(AppTypography.caption)
            }
        }
    }
}

private struct SectionHeader: View {
    let title: String
    @Environment(\.colorScheme) var colorScheme

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title.uppercased())
            .font(AppTypography.caption)
            .fontWeight(.semibold)
            .foregroundColor(AppColors.textSecondary(for: colorScheme))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    JobFormView(
        store: Store(
            initialState: JobFormLogic.State(jobApplication: nil),
            reducer: { JobFormLogic() }
        )
    )
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    JobFormView(
        store: Store(
            initialState: JobFormLogic.State(jobApplication: nil),
            reducer: { JobFormLogic() }
        )
    )
    .preferredColorScheme(.dark)
}

// MARK: - Reducer

@Reducer
public struct JobFormLogic: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        var jobApplication: JobApplication?
        var title: String
        var company: String
        var dateApplied: Date
        var status: ApplicationStatus
        var notes: String

        var titleHasError: Bool = false
        var companyHasError: Bool = false
        var showValidationErrors: Bool = false
        var dynamicHeight: CGFloat = 100
    }

    public enum Action: Equatable, Sendable, BindableAction {
        case binding(BindingAction<State>)
        case onSaveButtonTappedValidation
        case onCancelButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case onSaveButtonTapped(JobApplication)
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.date.now) var now

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .onCancelButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case .onSaveButtonTappedValidation:
                state.titleHasError = state.title.isEmpty
                state.companyHasError = state.company.isEmpty
                state.showValidationErrors = true

                guard !state.title.isEmpty, !state.company.isEmpty else { return .none }

                let job = JobApplication(
                    id: state.jobApplication?.id,
                    title: state.title,
                    company: state.company,
                    createdAt: state.jobApplication?.createdAt ?? now,
                    dateApplied: state.dateApplied,
                    status: state.status,
                    notes: state.notes.isEmpty ? nil : state.notes,
                    lastFollowUpDate: state.jobApplication?.lastFollowUpDate
                )

                return .run { send in
                    await send(
                        .delegate(.onSaveButtonTapped(job)),
                        animation: .interactiveSpring(duration: 0.3, extraBounce: 0.3, blendDuration: 0.8)
                    )
                    await dismiss()
                }

            case .binding, .delegate:
                return .none
            }
        }
    }
}

extension JobFormLogic.State {
    init(jobApplication: JobApplication? = nil) {
        self.jobApplication = jobApplication
        self.title = jobApplication?.title ?? ""
        self.company = jobApplication?.company ?? ""
        self.dateApplied = jobApplication?.dateApplied ?? Date()
        self.status = jobApplication?.status ?? ApplicationStatus.applied
        self.notes = jobApplication?.notes ?? ""
    }
}
