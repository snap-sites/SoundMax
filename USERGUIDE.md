# SoundMax User Guide

A complete guide to setting up and using SoundMax, your system-wide audio equalizer for macOS.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [Initial Setup](#initial-setup)
4. [Using the Equalizer](#using-the-equalizer)
5. [Presets](#presets)
6. [Per-Device Profiles](#per-device-profiles)
7. [HDMI Volume Control](#hdmi-volume-control)
8. [Tips & Best Practices](#tips--best-practices)
9. [Troubleshooting](#troubleshooting)
10. [FAQ](#faq)

---

## Quick Start

1. Install BlackHole: `brew install blackhole-2ch`
2. Set system output to "BlackHole 2ch" in System Settings → Sound
3. Launch SoundMax from Applications
4. Select your speakers/headphones as Output
5. Click **Start**
6. Adjust the EQ sliders to taste

---

## Installation

### Step 1: Install BlackHole Audio Driver

BlackHole is a free virtual audio driver that captures system audio for SoundMax to process.

**Using Homebrew (recommended):**
```bash
brew install blackhole-2ch
```

**Manual installation:**
1. Download from [BlackHole Releases](https://github.com/ExistentialAudio/BlackHole/releases)
2. Open the installer package
3. Follow the installation prompts
4. Restart your Mac if prompted

### Step 2: Install SoundMax

1. Download `SoundMax-Installer.dmg` from the [Releases page](https://github.com/snap-sites/SoundMax/releases)
2. Open the DMG file
3. Drag **SoundMax** to the **Applications** folder
4. Eject the DMG

### Step 3: First Launch

1. Open SoundMax from Applications (or use Spotlight: ⌘+Space, type "SoundMax")
2. If macOS blocks the app:
   - Right-click SoundMax → **Open** → **Open**
   - Or: System Settings → Privacy & Security → Click **Open Anyway**
3. Grant microphone access when prompted (required to capture audio)

---

## Initial Setup

### Configure System Audio

1. Open **System Settings** → **Sound** → **Output**
2. Select **BlackHole 2ch** as your output device
3. Your system audio is now routed through BlackHole

> **Note:** You won't hear any sound until SoundMax is running and configured.

### Configure SoundMax

1. Click the **slider icon** in your menu bar to open SoundMax
2. **Input**: Should auto-select "BlackHole 2ch" (if not, select it manually)
3. **Output**: Select your actual speakers or headphones:
   - MacBook Speakers
   - AirPods / AirPods Pro
   - External speakers
   - Audio interface (e.g., Scarlett 2i2)
   - HDMI display speakers
4. Click **Start**
5. The status indicator turns **green** when audio is flowing

### Audio Signal Path

```
┌──────────────┐      ┌───────────┐      ┌──────────┐      ┌──────────────┐
│  Your Apps   │  →   │ BlackHole │  →   │ SoundMax │  →   │   Speakers   │
│  (Spotify,   │      │           │      │   (EQ)   │      │ (Your actual │
│   YouTube)   │      │           │      │          │      │    output)   │
└──────────────┘      └───────────┘      └──────────┘      └──────────────┘
```

---

## Using the Equalizer

### The 10 Frequency Bands

| Band | Frequency | Typical Use |
|------|-----------|-------------|
| 32 Hz | Sub-bass | Rumble, sub-woofer content |
| 64 Hz | Bass | Kick drums, bass guitar fundamentals |
| 125 Hz | Low-mid | Bass warmth, male vocals |
| 250 Hz | Mid-bass | Muddiness area, body of instruments |
| 500 Hz | Midrange | Vocal clarity, snare drum |
| 1 kHz | Upper-mid | Vocal presence, guitar attack |
| 2 kHz | Presence | Clarity, vocal intelligibility |
| 4 kHz | Brilliance | Detail, consonants, hi-hat |
| 8 kHz | Treble | Airiness, cymbal shimmer |
| 16 kHz | Air | Sparkle, highest harmonics |

### Adjusting the EQ

- **Drag a slider UP** → Boost that frequency (orange, up to +12dB)
- **Drag a slider DOWN** → Cut that frequency (blue, down to -12dB)
- **Center position** → No change (0dB)

### Enable/Disable

Use the toggle switch in the header to quickly bypass the EQ and hear your original audio.

### Reset

Click the **Reset** button to return all bands to 0dB (flat response).

---

## Presets

### Built-in Presets

SoundMax includes 7 professionally-tuned presets:

| Preset | Description |
|--------|-------------|
| **Flat** | No EQ applied (all bands at 0dB) |
| **Bass Boost** | Enhanced low frequencies for more punch |
| **Treble Boost** | Enhanced high frequencies for clarity |
| **Vocal** | Optimized for speech and singing |
| **Rock** | Classic rock sound with punchy mids |
| **Electronic** | Enhanced bass and highs for EDM |
| **Acoustic** | Natural sound for acoustic instruments |

### Using Presets

1. Click the preset dropdown menu
2. Select a preset from "Built-in" or "Custom"
3. The EQ adjusts instantly

### Saving Custom Presets

1. Adjust the EQ to your preferred settings
2. Click the **+** button next to the preset menu
3. Enter a name for your preset
4. Click **Save**

### Deleting Custom Presets

1. Select the custom preset you want to delete
2. Click the **trash icon** that appears
3. The preset is removed and EQ resets to Flat

---

## Per-Device Profiles

SoundMax remembers your EQ settings for each output device. This is perfect if you use different audio equipment throughout the day.

### How It Works

When you select an output device:
- **If a profile exists**: Your saved EQ and volume settings are automatically restored
- **If no profile exists**: You'll see "No profile for [device name]"

### Saving a Device Profile

1. Select your output device
2. Adjust the EQ sliders to your preference
3. Click **Save Profile**
4. A green checkmark confirms the profile is saved

### Auto-Save

Once you've saved a profile, any further EQ adjustments are **automatically saved** to that device's profile. No need to click Save again.

### Deleting a Device Profile

1. Select the device
2. Click the **trash icon** next to the profile status
3. The profile is deleted (your current EQ settings remain)

### Example Use Cases

| Device | Typical Profile |
|--------|-----------------|
| AirPods Pro | Slight bass boost to compensate for seal |
| MacBook Speakers | Bass boost + treble lift for small drivers |
| Studio Monitors | Flat or subtle adjustments |
| HDMI TV | Vocal boost for dialog clarity |
| Scarlett + Headphones | Flat reference sound |

---

## HDMI Volume Control

macOS disables hardware volume control for HDMI audio outputs (TVs, monitors). SoundMax solves this with a software volume slider.

### When It Appears

The volume slider automatically appears when:
- Your output device is connected via HDMI or DisplayPort
- The device doesn't have hardware volume control

### Using the Volume Slider

- Drag the slider to adjust volume (0-100%)
- Volume setting is saved as part of your device profile
- Works independently of the EQ on/off toggle

---

## Tips & Best Practices

### Getting the Best Sound

1. **Start with a preset** that matches your music genre
2. **Make small adjustments** (±3dB) rather than extreme boosts
3. **Cut before boosting** - reducing problem frequencies often sounds better than boosting others
4. **Use the bypass toggle** to compare your EQ to the original sound

### Common EQ Adjustments

| Problem | Solution |
|---------|----------|
| Muddy/boomy sound | Cut 125-250 Hz |
| Thin/weak bass | Boost 64-125 Hz |
| Harsh/fatiguing | Cut 2-4 kHz |
| Dull/muffled | Boost 4-8 kHz |
| Sibilant vocals | Cut 4-8 kHz |
| No "air" or sparkle | Boost 12-16 kHz |

### System Integration

- **Launch at Login**: Enable this to have SoundMax ready whenever you start your Mac
- **Menu Bar Access**: SoundMax lives in your menu bar for quick access without cluttering your Dock

---

## Troubleshooting

### No Sound at All

1. **Check system output**: System Settings → Sound → Output should be "BlackHole 2ch"
2. **Check SoundMax status**: Should show green "Running" indicator
3. **Check output device**: Make sure your actual speakers are selected in SoundMax
4. **Restart audio**: Click Stop, wait a moment, click Start

### Sound Only From Some Apps

Some apps have their own audio output settings:
- **Spotify**: Settings → Playback → Output device
- **Zoom**: Settings → Audio → Speaker
- **Chrome**: Usually follows system default

Set these apps to use "System Default" or "BlackHole 2ch".

### Crackling or Distorted Audio

1. **Lower the EQ gains** - excessive boosting causes clipping
2. **Reduce software volume** if using HDMI
3. **Close other audio apps** that might conflict
4. **Check sample rates** in Audio MIDI Setup (both devices should match)

### App Won't Open

If macOS blocks SoundMax:
1. Right-click the app → **Open** → **Open**
2. Or: System Settings → Privacy & Security → **Open Anyway**

### Microphone Permission Denied

If you accidentally denied microphone access:
1. Open **System Settings** → **Privacy & Security** → **Microphone**
2. Find SoundMax and enable it
3. Restart SoundMax

### EQ Not Affecting Sound

1. Check the **EQ toggle** is enabled (switch should be ON)
2. Check you're not on the **Flat** preset (all bands at 0dB)
3. Make sure audio is flowing (status should be "Running")

---

## FAQ

**Q: Why does SoundMax need microphone permission?**
A: macOS treats any audio input as "microphone access" - SoundMax needs this to capture audio from BlackHole for processing.

**Q: Will SoundMax affect call audio in Zoom/Teams/FaceTime?**
A: Only if those apps are set to output through BlackHole. For calls, it's usually better to set them to output directly to your speakers.

**Q: Can I use SoundMax with AirPlay?**
A: Yes! Select your AirPlay device as the output in SoundMax.

**Q: Does SoundMax work with Bluetooth headphones?**
A: Yes, select your Bluetooth headphones as the output device.

**Q: How much CPU does SoundMax use?**
A: Very little - typically less than 1% on Apple Silicon Macs.

**Q: Can I use SoundMax with other audio apps like Logic Pro?**
A: Professional audio apps typically have their own audio routing. You can use SoundMax alongside them, but you may want to route the DAW directly to your interface, not through BlackHole.

**Q: What's the audio latency?**
A: Minimal - typically under 10ms, imperceptible for music listening. For recording or live monitoring, use your audio interface directly.

**Q: How do I completely uninstall SoundMax?**
A:
1. Quit SoundMax
2. Delete from Applications
3. Optionally remove BlackHole: `brew uninstall blackhole-2ch`
4. Reset system audio output to your speakers

---

## Need Help?

- **GitHub Issues**: [Report a bug or request a feature](https://github.com/snap-sites/SoundMax/issues)
- **README**: [Technical documentation](https://github.com/snap-sites/SoundMax#readme)

---

*SoundMax is free, open-source software released under the MIT License.*
