//  SimpleAudioSampler_v2.5_CrystalCove.swift
//  Frutiger Aero "Crystal Cove" Redesign
//  All audio/crop features preserved from v2.4

import SwiftUI
import AVFoundation
import CoreAudio
import UniformTypeIdentifiers

@main
struct SimpleAudioSamplerCrystalCoveApp: App {
    var body: some Scene {
        WindowGroup {
            CrystalCoveContentView()
        }
    }
}

struct CrystalCoveContentView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var setupGuide = SetupGuideManager()
    @State private var showingSavePanel = false
    @State private var showingCropMode = false
    @State private var showingSetupGuide = false
    @State private var cropStartTime: Double = 0
    @State private var cropEndTime: Double = 0
    
    var body: some View {
        ZStack {
            OceanGradientBackground()
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.2), value: showingCropMode)
            
            // Floating glass panels
            VStack(spacing: 32) {
                // Header Glass Panel
                GlassPanel(depth: 2, blur: 32, opacity: 0.35) {
                    VStack(spacing: 6) {
                        Text("🎵 Simple Audio Sampler")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                        Text("v2.5 – Crystal Cove")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                    }
                    .padding(.vertical, 10)
                }
                .frame(width: 420)
                .padding(.top, 16)
                
                // Status Panel
                GlassPanel(depth: 1, blur: 18, opacity: 0.22) {
                    Text(audioManager.statusMessage)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                        .padding(.vertical, 4)
                }
                .frame(width: 340)
                
                // Setup Guide Button
                HStack {
                    GelButton(icon: "questionmark.circle", label: "Setup Guide", style: .secondary) {
                        showingSetupGuide = true
                    }
                    Spacer()
                }
                .frame(width: 340)
                
                // Recording Controls Panel
                GlassPanel(depth: 2, blur: 28, opacity: 0.32) {
                    HStack(spacing: 24) {
                        GelButton(
                            icon: audioManager.isRecording ? "stop.circle.fill" : "circle.fill",
                            label: audioManager.isRecording ? "Stop Recording" : "Record (5 min)",
                            style: audioManager.isRecording ? .danger : .primary
                        ) {
                            if audioManager.isRecording {
                                audioManager.stopRecording()
                            } else {
                                audioManager.startRecording()
                            }
                        }
                        .frame(width: 180)
                        .disabled(audioManager.isPlaying)
                        
                        if let _ = audioManager.recordedAudioURL {
                            GelButton(icon: "play.circle", label: "Play", style: .primary) {
                                if showingCropMode {
                                    audioManager.playFromTime(cropStartTime, endTime: cropEndTime)
                                } else {
                                    audioManager.playFromPosition(0)
                                }
                            }
                            .frame(width: 110)
                            .disabled(audioManager.isRecording)
                            
                            if audioManager.isPlaying {
                                GelButton(icon: "pause.circle", label: "Pause", style: .secondary) {
                                    audioManager.pausePlayback()
                                }
                                .frame(width: 110)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(width: 520)
                
                // Waveform & Controls
                if let _ = audioManager.recordedAudioURL {
                    GlassPanel(depth: 3, blur: 36, opacity: 0.38) {
                        VStack(spacing: 18) {
                            // Ocean Waveform
                            OceanWaveformView(
                                samples: audioManager.waveformSamples,
                                playheadPosition: $audioManager.playheadPosition,
                                isPlaying: audioManager.isPlaying,
                                cropStart: showingCropMode ? cropStartTime / max(audioManager.recordingDuration, 0.01) : nil,
                                cropEnd: showingCropMode ? cropEndTime / max(audioManager.recordingDuration, 0.01) : nil
                            )
                            .frame(height: 140)
                            .padding(.top, 8)
                            .padding(.horizontal, 8)
                            .animation(.easeInOut(duration: 0.7), value: audioManager.waveformSamples)
                            
                            Text("Audio: \(formatDuration(audioManager.recordingDuration))")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.caption)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            
                            // Control Buttons
                            HStack(spacing: 18) {
                                if !showingCropMode {
                                    GelButton(icon: "scissors", label: "Crop", style: .secondary) {
                                        cropStartTime = 0
                                        cropEndTime = audioManager.recordingDuration
                                        showingCropMode = true
                                    }
                                    .frame(width: 90)
                                    
                                    GelButton(icon: "square.and.arrow.down", label: "Save Recording", style: .primary) {
                                        showingSavePanel = true
                                    }
                                    .frame(width: 170)
                                    
                                    if audioManager.hasCropApplied {
                                        GelButton(icon: "arrow.uturn.left", label: "Reset Crop", style: .danger) {
                                            audioManager.resetToOriginal()
                                        }
                                        .frame(width: 110)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    .frame(width: 540)
                }
                
                // Crop Controls
                if showingCropMode {
                    GlassPanel(depth: 2, blur: 24, opacity: 0.32) {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Start: \(formatTime(cropStartTime))")
                                Spacer()
                                Text("End: \(formatTime(cropEndTime))")
                            }
                            .foregroundColor(.white)
                            .font(.caption)
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                            
                            Text("Duration: \(formatTime(cropEndTime - cropStartTime))")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Start Time")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.8))
                                    Slider(value: $cropStartTime, in: 0...audioManager.recordingDuration)
                                        .accentColor(.teal)
                                        .onChange(of: cropStartTime) { _, newValue in
                                            if newValue >= cropEndTime {
                                                cropStartTime = cropEndTime - 0.1
                                            }
                                            if audioManager.isPlaying {
                                                audioManager.playFromTime(cropStartTime, endTime: cropEndTime)
                                            }
                                        }
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("End Time")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.8))
                                    Slider(value: $cropEndTime, in: 0...audioManager.recordingDuration)
                                        .accentColor(.teal)
                                        .onChange(of: cropEndTime) { _, newValue in
                                            if newValue <= cropStartTime {
                                                cropEndTime = cropStartTime + 0.1
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 16) {
                                GelButton(icon: "arrow.counterclockwise", label: "Reset", style: .secondary) {
                                    cropStartTime = 0
                                    cropEndTime = audioManager.recordingDuration
                                }
                                .frame(width: 80)
                                
                                GelButton(icon: "xmark", label: "Cancel", style: .danger) {
                                    showingCropMode = false
                                }
                                .frame(width: 80)
                                
                                GelButton(icon: "checkmark", label: "Apply Crop", style: .primary) {
                                    audioManager.applyCropInSeconds(startTime: cropStartTime, endTime: cropEndTime)
                                    showingCropMode = false
                                }
                                .frame(width: 120)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(width: 480)
                }
                Spacer()
            }
            .padding(.top, 24)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            .animation(.spring(response: 0.7, dampingFraction: 0.85), value: showingCropMode)
        }
        .frame(width: 700, height: 820)
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
        .onAppear {
            setupGuide.checkSetup()
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

// MARK: - Ocean Gradient Background
struct OceanGradientBackground: View {
    @State private var animate = false
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(red: 0.07, green: 0.13, blue: 0.32), location: 0.0), // Deep blue
                .init(color: Color(red: 0.09, green: 0.32, blue: 0.54), location: 0.25),
                .init(color: Color(red: 0.13, green: 0.62, blue: 0.74), location: 0.55),
                .init(color: Color(red: 0.18, green: 0.85, blue: 0.82), location: 0.85), // Teal
                .init(color: Color(red: 0.38, green: 0.98, blue: 0.98), location: 1.0) // Light aqua
            ]),
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .animation(Animation.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
        .onAppear { animate = true }
        .overlay(
            // Subtle animated caustics
            CausticsOverlay()
        )
    }
}

struct CausticsOverlay: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                WaveCausticShape(phase: phase + CGFloat(i) * 1.2, amplitude: 18 + CGFloat(i) * 8, frequency: 1.2 + CGFloat(i) * 0.3)
                    .stroke(Color.white.opacity(0.08 + 0.04 * Double(i)), lineWidth: 2.5 - CGFloat(i) * 0.7)
                    .blur(radius: 6 + CGFloat(i) * 2)
                    .offset(y: CGFloat(i) * 30)
                    .animation(.easeInOut(duration: 7.5).repeatForever(autoreverses: true), value: phase)
            }
        }
        .drawingGroup()
        .onAppear {
            withAnimation(.linear(duration: 7.5).repeatForever(autoreverses: true)) {
                phase = 2 * .pi
            }
        }
    }
}

struct WaveCausticShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var frequency: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = height * 0.5
        let points = 80
        for i in 0...points {
            let x = width * CGFloat(i) / CGFloat(points)
            let y = midY + sin(CGFloat(i) * frequency / CGFloat(points) * 2 * .pi + phase) * amplitude
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}

// MARK: - Glass Panel
struct GlassPanel<Content: View>: View {
    let depth: Int
    let blur: CGFloat
    let opacity: Double
    let content: () -> Content
    
    var body: some View {
        ZStack {
            // Glass background
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(opacity))
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .blur(radius: blur)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.22 + 0.08 * Double(depth)), lineWidth: 1.5 + CGFloat(depth) * 0.5)
                        .shadow(color: .white.opacity(0.18 + 0.06 * Double(depth)), radius: 6 + CGFloat(depth) * 2)
                )
                .shadow(color: Color.black.opacity(0.12 + 0.04 * Double(depth)), radius: 16 + CGFloat(depth) * 4, x: 0, y: 8)
                .background(
                    // Subtle inner shadow
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 8)
                        .blur(radius: 8)
                        .offset(y: 4)
                        .mask(RoundedRectangle(cornerRadius: 28, style: .continuous))
                )
            content()
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
        }
        .compositingGroup()
        .transition(.opacity.combined(with: .scale))
    }
}

