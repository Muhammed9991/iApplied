//  Created by Muhammed Mahmood on 27/04/2025.
import SwiftUI

enum TextFieldError: Equatable, Sendable {
    case requiredField
    case custom(message: String)
}

struct ValidatedTextField: View {
    let title: String
    @Binding var text: String
    @Binding var error: TextFieldError?
    let isRequired: Bool

    // Optional configurations
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var autocorrectionDisabled: Bool = false

    var body: some View {
        let showError = error != nil

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

            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(autocorrectionDisabled)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showError ? Color.red : Color.gray.opacity(0.3), lineWidth: 1.5)
                )

            if let error {
                Text(errorMessage(for: error))
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    private func errorMessage(for error: TextFieldError) -> String {
        switch error {
        case .requiredField:
            "This field is required"
        case .custom(let message):
            message
        }
    }
}
