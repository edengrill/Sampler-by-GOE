import SwiftUI
import AVFoundation
import CoreAudio
import UniformTypeIdentifiers

// Simple Audio Sampler v2.4 - With Waveform Visualization
// Based on v2.3 with minimal waveform display

@main
struct SimpleAudioSamplerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var setupGuide = SetupGuideManager()
    @State private var showingSavePanel = false
    @State private var showingCropMode = false
    @State private var showingSetupGuide = false
    
    // Crop positions in seconds (not normalized)
    @State private var cropStartTime: Double = 0
    @State private var cropEndTime: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("🎵 Simple Audio Sampler")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("v2.4 - Waveform")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Status
            VStack(spacing: 4) {
                Text(audioManager.statusMessage)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            // Setup Guide Button
            Button(action: {
                showingSetupGuide = true
            }) {
                HStack {
                    Image(systemName: "questionmark.circle")
                    Text("Setup Guide")
                }
            }
            .buttonStyle(.bordered)
            .foregroundColor(.blue)
            
            // Recording Controls
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    Button(action: {
                        if audioManager.isRecording {
                            audioManager.stopRecording()
                        } else {
                            audioManager.startRecording()
                        }
                    }) {
                        HStack {
                            Image(systemName: audioManager.isRecording ? "stop.circle.fill" : "circle.fill")
                            Text(audioManager.isRecording ? "Stop Recording" : "Record (5 min)")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 180, height: 44)
                        .background(audioManager.isRecording ? Color.red : Color.blue)
                        .cornerRadius(22)
                    }
                    
                    if let _ = audioManager.recordedAudioURL {
                        // Play button - always starts from beginning
                        Button(action: {
                            if showingCropMode {
                                audioManager.playFromTime(cropStartTime, endTime: cropEndTime)
                            } else {
                                audioManager.playFromPosition(0)
                            }
                        }) {
                            HStack {
                                Image(systemName: "play.circle")
                                Text("Play")
                            }
                            .frame(width: 100, height: 44)
                        }
                        .buttonStyle(.bordered)
                        .disabled(audioManager.isRecording)
                        
                        // Pause button - only visible when playing
                        if audioManager.isPlaying {
                            Button(action: {
                                audioManager.pausePlayback()
                            }) {
                                HStack {
                                    Image(systemName: "pause.circle")
                                    Text("Pause")
                                }
                                .frame(width: 100, height: 44)
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.orange)
                        }
                    }
                }
            }
            
            // Audio visualization and controls
            if let _ = audioManager.recordedAudioURL {
                VStack(spacing: 12) {
                    // Audio visualization
                    ZStack {
                        // Waveform or placeholder
                        if audioManager.waveformSamples.isEmpty {
                            Rectangle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(height: 120)
                                .cornerRadius(8)
                        } else {
                            WaveformView(
                                samples: audioManager.waveformSamples,
                                playheadPosition: $audioManager.playheadPosition,
                                isPlaying: audioManager.isPlaying
                            )
                            .frame(height: 120)
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(8)
                        }
                        
                        if showingCropMode {
                            // Show crop area based on actual time
                            GeometryReader { geometry in
                                let startFraction = cropStartTime / audioManager.recordingDuration
                                let endFraction = cropEndTime / audioManager.recordingDuration
                                Rectangle()
                                    .fill(Color.green.opacity(0.3))
                                    .frame(width: geometry.size.width * (endFraction - startFraction))
                                    .offset(x: geometry.size.width * startFraction)
                                
                                // Show crop markers
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: 2)
                                    .offset(x: geometry.size.width * startFraction)
                                
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: 2)
                                    .offset(x: geometry.size.width * endFraction)
                            }
                        }
                        
                        // Playhead indicator
                        if audioManager.isPlaying {
                            GeometryReader { geometry in
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: 2)
                                    .offset(x: geometry.size.width * audioManager.playheadPosition)
                            }
                        }
                        
                        Text("Audio: \(formatDuration(audioManager.recordingDuration))")
                            .foregroundColor(.blue)
                    }
                    .frame(height: 120)
                    
                    // Control buttons
                    HStack(spacing: 16) {
                        if !showingCropMode {
                            Button("Crop") {
                                // Initialize crop times to full duration
                                cropStartTime = 0
                                cropEndTime = audioManager.recordingDuration
                                showingCropMode = true
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Save Recording") {
                                showingSavePanel = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            if audioManager.hasCropApplied {
                                Button("Reset Crop") {
                                    audioManager.resetToOriginal()
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.orange)
                            }
                        }
                    }
                }
            }
            
            // Crop Controls
            if showingCropMode {
                VStack(spacing: 12) {
                    // Crop info showing actual times
                    VStack(spacing: 8) {
                        HStack {
                            Text("Start: \(formatTime(cropStartTime))")
                            Spacer()
                            Text("End: \(formatTime(cropEndTime))")
                        }
                        Text("Duration: \(formatTime(cropEndTime - cropStartTime))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                    .padding(.horizontal)
                    
                    // Sliders for actual time in seconds
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Time")
                                .font(.caption)
                            Slider(value: $cropStartTime, in: 0...audioManager.recordingDuration)
                                .onChange(of: cropStartTime) { _, newValue in
                                    // Ensure start doesn't go past end
                                    if newValue >= cropEndTime {
                                        cropStartTime = cropEndTime - 0.1
                                    }
                                    // Play from new position if playing
                                    if audioManager.isPlaying {
                                        audioManager.playFromTime(cropStartTime, endTime: cropEndTime)
                                    }
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("End Time")
                                .font(.caption)
                            Slider(value: $cropEndTime, in: 0...audioManager.recordingDuration)
                                .onChange(of: cropEndTime) { _, newValue in
                                    // Ensure end doesn't go before start
                                    if newValue <= cropStartTime {
                                        cropEndTime = cropStartTime + 0.1
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Crop action buttons
                    HStack(spacing: 16) {
                        Button("Reset") {
                            cropStartTime = 0
                            cropEndTime = audioManager.recordingDuration
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Cancel") {
                            showingCropMode = false
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Apply Crop") {
                            // Apply the crop using actual times
                            audioManager.applyCropInSeconds(startTime: cropStartTime, endTime: cropEndTime)
                            showingCropMode = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 600, height: 700)
        .onAppear {
            setupGuide.checkSetup()
        }
        .sheet(isPresented: $showingSetupGuide) {
            SetupGuideView(setupGuide: setupGuide)
        }
        .fileExporter(
            isPresented: $showingSavePanel,
            document: audioManager.recordedAudioURL.map { WaveformDocument(url: $0) },
            contentType: .wav,
            defaultFilename: "audio_sample_\(Int(Date().timeIntervalSince1970))"
        ) { result in
            switch result {
            case .success(let url):
                audioManager.statusMessage = "Saved to: \(url.lastPathComponent)"
            case .failure(let error):
                audioManager.statusMessage = "Save failed: \(error.localizedDescription)"
            }
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        return String(format: "%0.1fs", seconds)
    }
    
    private func formatDuration(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let ms = Int((seconds.truncatingRemainder(dividingBy: 1)) * 10)
        if mins > 0 {
            return String(format: "%d:%02d.%d", mins, secs, ms)
        } else {
            return String(format: "%d.%ds", secs, ms)
        }
    }
}

struct WaveformDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.wav] }
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    init(configuration: ReadConfiguration) throws {
        throw CocoaError(.fileReadCorruptFile)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // Ensure we export at 44.1 kHz
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("export_44100_\(Date().timeIntervalSince1970).wav")
        
        do {
            let inputFile = try AVAudioFile(forReading: url)
            let inputFormat = inputFile.processingFormat
            
            // If already 44.1 kHz, just copy
            if inputFormat.sampleRate == 44100 {
                return try FileWrapper(url: url)
            }
            
            // Otherwise, use optimized chunk-based resampling
            try AudioProcessor.resampleAudioInChunks(from: url, to: tempURL)
            
            return try FileWrapper(url: tempURL)
            
        } catch {
            // Fallback to original file
            return try FileWrapper(url: url)
        }
    }
}

// MARK: - Optimized Audio Manager
class AudioManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var statusMessage = "Ready to record"
    @Published var recordedAudioURL: URL?
    @Published var recordingDuration: Double = 10.0
    @Published var playheadPosition: Double = 0
    @Published var hasCropApplied: Bool = false
    @Published var waveformSamples: [Float] = []
    
    private var audioEngine: AVAudioEngine?
    private var audioPlayer: AVAudioPlayer?
    private var recordingStartTime: Date?
    private var playbackTimer: Timer?
    private var originalRecordingDuration: Double = 10.0
    private var playbackEndPosition: Double? = nil
    private var originalRecordingURL: URL?
    private var originalDuration: Double = 10.0
    
    // Optimized buffer size
    private let optimalBufferSize: AVAudioFrameCount = 512
    
    // Track temporary files for cleanup
    private var temporaryFiles: Set<URL> = []
    
    deinit {
        // Cleanup temporary files
        for url in temporaryFiles {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    func startRecording() {
        statusMessage = "Recording..."
        isRecording = true
        recordingStartTime = Date()
        
        Task {
            await startBlackHoleRecording()
        }
    }
    
    func stopRecording() {
        isRecording = false
        
        if let engine = audioEngine {
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
        }
        audioEngine = nil
        
        statusMessage = "Recording saved"
    }
    
    private func startBlackHoleRecording() async {
        // Reset audio engine
        if let engine = audioEngine {
            if engine.isRunning {
                engine.stop()
            }
            engine.inputNode.removeTap(onBus: 0)
        }
        audioEngine = nil
        
        // Small delay for cleanup
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Find BlackHole device using consolidated helper
        guard let blackHoleDevice = AudioDeviceHelper.findBlackHoleDevice() else {
            await MainActor.run {
                statusMessage = "BlackHole not found. Please run Quick Setup."
                isRecording = false
            }
            return
        }
        
        print("Found BlackHole device ID: \(blackHoleDevice)")
        
        // Set as system input
        AudioDeviceHelper.setSystemInputDevice(blackHoleDevice)
        print("Set BlackHole as system input device")
        
        // Create new audio engine
        let engine = AVAudioEngine()
        self.audioEngine = engine
        
        // Get input format
        let inputNode = engine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        
        // Validate format
        guard inputFormat.sampleRate > 0 && inputFormat.channelCount > 0 else {
            await MainActor.run {
                statusMessage = "Audio format error. Please restart the app."
                isRecording = false
            }
            return
        }
        
        // Create recording file
        let fileName = "recording_\(Date().timeIntervalSince1970).wav"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        temporaryFiles.insert(fileURL)
        
        do {
            let audioFile = try AVAudioFile(forWriting: fileURL, settings: inputFormat.settings)
            
            // Install tap with optimized buffer size
            inputNode.installTap(onBus: 0, bufferSize: optimalBufferSize, format: inputFormat) { buffer, time in
                do {
                    try audioFile.write(from: buffer)
                } catch {
                    // Silent error handling
                }
            }
            
            // Start engine
            try engine.start()
            
            // Record for 5 minutes (300 seconds) or until stopped
            for _ in 0..<3000 {
                if !isRecording { break }
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            }
            
            // Stop recording
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
            
            let actualDuration = Date().timeIntervalSince(recordingStartTime ?? Date())
            
            await MainActor.run {
                self.recordedAudioURL = fileURL
                self.recordingDuration = min(actualDuration, 300.0) // 5 minutes max
                self.originalRecordingDuration = self.recordingDuration
                self.originalRecordingURL = fileURL
                self.originalDuration = self.recordingDuration
                self.hasCropApplied = false
                self.statusMessage = "Recording complete!"
                self.isRecording = false
            }
            
            // Generate waveform data
            await generateWaveform(from: fileURL)
            
        } catch {
            await MainActor.run {
                self.statusMessage = "Recording failed: \(error.localizedDescription)"
                self.isRecording = false
            }
        }
    }
    
    func playFromPosition(_ position: Double) {
        playFromPositionWithEnd(position, end: nil)
    }
    
    func playFromTime(_ startTime: Double, endTime: Double? = nil) {
        guard let url = recordedAudioURL else { return }
        
        do {
            // Stop current playback
            audioPlayer?.stop()
            playbackTimer?.invalidate()
            
            // Create new player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            
            // For cropped audio, the file starts at 0
            // For uncropped audio, start at the specified time
            let playbackStart = hasCropApplied ? 0 : startTime
            
            // Calculate end position and validate
            if let endTime = endTime {
                // Ensure end time is after start time
                if endTime <= startTime && !hasCropApplied {
                    statusMessage = "Invalid crop range"
                    return
                }
                
                if hasCropApplied {
                    // For cropped audio, always play the entire file
                    playbackEndPosition = recordingDuration
                } else {
                    // For preview mode, store the actual end time in seconds
                    playbackEndPosition = endTime
                }
            } else {
                playbackEndPosition = nil
            }
            
            // Prepare audio player for better timing accuracy
            audioPlayer?.prepareToPlay()
            audioPlayer?.currentTime = playbackStart
            
            // Small delay to ensure audio system is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                self?.audioPlayer?.play()
                self?.isPlaying = true
                self?.statusMessage = "Playing..."
                self?.startPlaybackTimer()
            }
            
        } catch {
            statusMessage = "Playback failed: \(error.localizedDescription)"
        }
    }
    
    func playFromPositionWithEnd(_ position: Double, end: Double?) {
        guard let url = recordedAudioURL else { return }
        
        do {
            // Stop current playback
            audioPlayer?.stop()
            playbackTimer?.invalidate()
            
            // Create new player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            
            // Calculate actual times
            let startTime = position * recordingDuration
            let endTime = end != nil ? end! * recordingDuration : nil
            
            // Validate range
            if let endT = endTime, endT <= startTime {
                statusMessage = "Invalid playback range"
                return
            }
            
            // Store end position for playback limiting (in seconds)
            playbackEndPosition = endTime
            
            // Prepare and set position
            audioPlayer?.prepareToPlay()
            audioPlayer?.currentTime = startTime
            
            // Small delay to ensure audio system is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                self?.audioPlayer?.play()
                self?.isPlaying = true
                self?.statusMessage = "Playing..."
                self?.startPlaybackTimer()
            }
            
        } catch {
            statusMessage = "Playback failed: \(error.localizedDescription)"
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        statusMessage = "Paused"
        playbackTimer?.invalidate()
        playbackEndPosition = nil
    }
    
    func applyCropInSeconds(startTime: Double, endTime: Double) {
        guard let recordedURL = recordedAudioURL else { return }
        
        statusMessage = "Applying crop..."
        
        Task {
            do {
                // Convert seconds to normalized positions for the crop function
                let start = startTime / recordingDuration
                let end = endTime / recordingDuration
                
                let croppedURL = try await AudioProcessor.cropAudio(
                    from: recordedURL,
                    start: start,
                    end: end,
                    originalDuration: recordingDuration
                )
                
                temporaryFiles.insert(croppedURL)
                
                await MainActor.run {
                    recordedAudioURL = croppedURL
                    // Update with the new duration
                    recordingDuration = endTime - startTime
                    
                    hasCropApplied = true
                    statusMessage = "Crop applied! Duration: \(String(format: "%.1f", recordingDuration))s"
                    
                    // Reset playback position since the cropped audio now starts at 0
                    playheadPosition = 0
                    playbackEndPosition = nil
                }
                
                // Regenerate waveform for cropped audio
                await generateWaveform(from: croppedURL)
                
            } catch {
                await MainActor.run {
                    statusMessage = "Crop failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func applyCrop(start: Double, end: Double) {
        guard let recordedURL = recordedAudioURL else { return }
        
        statusMessage = "Applying crop..."
        
        Task {
            do {
                let croppedURL = try await AudioProcessor.cropAudio(
                    from: recordedURL,
                    start: start,
                    end: end,
                    originalDuration: recordingDuration
                )
                
                temporaryFiles.insert(croppedURL)
                
                // Calculate the new duration before updating recordingDuration
                let currentDuration = self.recordingDuration
                
                await MainActor.run {
                    recordedAudioURL = croppedURL
                    
                    // Get the actual duration of the cropped file
                    if let croppedFile = try? AVAudioFile(forReading: croppedURL) {
                        let actualDuration = Double(croppedFile.length) / croppedFile.processingFormat.sampleRate
                        recordingDuration = actualDuration
                        print("Crop applied: calculated duration: \(currentDuration * (end - start))s, actual duration: \(actualDuration)s")
                    } else {
                        recordingDuration = currentDuration * (end - start)
                    }
                    
                    hasCropApplied = true
                    statusMessage = "Crop applied! Duration: \(String(format: "%.1f", recordingDuration))s"
                    
                    // Reset playback position since the cropped audio now starts at 0
                    playheadPosition = 0
                    playbackEndPosition = nil
                }
                
                // Regenerate waveform for cropped audio
                await generateWaveform(from: croppedURL)
                
            } catch {
                await MainActor.run {
                    statusMessage = "Crop failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func startPlaybackTimer() {
        playbackTimer?.invalidate()
        
        // Use single-fire timer for end position if available
        if let endPos = self.playbackEndPosition, let player = self.audioPlayer {
            let currentTime = player.currentTime
            let duration = endPos - currentTime
            
            if duration > 0 {
                // Create a single-fire timer for precise stopping
                Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                    // Add a small check to ensure we're still playing
                    if self.isPlaying {
                        player.stop()
                        self.isPlaying = false
                        self.statusMessage = "Playback complete"
                        self.playheadPosition = 0
                        self.playbackEndPosition = nil
                    }
                }
            }
        }
        
        // UI update timer - 60fps for smoother playhead movement
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            if let player = self.audioPlayer {
                // Calculate position based on current playback time
                let currentTime = player.currentTime
                let newPosition = currentTime / self.recordingDuration
                
                // Safety check: stop if we've exceeded end position
                if let endPos = self.playbackEndPosition {
                    if currentTime >= endPos - 0.01 { // Small buffer for precision
                        if self.isPlaying {
                            player.stop()
                            self.isPlaying = false
                            self.statusMessage = "Playback complete"
                            self.playbackTimer?.invalidate()
                            self.playheadPosition = 0
                            self.playbackEndPosition = nil
                        }
                        return
                    }
                }
                
                // Only update if significant change
                if abs(newPosition - self.playheadPosition) > 0.01 {
                    self.playheadPosition = newPosition
                }
            }
        }
    }
    
    func resetToOriginal() {
        guard let originalURL = originalRecordingURL else { return }
        
        // Stop any playback
        audioPlayer?.stop()
        playbackTimer?.invalidate()
        isPlaying = false
        
        // Restore original recording
        recordedAudioURL = originalURL
        recordingDuration = originalDuration
        originalRecordingDuration = originalDuration
        hasCropApplied = false
        
        statusMessage = "Crop removed - original audio restored"
        
        // Regenerate waveform for original audio
        Task {
            await generateWaveform(from: originalURL)
        }
    }
    
    // MARK: - Waveform Generation
    private func generateWaveform(from url: URL) async {
        do {
            let file = try AVAudioFile(forReading: url)
            let format = file.processingFormat
            let frameCount = UInt32(file.length)
            
            // Target number of samples for display (adjust based on UI width)
            let targetSamples = 300
            let samplesPerPixel = max(1, Int(frameCount) / targetSamples)
            
            // Read audio data
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
            try file.read(into: buffer)
            
            guard let floatData = buffer.floatChannelData else { return }
            let channelData = floatData[0] // Use first channel
            
            var waveform: [Float] = []
            
            // Process audio data in chunks to get peak values
            for i in stride(from: 0, to: Int(frameCount), by: samplesPerPixel) {
                let end = min(i + samplesPerPixel, Int(frameCount))
                var peak: Float = 0
                
                for j in i..<end {
                    let sample = abs(channelData[j])
                    if sample > peak {
                        peak = sample
                    }
                }
                
                waveform.append(peak)
            }
            
            // Normalize the waveform (0-1 range)
            let maxPeak = waveform.max() ?? 1.0
            if maxPeak > 0 {
                waveform = waveform.map { $0 / maxPeak }
            }
            
            await MainActor.run {
                self.waveformSamples = waveform
            }
            
        } catch {
            print("Error generating waveform: \(error)")
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        statusMessage = "Playback complete"
        playbackTimer?.invalidate()
        playheadPosition = 0
        playbackEndPosition = nil
    }
}

// MARK: - Consolidated Audio Device Helper
struct AudioDeviceHelper {
    static func findBlackHoleDevice() -> AudioDeviceID? {
        let devices = getAudioDevices()
        
        for deviceID in devices {
            if let name = getDeviceName(deviceID), name.contains("BlackHole") {
                return deviceID
            }
        }
        
        return nil
    }
    
    static func setSystemInputDevice(_ deviceID: AudioDeviceID) {
        var deviceID = deviceID
        let propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0, nil,
            propertySize,
            &deviceID
        )
    }
    
    private static func getAudioDevices() -> [AudioDeviceID] {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var dataSize: UInt32 = 0
        AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0, nil,
            &dataSize
        )
        
        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = Array(repeating: AudioDeviceID(0), count: deviceCount)
        
        AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0, nil,
            &dataSize,
            &deviceIDs
        )
        
        return deviceIDs
    }
    
    private static func getDeviceName(_ deviceID: AudioDeviceID) -> String? {
        var name: CFString = "" as CFString
        var dataSize = UInt32(MemoryLayout<CFString>.size)
        
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0, nil,
            &dataSize,
            &name
        )
        
        return status == noErr ? name as String : nil
    }
}

// MARK: - Audio Processing Utilities
struct AudioProcessor {
    // Chunk-based resampling for memory efficiency
    static func resampleAudioInChunks(from inputURL: URL, to outputURL: URL) throws {
        let inputFile = try AVAudioFile(forReading: inputURL)
        let inputFormat = inputFile.processingFormat
        
        guard inputFormat.sampleRate != 44100 else {
            try FileManager.default.copyItem(at: inputURL, to: outputURL)
            return
        }
        
        let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 44100,
            channels: inputFormat.channelCount,
            interleaved: false
        )!
        
        let outputFile = try AVAudioFile(forWriting: outputURL, settings: outputFormat.settings)
        let converter = AVAudioConverter(from: inputFormat, to: outputFormat)!
        
        let chunkSize: AVAudioFrameCount = 8192
        let inputBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: chunkSize)!
        let outputBuffer = AVAudioPCMBuffer(
            pcmFormat: outputFormat,
            frameCapacity: AVAudioFrameCount(Double(chunkSize) * 44100.0 / inputFormat.sampleRate)
        )!
        
        while inputFile.framePosition < inputFile.length {
            let framesToRead = min(chunkSize, AVAudioFrameCount(inputFile.length - inputFile.framePosition))
            try inputFile.read(into: inputBuffer, frameCount: framesToRead)
            
            var error: NSError?
            converter.convert(to: outputBuffer, error: &error) { inNumPackets, outStatus in
                outStatus.pointee = .haveData
                return inputBuffer
            }
            
            if let error = error { throw error }
            try outputFile.write(from: outputBuffer)
        }
    }
    
    // Optimized crop function
    static func cropAudio(from url: URL, start: Double, end: Double, originalDuration: Double) async throws -> URL {
        let audioFile = try AVAudioFile(forReading: url)
        let format = audioFile.processingFormat
        let totalFrames = audioFile.length
        
        let startFrame = AVAudioFramePosition(Double(totalFrames) * start)
        let endFrame = AVAudioFramePosition(Double(totalFrames) * end)
        let framesToRead = endFrame - startFrame
        
        let croppedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("cropped_\(Date().timeIntervalSince1970).wav")
        
        let outputFile = try AVAudioFile(forWriting: croppedURL, settings: format.settings)
        
        // Process in chunks for large files
        let chunkSize: AVAudioFrameCount = 8192
        var remainingFrames = framesToRead
        audioFile.framePosition = startFrame
        
        while remainingFrames > 0 {
            let framesToProcess = min(chunkSize, AVAudioFrameCount(remainingFrames))
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: framesToProcess)!
            
            try audioFile.read(into: buffer, frameCount: framesToProcess)
            try outputFile.write(from: buffer)
            
            remainingFrames -= AVAudioFramePosition(framesToProcess)
        }
        
        return croppedURL
    }
}

// MARK: - Waveform View
struct WaveformView: View {
    let samples: [Float]
    let color: Color = .blue
    @Binding var playheadPosition: Double
    let isPlaying: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Waveform bars
                HStack(spacing: 1) {
                    ForEach(0..<samples.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(color.opacity(0.7))
                            .frame(height: geometry.size.height * CGFloat(samples[index]))
                    }
                }
                
                // Playhead
                if isPlaying && playheadPosition > 0 {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2)
                        .position(x: geometry.size.width * CGFloat(playheadPosition), y: geometry.size.height / 2)
                }
            }
        }
    }
}

