# Simple Audio Sampler - Setup Guide

## Prerequisites
1. **BlackHole** virtual audio driver installed
   - Download from: https://existential.audio/blackhole/
   - Choose the 2-channel version

## Setting Up Multi-Output Device (REQUIRED)

To hear audio while recording, you must create a Multi-Output Device:

### Steps:
1. Open **Audio MIDI Setup** (in /Applications/Utilities/)
2. Click the **+** button at bottom left
3. Select **"Create Multi-Output Device"**
4. In the device list, check both:
   - ✓ Your speakers (e.g., "MacBook Air Speakers")
   - ✓ BlackHole 2ch
5. Rename it to something memorable (e.g., "Sampler by G.O.E.")

### Configure System Audio:
1. Open **System Settings > Sound**
2. In the **Output** tab:
   - Select your Multi-Output Device (e.g., "Sampler by G.O.E.")
3. In the **Input** tab:
   - Select "BlackHole 2ch"

### How It Works:
- The Multi-Output Device sends audio to BOTH:
  - Your speakers (so you can hear it)
  - BlackHole (so the app can record it)
- The app records from BlackHole input
- This allows you to hear and record simultaneously

## Using the App

1. **Quick Setup** - Click this to ensure BlackHole is set as the recording input
2. **Record** - Starts recording system audio for up to 5 minutes
3. **Play** - Plays back your recording
4. **Crop** - Trim your recording to keep only the part you want
5. **Save Recording** - Exports as 44.1 kHz WAV file

## Troubleshooting

### No Audio Recording:
- Ensure Multi-Output Device is selected in System Settings > Sound > Output
- Ensure BlackHole 2ch is selected in System Settings > Sound > Input
- Make sure audio is playing from your source app (Spotify, YouTube, etc.)

### Can't Hear Audio While Recording:
- You must use a Multi-Output Device (see setup above)
- Direct BlackHole output = no sound to speakers

### App Crashes or Permission Loops:
- Never grant microphone permission if asked
- The app uses BlackHole, not the microphone