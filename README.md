# SoundMax

A free, open-source macOS system-wide 10-band parametric equalizer.

SoundMax sits in your menu bar and applies real-time EQ processing to all system audio, letting you fine-tune your listening experience across any app.

## Features

- **10-Band Parametric EQ** - 32Hz, 64Hz, 125Hz, 250Hz, 500Hz, 1kHz, 2kHz, 4kHz, 8kHz, 16kHz
- **±12dB Per Band** - Precise control with professional biquad filtering
- **Built-in Presets** - Flat, Bass Boost, Treble Boost, Vocal, Rock, Electronic, Acoustic
- **Custom Presets** - Save and load your own EQ configurations
- **Menu Bar App** - Always accessible, no dock icon clutter
- **Launch at Login** - Optional auto-start with your Mac
- **Device Flexibility** - Works with various audio interfaces and sample rates

## Requirements

- macOS 14.0 (Sonoma) or later
- [BlackHole 2ch](https://github.com/ExistentialAudio/BlackHole) virtual audio driver

## Installation

### Step 1: Install BlackHole

BlackHole is a free virtual audio driver that routes system audio through SoundMax.

```bash
brew install blackhole-2ch
```

Or download directly from [BlackHole Releases](https://github.com/ExistentialAudio/BlackHole/releases).

### Step 2: Install SoundMax

**Option A: Download Release (Recommended)**

1. Download the latest DMG from [Releases](https://github.com/yourusername/SoundMax/releases)
2. Open the DMG and drag SoundMax to Applications
3. If macOS blocks the app: Right-click → Open → Open

**Option B: Build from Source**

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install XcodeGen
brew install xcodegen

# Clone and build
git clone https://github.com/yourusername/SoundMax.git
cd SoundMax
xcodegen generate
xcodebuild -project SoundMax.xcodeproj -scheme SoundMax -configuration Release build
```

## Setup Guide

### Initial Configuration

1. **Set BlackHole as System Output**
   - Open **System Settings → Sound → Output**
   - Select **BlackHole 2ch**
   - This routes all system audio through BlackHole

2. **Launch SoundMax**
   - Open from Applications or Spotlight
   - Look for the slider icon (☰) in the menu bar
   - Grant microphone access when prompted (required to capture audio from BlackHole)

3. **Configure Audio Routing**
   - **Input**: Should auto-select "BlackHole 2ch"
   - **Output**: Select your actual speakers or headphones (e.g., MacBook Speakers, AirPods, Scarlett 2i2)

4. **Start Processing**
   - Click the **Start** button
   - Status indicator turns green when running

### Audio Signal Flow

```
┌─────────────┐    ┌───────────┐    ┌──────────────┐    ┌─────────────┐
│  Your Apps  │ →  │ BlackHole │ →  │   SoundMax   │ →  │  Speakers   │
│ (Spotify,   │    │   (2ch)   │    │  (EQ + DSP)  │    │ (Real Audio │
│  YouTube)   │    │           │    │              │    │   Output)   │
└─────────────┘    └───────────┘    └──────────────┘    └─────────────┘
```

## Usage

### EQ Controls

| Action | Effect |
|--------|--------|
| Drag slider **up** | Boost frequency (orange, up to +12dB) |
| Drag slider **down** | Cut frequency (blue, down to -12dB) |
| Center position | No change (0dB) |
| Toggle switch | Enable/disable EQ processing |

### Presets

- **Select Preset**: Use the dropdown menu to choose built-in or custom presets
- **Save Custom**: Click **+** to save current EQ settings
- **Delete Custom**: Click trash icon (only available for custom presets)
- **Reset**: Click Reset button to return all bands to 0dB

### Launch at Login

Check the "Launch at Login" box to have SoundMax start automatically when you log in. This setting is managed through macOS Login Items.

## Troubleshooting

### No Audio Output

1. Verify BlackHole is set as system output in System Settings → Sound
2. Check SoundMax shows "Running" status (green indicator)
3. Ensure the correct output device is selected in SoundMax
4. Try clicking Stop, then Start again

### No Sound from Specific Apps

Some apps have their own audio output settings. Check the app's preferences and ensure it's using "System Default" or "BlackHole 2ch" as output.

### "Microphone Access" Prompt

SoundMax requires microphone permission to capture audio from BlackHole. This is a macOS security requirement for any app that reads audio input.

- Click **Allow** when prompted
- If previously denied: System Settings → Privacy & Security → Microphone → Enable SoundMax

### App Won't Open (Blocked by macOS)

For unsigned builds, macOS Gatekeeper may block the app:

1. Right-click the app → **Open** → **Open**
2. Or: System Settings → Privacy & Security → Click **Open Anyway**

### Audio Crackling or Dropouts

- Close other audio-intensive applications
- Try a different output device
- Check Audio MIDI Setup to ensure sample rates match (44.1kHz or 48kHz)

### Sample Rate Mismatch Errors

SoundMax attempts to match sample rates automatically. If issues persist:

1. Open **Audio MIDI Setup** (in /Applications/Utilities)
2. Set both BlackHole and your output device to the same sample rate
3. Restart SoundMax

## Project Structure

```
SoundMax/
├── SoundMax/
│   ├── SoundMaxApp.swift           # App entry, menu bar setup
│   ├── ContentView.swift           # Main UI
│   ├── Audio/
│   │   ├── AudioEngine.swift       # Core Audio routing (AUHAL)
│   │   └── BiquadFilter.swift      # Parametric EQ DSP
│   ├── Models/
│   │   ├── EQModel.swift           # EQ state management
│   │   ├── EQPreset.swift          # Preset definitions
│   │   ├── AudioDeviceManager.swift # Device enumeration
│   │   └── LaunchAtLogin.swift     # Login item management
│   └── Views/
│       └── EQSliderView.swift      # Custom EQ slider
├── scripts/
│   └── build-release.sh            # DMG build script
├── project.yml                      # XcodeGen configuration
└── README.md
```

## Technical Details

- **Audio Framework**: Core Audio with AudioToolbox AUHAL units
- **DSP**: Biquad filters implementing peaking EQ (from Audio EQ Cookbook)
- **UI**: SwiftUI with MenuBarExtra
- **Audio Format**: 32-bit float, non-interleaved stereo
- **Latency**: Minimal (256-512 sample buffer)

## Building a Release

```bash
./scripts/build-release.sh
```

This creates a DMG installer in the `build/` directory.

For signed distribution:
```bash
# Sign the app
codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" build/DerivedData/Build/Products/Release/SoundMax.app

# Notarize
xcrun notarytool submit build/SoundMax-Installer.dmg --apple-id your@email.com --team-id TEAMID --password app-specific-password
```

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Acknowledgments

- [BlackHole](https://github.com/ExistentialAudio/BlackHole) by Existential Audio - Virtual audio driver
- [Audio EQ Cookbook](https://www.w3.org/2011/audio/audio-eq-cookbook.html) by Robert Bristow-Johnson - Biquad filter coefficients
- Built with SwiftUI and Core Audio