// MARK: - Setup Guide Manager
class SetupGuideManager: ObservableObject {
    @Published var setupStatus = SetupResult()
    
    func checkSetup() {
        setupStatus = QuickSetupHelper.performQuickSetup()
    }
}

struct SetupResult {
    var blackHoleInstalled = false
    var blackHoleAsInput = false
    
    var isFullySetup: Bool {
        return blackHoleInstalled && blackHoleAsInput
    }
}


struct QuickSetupHelper {
    static func performQuickSetup() -> SetupResult {
        var result = SetupResult()
        
        // Check if BlackHole is installed
        result.blackHoleInstalled = AudioDeviceHelper.findBlackHoleDevice() != nil
        
        // Set BlackHole as input if found
        if result.blackHoleInstalled {
            if let blackHoleID = AudioDeviceHelper.findBlackHoleDevice() {
                AudioDeviceHelper.setSystemInputDevice(blackHoleID)
                result.blackHoleAsInput = true
            }
        }
        
        return result
    }
}

// Extension to support .wav UTType
extension UTType {
    static let wav = UTType(filenameExtension: "wav")!
}

// MARK: - Setup Guide View
struct SetupGuideView: View {
    @ObservedObject var setupGuide: SetupGuideManager
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Setup Guide")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            
            // Progress indicator
            HStack(spacing: 10) {
                ForEach(0..<5) { step in
                    Circle()
                        .fill(currentStep >= step ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            
            // Step content
            TabView(selection: $currentStep) {
                // Step 1: Check BlackHole
                VStack(spacing: 20) {
                    Image(systemName: setupGuide.setupStatus.blackHoleInstalled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(setupGuide.setupStatus.blackHoleInstalled ? .green : .red)
                    
                    Text("Step 1: Install BlackHole")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("BlackHole is a virtual audio driver that allows the app to capture system audio.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    if setupGuide.setupStatus.blackHoleInstalled {
                        Text("✅ BlackHole is installed")
                            .foregroundColor(.green)
                    } else {
                        VStack(spacing: 10) {
                            Text("❌ BlackHole not found")
                                .foregroundColor(.red)
                            
                            Link("Download BlackHole", destination: URL(string: "https://existential.audio/blackhole/")!)
                                .buttonStyle(.borderedProminent)
                            
                            Text("Choose the 2-channel version")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tag(0)
                .padding()
                
                // Step 2: Create Multi-Output Device
                VStack(spacing: 20) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Step 2: Create Multi-Output Device")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("This allows you to hear audio while recording:")
                            .fontWeight(.medium)
                        
                        Text("1. Open Audio MIDI Setup (in /Applications/Utilities/)")
                        Text("2. Click the + button at bottom left")
                        Text("3. Select 'Create Multi-Output Device'")
                        Text("4. Check both:")
                        Text("   • Your speakers (e.g., MacBook Air Speakers)")
                            .padding(.leading)
                        Text("   • BlackHole 2ch")
                            .padding(.leading)
                        Text("5. Rename it (e.g., 'Sampler by G.O.E.')")
                    }
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .tag(1)
                .padding()
                
                // Step 3: Configure System Output
                VStack(spacing: 20) {
                    Image(systemName: "speaker.zzz.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Step 3: Set System Output")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Configure your Mac to use the Multi-Output Device:")
                            .fontWeight(.medium)
                        
                        Text("1. Open System Settings > Sound")
                        Text("2. Click the Output tab")
                        Text("3. Select your Multi-Output Device")
                        Text("   (e.g., 'Sampler by G.O.E.')")
                    }
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    Text("This sends audio to both your speakers AND BlackHole")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .tag(2)
                .padding()
                
                // Step 4: Configure System Input
                VStack(spacing: 20) {
                    Image(systemName: setupGuide.setupStatus.blackHoleAsInput ? "checkmark.circle.fill" : "mic.fill")
                        .font(.system(size: 60))
                        .foregroundColor(setupGuide.setupStatus.blackHoleAsInput ? .green : .orange)
                    
                    Text("Step 4: Set System Input")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if setupGuide.setupStatus.blackHoleAsInput {
                        Text("✅ BlackHole is set as input")
                            .foregroundColor(.green)
                    } else {
                        VStack(spacing: 10) {
                            Text("Set BlackHole as the recording input:")
                                .fontWeight(.medium)
                            
                            Text("1. In System Settings > Sound")
                            Text("2. Click the Input tab")
                            Text("3. Select 'BlackHole 2ch'")
                            
                            Text("- OR -")
                                .padding(.vertical, 5)
                            
                            Button("Auto-Configure Input") {
                                if let blackHoleID = AudioDeviceHelper.findBlackHoleDevice() {
                                    AudioDeviceHelper.setSystemInputDevice(blackHoleID)
                                    setupGuide.checkSetup()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .tag(3)
                .padding()
                
                // Step 5: Test Recording
                VStack(spacing: 20) {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Step 5: Test Recording")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("You're all set! Let's test:")
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. Play audio from any app (Spotify, YouTube, etc.)")
                        Text("2. Click Record in this app")
                        Text("3. Stop recording after a few seconds")
                        Text("4. Click Play to hear your recording")
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    
                    Button("Start Recording") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .tag(4)
                .padding()
            }
            .frame(height: 400)
            
            // Navigation buttons
            HStack {
                Button("Previous") {
                    withAnimation {
                        currentStep = max(0, currentStep - 1)
                    }
                }
                .disabled(currentStep == 0)
                
                Spacer()
                
                Button(currentStep < 4 ? "Next" : "Done") {
                    withAnimation {
                        if currentStep < 4 {
                            currentStep += 1
                        } else {
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 600, height: 650)
        .onAppear {
            setupGuide.checkSetup()
        }
    }
}
