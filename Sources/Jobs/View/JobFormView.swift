//  Created by Muhammed Mahmood on 19/04/2025.

import ComposableArchitecture
import SwiftUI
import Theme

struct JobFormView: View {
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
                                .font(.headline)
                            DatePicker("", selection: $store.dateApplied, displayedComponents: .date)
                                .labelsHidden()
                        }

                        HStack(spacing: 8) {
                            Text("Status")
                                .font(.headline)
                            Picker("", selection: $store.status) {
                                ForEach(ApplicationStatus.allCases.filter { $0 != .archived }, id: \.self) { status in
                                    Text(status.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader("Notes")

                        TextEditor(text: $store.notes)
                            .padding(10)
                            .frame(minHeight: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(store.jobApplication == nil ? "Add Application" : "Edit Application")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        store.send(.onCancelButtonTapped)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        store.send(.onSaveButtonTappedValidation)
                    }
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.headline)
                }
            }

            TextField("", text: $text)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8)
                    .stroke(hasError && text.isEmpty ? Color.red : Color.gray.opacity(0.3), lineWidth: 1.5))

            if hasError, text.isEmpty {
                Text("This field is required")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

private struct SectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    JobFormView(
        store: Store(
            initialState: JobFormLogic.State(jobApplication: nil),
            reducer: { JobFormLogic() }
        )
    )
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
                    id: state.jobApplication?.id ?? 1,
                    title: state.title,
                    company: state.company,
                    createdAt: now,
                    dateApplied: state.dateApplied,
                    status: state.status.rawValue,
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
        self.status = ApplicationStatus.toApplicationStatus(from: jobApplication?.status ?? ApplicationStatus.applied.rawValue)
        self.notes = jobApplication?.notes ?? ""
    }
}
