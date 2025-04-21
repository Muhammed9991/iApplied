//  Created by Muhammed Mahmood on 19/04/2025.

import ComposableArchitecture
import SwiftUI
import Theme

@Reducer
struct JobFormLogic: Reducer {
    @ObservableState
    struct State: Equatable, Sendable {
        var originalJob: JobApplication?
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

struct JobFormView: View {
    @Environment(\.dismiss) private var dismiss

    private var originalJob: JobApplication?
    @State private var title: String
    @State private var company: String
    @State private var dateApplied: Date
    @State private var status: ApplicationStatus
    @State private var notes: String

    @State private var titleHasError: Bool = false
    @State private var companyHasError: Bool = false
    @State private var showValidationErrors: Bool = false

    private var onSave: (JobApplication?) -> Void

    init(job: JobApplication?, onSave: @escaping (JobApplication?) -> Void) {
        self.originalJob = job
        self.onSave = onSave
        _title = State(initialValue: job?.title ?? "")
        _company = State(initialValue: job?.company ?? "")
        _dateApplied = State(initialValue: job?.dateApplied ?? Date())
        _status = State(initialValue: ApplicationStatus.toApplicationStatus(from: job?.status ?? ApplicationStatus.applied.rawValue))
        _notes = State(initialValue: job?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionHeader("Job Details")

                    ValidatedTextField(title: "Job Title", text: $title, hasError: $titleHasError, isRequired: true)
                    ValidatedTextField(title: "Company", text: $company, hasError: $companyHasError, isRequired: true)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Text("Date Applied")
                                .font(.headline)
                            DatePicker("", selection: $dateApplied, displayedComponents: .date)
                                .labelsHidden()
                        }

                        HStack(spacing: 8) {
                            Text("Status")
                                .font(.headline)
                            Picker("", selection: $status) {
                                ForEach(ApplicationStatus.allCases.filter { $0 != .archived }, id: \.self) { status in
                                    Text(status.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader("Notes")

                        TextEditor(text: $notes)
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
            .navigationTitle(originalJob == nil ? "Add Application" : "Edit Application")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        titleHasError = title.isEmpty
                        companyHasError = company.isEmpty
                        showValidationErrors = true

                        guard !title.isEmpty, !company.isEmpty else { return }

                        let updatedJob = JobApplication(
                            id: originalJob?.id ?? 1,
                            title: title,
                            company: company,
                            dateApplied: dateApplied,
                            status: status.rawValue,
                            notes: notes.isEmpty ? nil : notes,
                            lastFollowUpDate: originalJob?.lastFollowUpDate
                        )
                        onSave(updatedJob)
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

#Preview {
    JobFormView(job: JobApplication.mock) { _ in }
}
