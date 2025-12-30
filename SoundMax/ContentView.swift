import SwiftUI
import CoreAudio

struct ContentView: View {
    @EnvironmentObject var audioEngine: AudioEngine
    @EnvironmentObject var eqModel: EQModel
    @StateObject private var deviceManager = AudioDeviceManager()
    @StateObject private var presetManager = PresetManager()

    @State private var selectedInputID: AudioDeviceID?
    @State private var selectedOutputID: AudioDeviceID?
    @State private var showingSavePreset = false
    @State private var newPresetName = ""
    @StateObject private var launchAtLogin = LaunchAtLogin()

    var body: some View {
        VStack(spacing: 12) {
            header

            Divider()

            eqSliders

            // Volume slider for HDMI/devices without hardware volume
            if audioEngine.outputDeviceNeedsVolumeControl {
                volumeControl
            }

            Divider()

            presetControls

            Divider()

            deviceControls

            Divider()

            footer
        }
        .padding()
        .frame(width: 440)
        .onAppear {
            setupDeviceChangeCallback()
            syncEQToEngine()
            autoSelectDevices()
        }
        .onChange(of: eqModel.bands) { _, newValue in
            audioEngine.setAllGains(newValue)
            eqModel.clearPresetSelection()
        }
        .onChange(of: eqModel.isEnabled) { _, newValue in
            audioEngine.setBypass(!newValue)
        }
        .onChange(of: eqModel.volume) { _, newValue in
            audioEngine.setVolume(newValue)
        }
        .sheet(isPresented: $showingSavePreset) {
            savePresetSheet
        }
    }

    private func setupDeviceChangeCallback() {
        audioEngine.onOutputDeviceChanged = { _, uid, name in
            DispatchQueue.main.async {
                eqModel.onDeviceChanged(deviceUID: uid, deviceName: name)
                // Sync volume from profile to engine
                audioEngine.setVolume(eqModel.volume)
            }
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "slider.horizontal.3")
                .font(.title2)

            Text("SoundMax EQ")
                .font(.headline)

            Spacer()

            Toggle("", isOn: $eqModel.isEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .help("Enable or bypass EQ processing")
        }
    }

    private static let frequencyTooltips = [
        "Sub-bass: Rumble, sub-woofer content",
        "Bass: Kick drums, bass guitar fundamentals",
        "Low-mid: Bass warmth, body of sound",
        "Mid-bass: Reduce for less muddiness",
        "Midrange: Vocal body, snare drum",
        "Upper-mid: Vocal presence, clarity",
        "Presence: Detail, intelligibility",
        "Brilliance: Attack, consonants, hi-hat",
        "Treble: Airiness, cymbal shimmer",
        "Air: Sparkle, highest harmonics"
    ]

    private var eqSliders: some View {
        HStack(spacing: 6) {
            ForEach(0..<10, id: \.self) { index in
                EQSliderView(
                    value: $eqModel.bands[index],
                    label: EQModel.frequencyLabels[index],
                    tooltip: Self.frequencyTooltips[index]
                )
            }
        }
        .opacity(eqModel.isEnabled ? 1.0 : 0.5)
        .disabled(!eqModel.isEnabled)
    }

    private var volumeControl: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "speaker.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)

