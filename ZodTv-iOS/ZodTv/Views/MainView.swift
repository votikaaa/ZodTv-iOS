//
//  MainView.swift
//  ZodTv
//
//  Main Navigation Root matching Android MainActivity.kt
//

import SwiftUI

struct MainView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var showSplash: Bool = true
    @State private var selectedMediaForDetails: MediaItem? = nil
    @State private var activeStream: (title: String, url: String, userAgent: String?, referer: String?)? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if showSplash {
                SplashScreen(homeViewModel: homeViewModel) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
            } else {
                HomeScreen(
                    homeViewModel: homeViewModel,
                    onSelectMedia: { media in
                        self.selectedMediaForDetails = media
                    },
                    onSelectChannel: { channel in
                        self.activeStream = (
                            title: channel.name,
                            url: channel.url,
                            userAgent: channel.userAgent,
                            referer: channel.referer
                        )
                    },
                    onSelectMatch: { match in
                        if let url = match.url, !url.isEmpty {
                            self.activeStream = (
                                title: "\(match.teamA) ضد \(match.teamB)",
                                url: url,
                                userAgent: nil,
                                referer: nil
                            )
                        }
                    },
                    onOpenSearch: {},
                    onOpenSettings: {}
                )
            }
        }
        // Media Details Screen Sheet
        .fullScreenCover(item: $selectedMediaForDetails) { item in
            DetailsScreen(
                mediaItem: item,
                onPlayVideo: { title, streamUrl in
                    self.activeStream = (title: title, url: streamUrl, userAgent: nil, referer: nil)
                },
                onBack: {
                    self.selectedMediaForDetails = nil
                }
            )
        }
        // Video Watch Screen Sheet
        .fullScreenCover(isPresented: Binding(
            get: { activeStream != nil },
            set: { if !$0 { activeStream = nil } }
        )) {
            if let stream = activeStream {
                WatchScreen(
                    title: stream.title,
                    streamUrl: stream.url,
                    userAgent: stream.userAgent,
                    referer: stream.referer,
                    onDismiss: {
                        self.activeStream = nil
                    }
                )
            }
        }
        .environment(\.layoutDirection, .rightToLeft) // RTL layout for Arabic interface
        .preferredColorScheme(.dark)
    }
}
