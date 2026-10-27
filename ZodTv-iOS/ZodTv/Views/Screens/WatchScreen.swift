//
//  WatchScreen.swift
//  ZodTv
//
//  Exact 1:1 replica of Android WatchScreen.kt using AVPlayer with custom Cinema Overlay
//

import SwiftUI
import AVKit
import MediaPlayer

struct WatchScreen: View {
    let title: String
    let streamUrl: String
    var userAgent: String? = nil
    var referer: String? = nil
    var onDismiss: () -> Void
    
    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = true
    @State private var showControls: Bool = true
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var isLiveStream: Bool = false
    @State private var controlsTimer: Timer?
    @State private var isLocked: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Video Player Layer
            if let player = player {
                CustomVideoPlayerView(player: player)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showControls.toggle()
                        }
                        resetControlsTimer()
                    }
            } else {
                ProgressView()
                    .tint(AppColors.bronzeGold)
                    .scaleEffect(1.5)
            }
            
            // Custom Cinema Overlay
            if showControls {
                ZStack {
                    // Darkening Vignette
                    Color.black.opacity(0.45).ignoresSafeArea()
                    
                    VStack {
                        // Top Controls Bar
                        topBar
                        
                        Spacer()
                        
                        // Center Play / Pause & Skip
                        centerControls
                        
                        Spacer()
                        
                        // Bottom Progress & Fullscreen
                        bottomBar
                    }
                    .padding()
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            setupPlayer()
            resetControlsTimer()
        }
        .onDisappear {
            player?.pause()
            player = nil
            controlsTimer?.invalidate()
        }
    }
    
    // MARK: - Setup AVPlayer
    private func setupPlayer() {
        guard let url = URL(string: streamUrl) else { return }
        
        var headers: [String: String] = [
            "User-Agent": userAgent ?? "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36"
        ]
        if let referer = referer, !referer.isEmpty {
            headers["Referer"] = referer
        }
        
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let playerItem = AVPlayerItem(asset: asset)
        let avPlayer = AVPlayer(playerItem: playerItem)
        
        // Time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            self.currentTime = time.seconds
            if let dur = avPlayer.currentItem?.duration.seconds, !dur.isNaN && dur > 0 {
                self.duration = dur
                self.isLiveStream = false
            } else {
                self.isLiveStream = true
            }
        }
        
        self.player = avPlayer
        avPlayer.play()
        self.isPlaying = true
    }
    
    private func resetControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            withAnimation {
                showControls = false
            }
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 14) {
            Button(action: onDismiss) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            
            Text(title)
                .font(AppFont.cairo(size: 15, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
            
            if isLiveStream {
                HStack(spacing: 4) {
                    Circle()
                        .fill(AppColors.errorRed)
                        .frame(width: 7, height: 7)
                    Text("بث مباشر")
                        .font(AppFont.cairo(size: 11, weight: .bold))
                        .foregroundColor(AppColors.errorRed)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AppColors.errorRed.opacity(0.2))
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Center Controls
    private var centerControls: some View {
        HStack(spacing: 40) {
            if !isLiveStream {
                // Rewind 10s
                Button(action: {
                    seek(by: -10)
                    resetControlsTimer()
                }) {
                    Image(systemName: "gobackward.10")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
            }
            
            // Play / Pause
            Button(action: {
                if isPlaying {
                    player?.pause()
                } else {
                    player?.play()
                }
                isPlaying.toggle()
                resetControlsTimer()
            }) {
                ZStack {
                    Circle()
                        .fill(AppColors.bronzeGold)
                        .frame(width: 58, height: 58)
                    
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.cinemaBlack)
                }
            }
            
            if !isLiveStream {
                // Forward 10s
                Button(action: {
                    seek(by: 10)
                    resetControlsTimer()
                }) {
                    Image(systemName: "goforward.10")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func seek(by seconds: Double) {
        guard let p = player else { return }
        let newTime = max(0, min(duration, currentTime + seconds))
        p.seek(to: CMTime(seconds: newTime, preferredTimescale: 1000))
    }
    
    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 6) {
            if !isLiveStream && duration > 0 {
                // Seek slider
                Slider(
                    value: Binding(
                        get: { currentTime },
                        set: { newValue in
                            currentTime = newValue
                            player?.seek(to: CMTime(seconds: newValue, preferredTimescale: 1000))
                            resetControlsTimer()
                        }
                    ),
                    in: 0...duration
                )
                .tint(AppColors.bronzeGold)
                
                // Time stamps
                HStack {
                    Text(formatTime(currentTime))
                        .font(AppFont.cairo(size: 11, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text(formatTime(duration))
                        .font(AppFont.cairo(size: 11, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "00:00" }
        let total = Int(seconds)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
}

// Custom AVPlayerLayer UIViewRepresentable
struct CustomVideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        controller.allowsPictureInPicturePlayback = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