// MARK: - Gel Button
enum GelButtonStyle {
    case primary, secondary, danger
}

struct GelButton: View {
    let icon: String?
    let label: String
    let style: GelButtonStyle
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .shadow(color: .white.opacity(0.7), radius: 1, x: 0, y: 1)
                }
                Text(label)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(buttonGradient)
                        .shadow(color: .white.opacity(0.18), radius: 8, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.32), lineWidth: 1.5)
                        )
                    // Inner highlight
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 6)
                        .blur(radius: 4)
                        .offset(y: 2)
                        .mask(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            )
            .overlay(
                // Gel shine
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.32), Color.clear]), startPoint: .top, endPoint: .bottom)
                    )
                    .frame(height: 18)
                    .offset(y: -12)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(0.98)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: style)
    }
    
    private var buttonGradient: LinearGradient {
        switch style {
        case .primary:
            return LinearGradient(gradient: Gradient(colors: [Color.teal.opacity(0.85), Color.blue.opacity(0.85)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        case .secondary:
            return LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.22), Color.teal.opacity(0.32)]), startPoint: .top, endPoint: .bottom)
        case .danger:
            return LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.7), Color.pink.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Ocean Waveform View
struct OceanWaveformView: View {
    let samples: [Float]
    @Binding var playheadPosition: Double
    let isPlaying: Bool
    let cropStart: Double?
    let cropEnd: Double?
    
