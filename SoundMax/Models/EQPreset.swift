import Foundation

// Built-in presets
enum BuiltInPreset: String, CaseIterable, Identifiable {
    case flat = "Flat"
    case bassBoost = "Bass Boost"
    case trebleBoost = "Treble Boost"
    case vocal = "Vocal"
    case rock = "Rock"
    case electronic = "Electronic"
    case acoustic = "Acoustic"

    var id: String { rawValue }

    var values: [Float] {
        switch self {
        case .flat:
            return [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        case .bassBoost:
            return [6, 5, 4, 2, 0, 0, 0, 0, 0, 0]
        case .trebleBoost:
            return [0, 0, 0, 0, 0, 0, 2, 4, 5, 6]
        case .vocal:
            return [-2, -1, 0, 2, 4, 4, 3, 2, 0, -1]
        case .rock:
            return [5, 4, 2, 0, -1, 0, 2, 4, 5, 5]
        case .electronic:
            return [5, 4, 2, 0, -2, -2, 0, 2, 4, 5]
        case .acoustic:
            return [3, 2, 1, 1, 2, 2, 2, 3, 3, 2]
        }
    }
}

// Custom user preset
struct CustomPreset: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var values: [Float]

    init(name: String, values: [Float]) {
        self.id = UUID()
        self.name = name
        self.values = values
    }
}

// Manager for custom presets
class PresetManager: ObservableObject {
    @Published var customPresets: [CustomPreset] = []

    private let presetsKey = "custom_presets"

    init() {
        loadPresets()
    }

    func savePreset(name: String, values: [Float]) {
        let preset = CustomPreset(name: name, values: values)
        customPresets.append(preset)
        persistPresets()
    }

    func deletePreset(_ preset: CustomPreset) {
        customPresets.removeAll { $0.id == preset.id }
        persistPresets()
    }

    func updatePreset(_ preset: CustomPreset, values: [Float]) {
        if let index = customPresets.firstIndex(where: { $0.id == preset.id }) {
            customPresets[index].values = values
            persistPresets()
        }
    }

    private func persistPresets() {
        if let data = try? JSONEncoder().encode(customPresets) {
            UserDefaults.standard.set(data, forKey: presetsKey)
        }
    }

    private func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: presetsKey),
           let presets = try? JSONDecoder().decode([CustomPreset].self, from: data) {
            customPresets = presets
        }
    }
}