                Slider(value: $eqModel.volume, in: 0...1)
                    .help("Software volume control - macOS disables hardware volume for HDMI outputs")

                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)

                Text("\(Int(eqModel.volume * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 35, alignment: .trailing)
            }

            Text("HDMI Volume (no hardware control)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private var presetControls: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Preset")
                    .foregroundColor(.secondary)

                Spacer()

                Menu {
                    // Built-in presets
                    Section("Built-in") {
                        ForEach(BuiltInPreset.allCases) { preset in
                            Button(preset.rawValue) {
                                eqModel.applyBuiltInPreset(preset)
                            }
                        }
                    }

                    // Custom presets
                    if !presetManager.customPresets.isEmpty {
                        Section("Custom") {
                            ForEach(presetManager.customPresets) { preset in
                                Button(preset.name) {
                                    eqModel.applyCustomPreset(preset)
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(currentPresetName)
                            .frame(width: 120, alignment: .leading)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
                }
                .help("Select a preset EQ curve")

                Button {
                    newPresetName = ""
                    showingSavePreset = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderless)
                .help("Save current EQ as a custom preset")

                if let customPreset = eqModel.selectedCustomPreset {
                    Button {
                        presetManager.deletePreset(customPreset)
                        eqModel.applyBuiltInPreset(.flat)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.red)
                    .help("Delete this preset")
                }
            }
        }
    }

    private var currentPresetName: String {
        if let preset = eqModel.selectedBuiltInPreset {
            return preset.rawValue
        } else if let preset = eqModel.selectedCustomPreset {
            return preset.name
        } else {
            return "Custom"
        }
    }

    private var deviceControls: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Input")
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading)

                Picker("", selection: $selectedInputID) {
                    Text("Select...").tag(nil as AudioDeviceID?)
                    ForEach(deviceManager.inputDevices) { device in
                        Text(device.name).tag(device.id as AudioDeviceID?)
                    }
                }
                .labelsHidden()
                .help("Select BlackHole 2ch to capture system audio")
                .onChange(of: selectedInputID) { _, newDevice in
                    if let deviceID = newDevice {
                        audioEngine.setInputDevice(deviceID)
                    }
                }
            }

            HStack {
                Text("Output")
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .leading)

                Picker("", selection: $selectedOutputID) {
                    Text("Select...").tag(nil as AudioDeviceID?)
                    ForEach(deviceManager.outputDevices) { device in
                        Text(device.name).tag(device.id as AudioDeviceID?)
                    }
                }
                .labelsHidden()
                .help("Select your speakers or headphones")
                .onChange(of: selectedOutputID) { _, newDevice in
                    if let deviceID = newDevice {
                        audioEngine.setOutputDevice(deviceID)
                    }
                }
            }

            // Device profile controls
            if eqModel.currentDeviceName != nil {
                deviceProfileControls
            }

            if let error = audioEngine.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private var deviceProfileControls: some View {
        HStack {
            if eqModel.hasDeviceProfile {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("Profile saved for \(eqModel.currentDeviceName ?? "device")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    eqModel.deleteCurrentDeviceProfile()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.red)
                .help("Delete device profile")
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "circle.dashed")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text("No profile for \(eqModel.currentDeviceName ?? "device")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    eqModel.saveCurrentAsDeviceProfile()
                } label: {
                    Text("Save Profile")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .help("Save EQ settings for this device")
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 8) {
            HStack {
                Toggle("Launch at Login", isOn: $launchAtLogin.isEnabled)
                    .font(.caption)
                    .toggleStyle(.checkbox)
                    .help("Automatically start SoundMax when you log in")

                Spacer()
            }

            HStack {
                statusIndicator

                Spacer()

                Button("Reset") {
                    eqModel.reset()
                }
                .help("Reset all EQ bands to 0dB (flat)")

                Button(audioEngine.isRunning ? "Stop" : "Start") {
                    if audioEngine.isRunning {
                        audioEngine.stop()
                    } else {
                        audioEngine.start()
                    }
                }
                .buttonStyle(.borderedProminent)
                .help(audioEngine.isRunning ? "Stop audio processing" : "Start audio processing")

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .help("Quit SoundMax")
            }
        }
    }

    private var statusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(audioEngine.isRunning ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            Text(audioEngine.isRunning ? "Running" : "Stopped")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var savePresetSheet: some View {
        VStack(spacing: 16) {
            Text("Save Preset")
                .font(.headline)

            TextField("Preset Name", text: $newPresetName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)

            HStack {
                Button("Cancel") {
                    showingSavePreset = false
                }

                Button("Save") {
                    if !newPresetName.isEmpty {
                        presetManager.savePreset(name: newPresetName, values: eqModel.bands)
                        showingSavePreset = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(newPresetName.isEmpty)
            }
        }
        .padding()
        .frame(width: 280)
    }

    private func syncEQToEngine() {
        audioEngine.setAllGains(eqModel.bands)
        audioEngine.setBypass(!eqModel.isEnabled)
    }

    private func autoSelectDevices() {
        if let blackhole = deviceManager.findBlackHole() {
            selectedInputID = blackhole.id
            audioEngine.setInputDevice(blackhole.id)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AudioEngine())
        .environmentObject(EQModel())
}
