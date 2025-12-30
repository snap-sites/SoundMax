import SwiftUI
import Combine

class EQModel: ObservableObject {
    @Published var bands: [Float] = Array(repeating: 0, count: 10)
    @Published var isEnabled: Bool = true
    @Published var selectedBuiltInPreset: BuiltInPreset? = .flat
    @Published var selectedCustomPreset: CustomPreset? = nil

    static let frequencyLabels = ["32", "64", "125", "250", "500", "1K", "2K", "4K", "8K", "16K"]

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadSettings()

        $bands
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)

        $isEnabled
            .sink { [weak self] _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)
    }

    func applyBuiltInPreset(_ preset: BuiltInPreset) {
        selectedBuiltInPreset = preset
        selectedCustomPreset = nil
        bands = preset.values
    }

    func applyCustomPreset(_ preset: CustomPreset) {
        selectedCustomPreset = preset
        selectedBuiltInPreset = nil
        bands = preset.values
    }

    func reset() {
        applyBuiltInPreset(.flat)
    }

    func clearPresetSelection() {
        selectedBuiltInPreset = nil
        selectedCustomPreset = nil
    }

    private func saveSettings() {
        UserDefaults.standard.set(bands, forKey: "eq_bands")
        UserDefaults.standard.set(isEnabled, forKey: "eq_enabled")
        if let preset = selectedBuiltInPreset {
            UserDefaults.standard.set(preset.rawValue, forKey: "eq_builtin_preset")
            UserDefaults.standard.removeObject(forKey: "eq_custom_preset_id")
        } else if let preset = selectedCustomPreset {
            UserDefaults.standard.set(preset.id.uuidString, forKey: "eq_custom_preset_id")
            UserDefaults.standard.removeObject(forKey: "eq_builtin_preset")
        }
    }

    private func loadSettings() {
        if let savedBands = UserDefaults.standard.array(forKey: "eq_bands") as? [Float] {
            bands = savedBands
        }
        isEnabled = UserDefaults.standard.object(forKey: "eq_enabled") as? Bool ?? true

        if let presetName = UserDefaults.standard.string(forKey: "eq_builtin_preset"),
           let preset = BuiltInPreset(rawValue: presetName) {
            selectedBuiltInPreset = preset
        }
    }
}
