import SwiftUI
import Combine

class EQModel: ObservableObject {
    @Published var bands: [Float] = Array(repeating: 0, count: 10)
    @Published var isEnabled: Bool = true
    @Published var volume: Float = 1.0
    @Published var selectedBuiltInPreset: BuiltInPreset? = .flat
    @Published var selectedCustomPreset: CustomPreset? = nil

    // Current device profile tracking
    @Published var currentDeviceUID: String?
    @Published var currentDeviceName: String?
    @Published var hasDeviceProfile: Bool = false
    @Published var autoSaveEnabled: Bool = true

    static let frequencyLabels = ["32", "64", "125", "250", "500", "1K", "2K", "4K", "8K", "16K"]

    private var cancellables = Set<AnyCancellable>()
    private let profileManager = DeviceProfileManager.shared
    private var isLoadingProfile = false

    init() {
        loadSettings()

        $bands
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveSettings()
                self?.autoSaveToDeviceProfile()
            }
            .store(in: &cancellables)

        $isEnabled
            .sink { [weak self] _ in
                self?.saveSettings()
                self?.autoSaveToDeviceProfile()
            }
            .store(in: &cancellables)

        $volume
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.autoSaveToDeviceProfile()
            }
            .store(in: &cancellables)
    }

    // MARK: - Device Profile Management

    func onDeviceChanged(deviceUID: String, deviceName: String) {
        currentDeviceUID = deviceUID
        currentDeviceName = deviceName

        // Load profile for this device if it exists
        if let profile = profileManager.profile(for: deviceUID) {
            loadFromProfile(profile)
            hasDeviceProfile = true
        } else {
            hasDeviceProfile = false
        }
    }

    func saveCurrentAsDeviceProfile() {
        guard let uid = currentDeviceUID, let name = currentDeviceName else { return }

        let bandsAsDouble = bands.map { Double($0) }
        profileManager.saveCurrentSettings(
            for: uid,
            deviceName: name,
            eqBands: bandsAsDouble,
            volume: volume,
            isEQEnabled: isEnabled
        )
        hasDeviceProfile = true
    }

    func deleteCurrentDeviceProfile() {
        guard let uid = currentDeviceUID else { return }
        profileManager.deleteProfile(for: uid)
        hasDeviceProfile = false
    }

    private func loadFromProfile(_ profile: DeviceProfile) {
        isLoadingProfile = true
        bands = profile.eqBands.map { Float($0) }
        volume = profile.volume
        isEnabled = profile.isEQEnabled
        clearPresetSelection()
        isLoadingProfile = false
    }

    private func autoSaveToDeviceProfile() {
        guard autoSaveEnabled,
              !isLoadingProfile,
              hasDeviceProfile,
              let uid = currentDeviceUID,
              let name = currentDeviceName else { return }

        let bandsAsDouble = bands.map { Double($0) }
        profileManager.saveCurrentSettings(
            for: uid,
            deviceName: name,
            eqBands: bandsAsDouble,
            volume: volume,
            isEQEnabled: isEnabled
        )
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
