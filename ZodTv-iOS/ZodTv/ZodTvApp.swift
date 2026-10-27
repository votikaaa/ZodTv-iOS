//
//  ZodTvApp.swift
//  ZodTv
//
//  iOS Application Entry Point
//

import SwiftUI
import AVFoundation

@main
struct ZodTvApp: App {
    init() {
        // Configure AVAudioSession for background audio and cinema playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
