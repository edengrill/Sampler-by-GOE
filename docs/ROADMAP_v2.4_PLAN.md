# Simple Audio Sampler - v2.4 Roadmap & Pre-UI Design Plan

## Current Status (v2.3)
- ✅ Core recording/playback working
- ✅ Time-based crop with seconds
- ✅ Comprehensive setup guide
- ✅ Separate Play/Pause buttons (just implemented)
- ⚠️ No waveform visualization
- ⚠️ Crop sliders could be smoother
- ⚠️ Basic UI without visual polish

## Phase 1: Technical Optimizations (Before UI Design)

### 1.1 Performance Improvements
Based on research, implement:
- **Chunk-based processing** ✓ (already done)
- **Metal-accelerated waveform rendering** for smooth visualization
- **Background audio processing** to prevent UI freezes
- **Memory management** - ensure proper cleanup of audio buffers

### 1.2 Waveform Visualization
- Simple amplitude display showing audio levels
- Efficient rendering without performance impact
- Visual feedback during recording (growing waveform)
- Crop overlay on waveform for better precision

### 1.3 Crop Improvements
- **Smoother sliders** - increase update frequency
- **Snap-to-grid** option for precise timing
- **Zoom capability** for fine-tuning
- **Keyboard shortcuts** (arrow keys for fine adjustment)

### 1.4 Code Architecture Cleanup
- Separate audio engine into its own module
- Create reusable UI components
- Document all public methods
- Remove any dead code

## Phase 2: Pre-UI Design Checklist

### What needs to be done BEFORE UI redesign:

1. **Finalize Feature Set**
   - Confirm no new features will be added
   - Lock down all functionality
   - Document exact behavior of each feature

2. **Create Component Inventory**
   - List all UI elements needed
   - Define all user interactions
   - Map out all app states (recording, playing, cropping, etc.)

3. **Establish Design Constraints**
   - Minimum window size
   - Required accessibility features
   - Platform-specific guidelines (macOS HIG)

4. **Performance Baseline**
   - Ensure <50ms response time for all actions
   - Smooth 60fps animations capability
   - Low CPU usage during idle

## Phase 3: UI Design Preparation

### Information Architecture
- Main controls (Record, Play, Pause)
- Audio visualization area
- Crop controls
- File management (Save, Export)
- Setup/Help access

### Interaction Patterns
- **Recording**: One-click start/stop
- **Playback**: Play always restarts, Pause holds position
- **Cropping**: Visual + numeric precision
- **Export**: Simple save to Downloads

### Visual Hierarchy
1. Primary: Record button
2. Secondary: Play/Pause controls
3. Tertiary: Crop and export functions
4. Quaternary: Setup and help

## Implementation Priority

### High Priority (Do First):
1. Simple waveform visualization
2. Crop slider improvements
3. Code cleanup/organization

### Medium Priority:
1. Performance optimizations
2. Keyboard shortcuts
3. Better error handling

### Low Priority (After UI Design):
1. Themes/color schemes
2. Advanced visualizations
3. Export format options

## Next Steps

1. **Implement waveform** - Start with basic amplitude display
2. **Improve crop sliders** - Make them more responsive
3. **Clean up code** - Prepare for UI designer handoff
4. **Document everything** - Create spec sheet for designers

## Technical Debt to Address

- Remove console print statements
- Fix CFString warning in audio device code
- Standardize error handling
- Add unit tests for critical functions

## Design System Requirements

For the UI designer, we'll need to provide:
- Color palette (currently using system colors)
- Typography scale
- Spacing system
- Icon requirements
- Animation timings
- Component states (normal, hover, pressed, disabled)

---

This plan ensures we have a solid, optimized foundation before applying the new UI design.