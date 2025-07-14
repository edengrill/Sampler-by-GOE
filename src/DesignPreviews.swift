import SwiftUI

// Crystal Cove: Layered glass, deep ocean gradients, floating panels
struct CrystalCovePreview: View {
    var body: some View {
        ZStack {
            // Ocean gradient background
            LinearGradient(
                colors: [Color(red: 0, green: 0.2, blue: 0.4), Color(red: 0, green: 0.7, blue: 0.7)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Blurred glass background layer
            RoundedRectangle(cornerRadius: 40)
                .fill(.ultraThinMaterial)
                .frame(width: 380, height: 520)
                .shadow(color: .blue.opacity(0.2), radius: 30, y: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.white.opacity(0.25), lineWidth: 2)
                )
            
            // Floating glass control panel
            VStack(spacing: 32) {
                Text("🎵 Simple Audio Sampler")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 8)
                // Ocean wave waveform
                WaveShape()
                    .fill(LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 60)
                    .shadow(color: .cyan.opacity(0.4), radius: 10, y: 8)
                // Gel button
                Button(action: {}) {
                    Text("Record")
                        .font(.headline)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                                )
                                .shadow(color: .blue.opacity(0.3), radius: 10, y: 4)
                        )
                        .overlay(
                            Capsule()
                                .fill(LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
                                .blur(radius: 2)
                        )
                }
            }
            .frame(width: 340)
        }
    }
}

// Aqua Aurora: Aurora gradients, glowing glass, floating orbs
struct AquaAuroraPreview: View {
    var body: some View {
        ZStack {
            // Animated aurora gradient background
            LinearGradient(
                colors: [Color(red: 0, green: 0.8, blue: 1), Color(red: 0.4, green: 0.2, blue: 1), Color(red: 0, green: 1, blue: 0.7)],
                startPoint: .top, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating glass orbs
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 120)
                .blur(radius: 2)
                .offset(x: -100, y: -180)
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 80)
                .blur(radius: 1)
                .offset(x: 120, y: 160)
            
            // Main glass panel
            VStack(spacing: 28) {
                Text("Aqua Aurora")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(color: .blue.opacity(0.5), radius: 8)
                // Neon waveform
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [.cyan, .blue, .purple], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 8)
                    .shadow(color: .cyan.opacity(0.7), radius: 16)
                // Glowing gel button
                Button(action: {}) {
                    Text("Play")
                        .font(.headline)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 14)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .cyan.opacity(0.5), radius: 16)
                        )
                        .overlay(
                            Circle()
                                .stroke(LinearGradient(colors: [.white.opacity(0.7), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 2)
                        )
                }
            }
            .padding(40)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 36))
            .shadow(color: .blue.opacity(0.2), radius: 20, y: 10)
        }
    }
}

// Vista Lagoon: Minimal glass, lagoon gradients, pill controls
struct VistaLagoonPreview: View {
    var body: some View {
        ZStack {
            // Lagoon gradient background with caustic effect
            LinearGradient(
                colors: [Color(red: 0, green: 0.6, blue: 1), Color(red: 0.4, green: 1, blue: 0.8)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Main glass card
            VStack(spacing: 24) {
                Text("Vista Lagoon")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 6)
                // Minimal waveform
                Capsule()
                    .fill(LinearGradient(colors: [.mint, .cyan], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 10)
                    .shadow(color: .mint.opacity(0.4), radius: 8)
                // Pill glassy controls
                HStack(spacing: 20) {
                    GlassPillButton(title: "Record", color: .red)
                    GlassPillButton(title: "Save", color: .blue)
                }
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
            .shadow(color: .cyan.opacity(0.18), radius: 18, y: 8)
        }
    }
}

// Helper components
struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: .zero)
            for x in stride(from: 0, to: rect.width, by: 1) {
                let y = 0.5 * rect.height + 0.4 * rect.height * sin((x / rect.width) * 2 * .pi)
                p.addLine(to: CGPoint(x: x, y: y))
            }
            p.addLine(to: CGPoint(x: rect.width, y: rect.height))
            p.addLine(to: CGPoint(x: 0, y: rect.height))
            p.closeSubpath()
        }
    }
}

struct GlassPillButton: View {
    let title: String
    let color: Color
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(color: color.opacity(0.3), radius: 8, y: 2)
            )
            .overlay(
                Capsule()
                    .fill(LinearGradient(colors: [.white.opacity(0.25), .clear], startPoint: .top, endPoint: .bottom))
                    .blur(radius: 1)
            )
    }
}

// Main app to preview all three designs
@main
struct DesignPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                CrystalCovePreview()
                    .tabItem { Label("Crystal Cove", systemImage: "1.circle") }
                    .frame(width: 600, height: 700)
                
                AquaAuroraPreview()
                    .tabItem { Label("Aqua Aurora", systemImage: "2.circle") }
                    .frame(width: 600, height: 700)
                
                VistaLagoonPreview()
                    .tabItem { Label("Vista Lagoon", systemImage: "3.circle") }
                    .frame(width: 600, height: 700)
            }
            .frame(width: 600, height: 750)
        }
    }
}