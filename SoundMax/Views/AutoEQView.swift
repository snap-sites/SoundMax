import SwiftUI

struct AutoEQView: View {
    @EnvironmentObject var eqModel: EQModel
    @StateObject private var autoEQManager = AutoEQManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedHeadphone: AutoEQHeadphone?
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            header

            searchField

            if autoEQManager.isLoading {
                loadingView
            } else if let error = autoEQManager.errorMessage {
                errorView(error)
            } else {
                headphoneList
            }

            Spacer()

            footer
        }
        .padding()
        .frame(width: 400, height: 450)
        .onAppear {
            // Delay focus to ensure view is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFocused = true
            }
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "headphones")
                    .font(.title2)
                Text("AutoEQ Headphone Correction")
                    .font(.headline)
            }

            Text("Apply frequency response corrections for your headphones")
                .font(.caption)
                .foregroundColor(.secondary)
                .help("AutoEQ provides scientifically-measured corrections to flatten your headphone's frequency response")

            Link("Powered by AutoEQ", destination: URL(string: "https://github.com/jaakkopasanen/AutoEq")!)
                .font(.caption2)
                .help("Open AutoEQ project on GitHub")
        }
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search headphones...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .focused($isSearchFocused)
                .onChange(of: searchText) { newValue in
                    if newValue.isEmpty {
                        autoEQManager.searchResults = AutoEQManager.popularHeadphones
                    } else {
                        autoEQManager.search(query: newValue)
                    }
                }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    autoEQManager.searchResults = AutoEQManager.popularHeadphones
                    isSearchFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Clear search")
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .help("Type to search for your headphones")
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Fetching EQ data...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
    }

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.orange)
            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
    }

    private var headphoneList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                let headphones = searchText.isEmpty ? AutoEQManager.popularHeadphones : autoEQManager.searchResults

                if headphones.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("No headphones found")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Try a different search term")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                } else {
                    ForEach(headphones) { headphone in
                        headphoneRow(headphone)
                    }
                }
            }
        }
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }

    private func headphoneRow(_ headphone: AutoEQHeadphone) -> some View {
        Button {
            selectedHeadphone = headphone
            applyAutoEQ(headphone)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(headphone.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)

                    HStack(spacing: 4) {
                        Text(headphone.displayType)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text(headphone.source)
                            .font(.system(size: 10))
                            .foregroundColor(.orange.opacity(0.8))
                    }
                }

                Spacer()

                if selectedHeadphone?.id == headphone.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selectedHeadphone?.id == headphone.id ? Color.accentColor.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Click to apply \(headphone.name) correction curve")
    }

    private var footer: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .help("Close without applying changes")

            Spacer()

            if selectedHeadphone != nil {
                Text("Applied: \(selectedHeadphone!.name)")
                    .font(.caption)
                    .foregroundColor(.green)
                    .help("Currently applied headphone correction")
            }

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .help("Close and keep applied EQ settings")
        }
    }

    private func applyAutoEQ(_ headphone: AutoEQHeadphone) {
        autoEQManager.fetchEQ(for: headphone) { result in
            switch result {
            case .success(let bands):
                eqModel.bands = bands
                eqModel.clearPresetSelection()
            case .failure:
                selectedHeadphone = nil
            }
        }
    }
}

#Preview {
    AutoEQView()
        .environmentObject(EQModel())
}