    @State private var animPhase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Ocean glass background
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .blur(radius: 16)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1.2)
                    )
                
                // Ocean waveform
                if !samples.isEmpty {
                    OceanWaveShape(samples: samples, phase: animPhase)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.7),
                                    Color.teal.opacity(0.7),
                                    Color.blue.opacity(0.7)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .teal.opacity(0.18), radius: 8, x: 0, y: 6)
                        .animation(.easeInOut(duration: 0.7), value: samples)
                        .drawingGroup()
                } else {
                    // Placeholder
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.blue.opacity(0.08))
                }
                
                // Crop overlay
                if let cropStart = cropStart, let cropEnd = cropEnd {
                    let width = geometry.size.width
                    let startX = width * CGFloat(cropStart)
                    let endX = width * CGFloat(cropEnd)
                    Rectangle()
                        .fill(Color.green.opacity(0.18))
                        .frame(width: endX - startX)
                        .offset(x: startX)
                        .animation(.easeInOut(duration: 0.5), value: cropStart)
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 2)
                        .offset(x: startX)
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 2)
                        .offset(x: endX)
                }
                
                // Playhead
                if isPlaying {
                    let width = geometry.size.width
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2)
                        .offset(x: width * CGFloat(playheadPosition))
                        .animation(.linear(duration: 0.1), value: playheadPosition)
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: true)) {
                    animPhase = .pi * 2
                }
            }
        }
    }
}

struct OceanWaveShape: Shape {
    let samples: [Float]
    var phase: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let count = samples.count
        guard count > 1 else { return path }
        let baseY = height * 0.55
        let amplitude = height * 0.38
        let wavePhase = phase
        
        path.move(to: CGPoint(x: 0, y: baseY))
        for i in 0..<count {
            let x = width * CGFloat(i) / CGFloat(count - 1)
            let sample = CGFloat(samples[i])
            // Oceanic undulation: combine sample with sine for fluidity
            let y = baseY - sample * amplitude * (0.7 + 0.3 * sin(CGFloat(i) * 0.12 + wavePhase))
            path.addLine(to: CGPoint(x: x, y: y))
        }
        // Close the path to bottom
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        return path
    }
} 