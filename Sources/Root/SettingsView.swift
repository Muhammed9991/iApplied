//  Created by Muhammed Mahmood on 03/05/2025.

import SwiftUI
import Theme

private var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
}

private var buildNumber: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
}

public struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showingAcknowledgements = false

    public init() {}

    public var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        showingAcknowledgements = true
                    } label: {
                        HStack {
                            Text("Acknowledgements")
                                .foregroundColor(AppColors.textPrimary(for: colorScheme))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textSecondary(for: colorScheme))
                        }
                    }
                    .sheet(isPresented: $showingAcknowledgements) {
                        AcknowledgementsView()
                    }
                }

                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(AppColors.textPrimary(for: colorScheme))
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .background(AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all))
        }
    }
}

struct AcknowledgementsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var packages: [Package] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accent(for: colorScheme)))
                        Text("Loading Acknowledgements...")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)

                        Text("Something went wrong")
                            .font(AppTypography.subtitle)

                        Text(error)
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(packages) { package in
                            NavigationLink(destination: PackageDetailView(package: package)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(package.name)
                                        .font(AppTypography.subtitle)
                                        .foregroundColor(AppColors.textPrimary(for: colorScheme))

                                    if let version = package.version {
                                        Text("v\(version)")
                                            .font(AppTypography.caption)
                                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Acknowledgements")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all))
            .task { await loadPackages() }
        }
    }

    private func loadJson(filename fileName: String) -> [Package]? {
        if let url = Bundle.module.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([Package].self, from: data)
                return jsonData.sorted { $0.name.lowercased() < $1.name.lowercased() }
            } catch {
                errorMessage = "Error decoding JSON: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "JSON file not found"
        }
        return nil
    }

    private func loadPackages() async {
        defer { isLoading = false }
        isLoading = true
        let packages = loadJson(filename: "package-list")

        if let packages {
            await MainActor.run {
                self.packages = packages
            }
        } else {
            errorMessage = "Error decoding JSON"
        }
    }
}

struct PackageDetailView: View {
    let package: Package
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.name)
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary(for: colorScheme))

                    if let version = package.version {
                        Text("Version \(version)")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    }
                }

                Divider()

                if let url = URL(string: package.location) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Repository")
                            .font(AppTypography.subtitle)
                            .foregroundColor(AppColors.textPrimary(for: colorScheme))

                        Link(destination: url) {
                            Text(package.location)
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.accent(for: colorScheme))
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("License")
                        .font(AppTypography.subtitle)
                        .foregroundColor(AppColors.textPrimary(for: colorScheme))

                    Text(package.license)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(package.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all))
    }
}

struct Package: Decodable, Identifiable {
    let identity: String
    let kind: String
    let license: String
    let location: String
    let name: String
    let revision: String
    let version: String?

    var id: String { identity }
}

#Preview {
    SettingsView()
}
