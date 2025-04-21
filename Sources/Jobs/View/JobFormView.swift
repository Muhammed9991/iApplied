//  Created by Muhammed Mahmood on 19/04/2025.

import ComposableArchitecture
import SwiftUI
import Theme

struct JobFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: StoreOf<JobFormLogic>
    var onSave: (JobApplication?) -> Void

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
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        store.titleHasError = store.title.isEmpty
                        store.companyHasError = store.company.isEmpty
                        store.showValidationErrors = true

                        guard !store.title.isEmpty, !store.company.isEmpty else { return }

                        let updatedJob = JobApplication(
                            id: store.jobApplication?.id ?? 1,
                            title: store.title,
                            company: store.company,
                            dateApplied: store.dateApplied,
                            status: store.status.rawValue,
                            notes: store.notes.isEmpty ? nil : store.notes,
                            lastFollowUpDate: store.jobApplication?.lastFollowUpDate
                        )
                        onSave(updatedJob)
                        dismiss()
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
        ),
        onSave: { _ in }
    )
}

// MARK: - Reducer

@Reducer
struct JobFormLogic: Reducer {
    @ObservableState
    struct State: Equatable, Sendable {
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

    enum Action: Equatable, Sendable, BindableAction {
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce<State, Action> { _, action in
            switch action {
            case .binding:
                .none
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
