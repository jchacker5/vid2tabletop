import SwiftUI
import RealityKit
import AVKit
import YouTubeiOSPlayerHelper

struct ContentView: View {
    @State private var youtubeURL: String = ""
    @State private var isProcessing: Bool = false
    @State private var processingProgress: Double = 0
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var courtScale: Float = 0.1
    @State private var showSettings = false
    
    private let courtVisualizer = CourtVisualizer.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header
                Text("Vid2Tabletop")
                    .font(.largeTitle)
                    .padding()
                
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        // URL Input Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NBA Game YouTube URL")
                                .font(.headline)
                            
                            TextField("https://youtube.com/watch?v=...", text: $youtubeURL)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal)
                        
                        // Processing Status
                        if isProcessing {
                            VStack(spacing: 12) {
                                ProgressView(value: processingProgress) {
                                    Text("Processing Video")
                                        .font(.subheadline)
                                }
                                
                                Text("\(Int(processingProgress * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Error Display
                        if showError {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red.opacity(0.1))
                                )
                                .padding(.horizontal)
                        }
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            Button(action: processVideo) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("Convert to Tabletop")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(youtubeURL.isEmpty || isProcessing)
                            
                            Button(action: { showSettings.toggle() }) {
                                Image(systemName: "gear")
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        
                        // 3D Court View
                        RealityView { content in
                            Task {
                                try? await courtVisualizer.setupCourt(in: content)
                            }
                        }
                        .frame(height: 400)
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    courtScale = Float(value.magnification) * 0.1
                                }
                        )
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onChange(of: processingProgress) { newValue in
                if newValue >= 1.0 {
                    withAnimation {
                        isProcessing = false
                        processingProgress = 0
                    }
                }
            }
        }
    }
    
    private func processVideo() {
        isProcessing = true
        showError = false
        processingProgress = 0
        
        Task {
            do {
                try await VideoProcessingService.shared.processYouTubeVideo(url: youtubeURL) { progress in
                    processingProgress = progress
                }
            } catch VideoProcessingError.invalidURL {
                showError = true
                errorMessage = "Invalid YouTube URL. Please check the URL and try again."
            } catch VideoProcessingError.downloadFailed {
                showError = true
                errorMessage = "Failed to download video. Please check your internet connection."
            } catch VideoProcessingError.processingFailed {
                showError = true
                errorMessage = "Failed to process video. Please try a different video."
            } catch {
                showError = true
                errorMessage = "An unexpected error occurred. Please try again."
            }
            isProcessing = false
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("courtColor") private var courtColor: Color = .white
    @AppStorage("playerColor") private var playerColor: Color = .blue
    @AppStorage("showTrajectories") private var showTrajectories = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Court Appearance") {
                    ColorPicker("Court Color", selection: $courtColor)
                    ColorPicker("Player Color", selection: $playerColor)
                }
                
                Section("Visualization") {
                    Toggle("Show Player Trajectories", isOn: $showTrajectories)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
} 