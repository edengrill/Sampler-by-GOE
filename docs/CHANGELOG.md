# Changelog

All notable changes to Simple Audio Sampler will be documented in this file.

## [2.4.0] - 2024-07-14

### Added
- Waveform visualization showing audio amplitude
- Real-time waveform generation after recording
- Waveform updates when crop is applied
- Visual playhead indicator on waveform during playback
- Minimal design with blue bars representation

### Technical
- Efficient audio processing with peak detection
- Downsampling to ~300 samples for display
- Background processing to avoid UI blocking

## [2.3.0] - 2024-07-14

### Added
- Comprehensive 5-step setup guide
- Visual progress indicators for setup
- Auto-configure input option
- Clear Multi-Output Device instructions
- Test recording guidance

### Fixed
- Improved crop end marker precision
- Better playback timing accuracy

## [2.2.0] - 2024-07-14

### Changed
- Crop feature now uses time-based approach (seconds) instead of normalized values
- Improved crop marker independence
- Better visual feedback for crop duration

### Fixed
- Audio playback no longer cuts off early
- Crop selection properly applied when saved
- Recording duration accuracy improved

### Technical
- Switched from normalized (0-1) to absolute time positions
- Fixed playback timer precision issues

## [2.1.0] - 2024-07-14

### Added
- Performance optimizations
- Chunk-based audio processing
- Memory efficiency improvements

### Changed
- 5-minute recording time (increased from 10 seconds)
- Optimized buffer sizes for better performance

### Fixed
- App freezing issues
- Audio format validation
- Permission handling improvements

## [2.0.0] - 2024-07-13

### Added
- Audio crop feature with visual markers
- Export to Downloads folder
- Separate Play and Pause buttons
- Visual crop selection interface
- Duration display

### Changed
- Complete UI overhaul
- Improved audio visualization

## [1.5.x] - 2024-07-13

### Fixed
- Permission loops when requesting microphone access
- App crashes on record button
- Audio format 0Hz errors

### Technical
- Removed AVCaptureDevice dependency
- Switched to Core Audio APIs only
- Direct BlackHole device integration

## [1.0.0] - 2024-07-13

### Initial Release
- Basic system audio recording through BlackHole
- Simple play/stop interface
- WAV file export