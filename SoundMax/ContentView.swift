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
        .sheet(isPresented: $showingSavePreset) {
            savePresetSheet
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
        }
    }

    private var eqSliders: some View {
        HStack(spacing: 6) {
            ForEach(0..<10, id: \.self) { index in
                EQSliderView(
                    value: $eqModel.bands[index],
                    label: EQModel.frequencyLabels[index]
                )
            }
        }
        .opacity(eqModel.isEnabled ? 1.0 : 0.5)
        .disabled(!eqModel.isEnabled)
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

                Button {
                    newPresetName = ""
                    showingSavePreset = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderless)
                .help("Save current settings as preset")

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
                .onChange(of: selectedOutputID) { _, newDevice in
                    if let deviceID = newDevice {
                        audioEngine.setOutputDevice(deviceID)
                    }
                }
            }

            if let error = audioEngine.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 8) {
            HStack {
                Toggle("Launch at Login", isOn: $launchAtLogin.isEnabled)
                    .font(.caption)
                    .toggleStyle(.checkbox)

                Spacer()
            }

            HStack {
                statusIndicator

                Spacer()

                Button("Reset") {
                    eqModel.reset()
                }

                Button(audioEngine.isRunning ? "Stop" : "Start") {
                    if audioEngine.isRunning {
                        audioEngine.stop()
                    } else {
                        audioEngine.start()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
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
