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
    
    // Featured & Carousels
    @Published var featuredMovies: [MediaItem] = []
    @Published var featuredSeries: [MediaItem] = []
    @Published var featuredAnime: [MediaItem] = []
    @Published var isFeaturedLoading: Bool = true
    
    // Rows
    @Published var moviesItems: [MediaItem] = []
    @Published var seriesItems: [MediaItem] = []
    @Published var animeItems: [MediaItem] = []
    @Published var recommendedMovies: [MediaItem] = []
    @Published var recommendedSeries: [MediaItem] = []
    @Published var turkishItems: [MediaItem] = []
    
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
        await loadFeaturedAndRows()
        await loadChannels()
        await loadMatches()
    }
    
    func loadConfig() async {
        self.appConfig = await APIService.shared.getAppConfig()
    }
    
    func loadFeaturedAndRows() async {
        isFeaturedLoading = true
        
        async let moviesTask = try? APIService.shared.getMovies(page: 1)
        async let seriesTask = try? APIService.shared.getSeries(page: 1)
        async let turkishTask = try? APIService.shared.getTurkishContent(page: 1)
        
        let (moviesRes, seriesRes, turkishRes) = await (moviesTask, seriesTask, turkishTask)
        
        if let movies = moviesRes?.data?.items {
            self.moviesItems = movies
            self.featuredMovies = Array(movies.prefix(6))
            self.recommendedMovies = Array(movies.suffix(from: min(6, movies.count)))
        }
        
        if let series = seriesRes?.data?.items {
            self.seriesItems = series
            self.featuredSeries = Array(series.prefix(6))
            self.recommendedSeries = Array(series.suffix(from: min(6, series.count)))
        }
        
        if let turkish = turkishRes?.data?.items {
            self.turkishItems = turkish
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
