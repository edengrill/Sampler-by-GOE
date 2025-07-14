# Development Guide

## Important Learning: App Bundle Permissions

**Critical Discovery**: macOS treats app bundles differently for audio permissions. Creating a new app bundle from scratch will fail to record audio, even with identical code. You must copy an existing working bundle and replace only the binary.

### Building New Versions

Always use this approach:
```bash
# Copy working app bundle
cp -R SimpleAudioSampler_v2.4.app SimpleAudioSampler_vNEW.app

# Build new binary
swiftc -parse-as-library -O -o SimpleAudioSampler_vNEW \
    SimpleAudioSampler_vNEW.swift \
    -framework SwiftUI \
    -framework AVFoundation \
    -framework CoreAudio

# Replace binary in bundle
cp SimpleAudioSampler_vNEW SimpleAudioSampler_vNEW.app/Contents/MacOS/SimpleAudioSampler
```

## Key Technical Decisions

### 1. Audio Capture Method
- **Use Core Audio directly** - Never use AVCaptureDevice
- AVCaptureDevice causes permission loops and crashes
- AudioDeviceHelper class handles device management

### 2. Crop Implementation
- **Time-based positions** (seconds) not normalized (0-1)
- Clearer for users to understand
- More precise for playback control

### 3. Waveform Generation
- Process audio in background thread
- Downsample to ~300 points for display
- Use peak detection for visual representation

### 4. Playback Timing
- Dual timer system for precision
- Single-fire timer for stop position
- 60fps UI update timer for smooth playhead

## Code Architecture

### Main Components

1. **AudioManager** - Handles all audio operations
   - Recording through BlackHole
   - Playback with crop support
   - Waveform generation
   
2. **AudioDeviceHelper** - System audio device management
   - Find BlackHole device
   - Set system input/output
   
3. **AudioProcessor** - Audio file operations
   - Resampling to 44.1kHz
   - Crop/trim operations
   
4. **WaveformView** - Visual audio representation
   - Minimal bar design
   - Playhead overlay

## Common Issues & Solutions

### Recording Shows No Signal
- Check BlackHole is set as system input
- Verify Multi-Output Device setup
- Ensure app bundle has correct permissions

### Crop Markers Not Precise
- Timer precision limited to ~16ms
- Use single-fire timers for better accuracy
- Add small tolerance buffer

### App Freezes
- Move heavy processing to background
- Use chunk-based processing
- Limit UI update frequency

## Testing Checklist

Before releasing new version:
- [ ] Test 5-minute recording
- [ ] Verify crop start/end precision
- [ ] Check waveform generation
- [ ] Test export to Downloads
- [ ] Verify setup guide works
- [ ] Test with various audio sources

## Performance Considerations

- Buffer size: 512 frames optimal
- Waveform samples: 300 points max
- UI updates: 60fps for playhead
- Chunk size: 8192 frames for processing