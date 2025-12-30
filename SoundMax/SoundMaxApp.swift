import SwiftUI
import AVFoundation

@main
struct SoundMaxApp: App {
    @StateObject private var audioEngine = AudioEngine()
    @StateObject private var eqModel = EQModel()

    init() {
        // Request microphone permission once at startup
        requestMicrophonePermission()
    }

    var body: some Scene {
        MenuBarExtra("SoundMax", systemImage: "slider.horizontal.3") {
            ContentView()
                .environmentObject(audioEngine)
                .environmentObject(eqModel)
        }
        .menuBarExtraStyle(.window)
    }

    private func requestMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    print("Microphone access granted")
                } else {
                    print("Microphone access denied")
                }
            }
        case .denied, .restricted:
            print("Microphone access denied - please enable in System Settings > Privacy > Microphone")
        case .authorized:
            print("Microphone access already authorized")
        @unknown default:
            break
        }
    }
}
