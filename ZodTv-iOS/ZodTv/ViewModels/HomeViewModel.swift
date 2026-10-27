//
//  HomeViewModel.swift
//  ZodTv
//
//  Exact 1:1 replica of Android HomeViewModel.kt
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var appConfig = AppConfig()
    
    // Featured Hero Slider
    @Published var sliderItems: [MediaItem] = []
    @Published var isFeaturedLoading: Bool = true
    
    // Curated Home Sections (Identical to Android)
    @Published var foreignMovies: [MediaItem] = []
    @Published var arabicMovies: [MediaItem] = []
    @Published var foreignSeries: [MediaItem] = []
    @Published var arabicSeries: [MediaItem] = []
    @Published var turkishSeries: [MediaItem] = []
    @Published var animationMovies: [MediaItem] = []
    @Published var ramadanSeries: [MediaItem] = []
    @Published var latestItems: [MediaItem] = []
    
    // Full categories for Explore Tab
    @Published var moviesItems: [MediaItem] = []
    @Published var seriesItems: [MediaItem] = []
    
    // Live TV & Matches
    @Published var channelCategories: [ChannelCategory] = []
    @Published var isLiveLoading: Bool = false
    @Published var todayMatches: [MatchData] = []
    @Published var isMatchesLoading: Bool = false
    
    // Search
    @Published var searchQuery: String = ""
    @Published var searchResults: [MediaItem] = []
    @Published var isSearching: Bool = false
    
    // History & Favorites
    @Published var continueWatching: [MediaItem] = []
    @Published var favorites: [MediaItem] = []
    
    init() {
        loadContinueWatching()
        loadFavorites()
    }
    
    func refreshAll() async {
        await loadConfig()
        await loadHomeFeed()
        await loadChannels()
        await loadMatches()
    }
    
    func loadConfig() async {
        self.appConfig = await APIService.shared.getAppConfig()
    }
    
    func loadHomeFeed() async {
        isFeaturedLoading = true
        
        do {
            let homeRes = try await APIService.shared.getHomeFeed()
            if let data = homeRes.data {
                self.sliderItems = data.slider ?? []
                self.latestItems = data.latest ?? []
                self.foreignMovies = data.foreignMovies ?? []
                self.arabicMovies = data.arabicMovies ?? []
                self.foreignSeries = data.foreignSeries ?? []
                self.arabicSeries = data.arabicSeries ?? []
                self.turkishSeries = data.turkishSeries ?? []
                self.animationMovies = data.animationMovies ?? []
                self.ramadanSeries = data.ramadan2026 ?? []
                
                // For explore tab fallback
                self.moviesItems = (data.foreignMovies ?? []) + (data.arabicMovies ?? [])
                self.seriesItems = (data.foreignSeries ?? []) + (data.arabicSeries ?? [])
            }
        } catch {
            print("loadHomeFeed error: \(error)")
        }
        
        // If slider is empty, fallback to fetching movies directly
        if self.sliderItems.isEmpty {
            if let moviesRes = try? await APIService.shared.getMovies(page: 1), let items = moviesRes.data?.items {
                self.moviesItems = items
                self.sliderItems = Array(items.prefix(5))
                self.foreignMovies = items
            }
        }
        
        isFeaturedLoading = false
    }
    
    func loadChannels() async {
        isLiveLoading = true
        do {
            self.channelCategories = try await APIService.shared.getTvChannels()
        } catch {
            print("loadChannels error: \(error)")
        }
        isLiveLoading = false
    }
    
    func loadMatches() async {
        isMatchesLoading = true
        do {
            let res = try await APIService.shared.getMatches()
            var matches: [MatchData] = []
            if let leagues = res.leagues {
                for league in leagues {
                    matches.append(contentsOf: league.matches)
                }
            }
            self.todayMatches = matches
        } catch {
            print("loadMatches error: \(error)")
        }
        isMatchesLoading = false
    }
    
    func performSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        isSearching = true
        do {
            let res = try await APIService.shared.search(query: query)
            self.searchResults = res.data?.items ?? []
        } catch {
            print("Search error: \(error)")
        }
        isSearching = false
    }
    
    func loadContinueWatching() {
        self.continueWatching = AuthManager.shared.getHistory()
    }
    
    func loadFavorites() {
        self.favorites = AuthManager.shared.getFavorites()
    }
    
    func toggleFavorite(item: MediaItem) {
        AuthManager.shared.toggleFavorite(item: item)
        loadFavorites()
    }
}
