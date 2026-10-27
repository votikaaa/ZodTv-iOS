//
//  DetailsViewModel.swift
//  ZodTv
//
//  Exact 1:1 replica of Android DetailsViewModel.kt
//

import Foundation
import SwiftUI

@MainActor
class DetailsViewModel: ObservableObject {
    @Published var movieDetails: MovieDetails?
    @Published var seriesDetails: SeriesDetails?
    @Published var episodeDetails: EpisodeDetails?
    @Published var selectedSeason: Season?
    @Published var selectedEpisode: Episode?
    @Published var extraServers: [MediaLink] = []
    @Published var similarItems: [MediaItem] = []
    
    @Published var isLoading: Bool = false
    @Published var isFetchingExtraServers: Bool = false
    @Published var isSimilarLoading: Bool = false
    @Published var directVideoUrl: String?
    
    func loadDetails(url: String, type: String) async {
        isLoading = true
        movieDetails = nil
        seriesDetails = nil
        episodeDetails = nil
        extraServers = []
        directVideoUrl = nil
        
        let lowerUrl = url.lowercased()
        let isMovie = type == "movie" || lowerUrl.contains("/movie/") || lowerUrl.contains("/movies/")
        let isEpisode = type == "episode" || lowerUrl.contains("/episode/")
        
        do {
            if isMovie {
                let res = try await APIService.shared.getMovieDetails(url: url)
                self.movieDetails = res.data
                if let title = res.data?.title {
                    await fetchExtraServers(title: title, type: "movie")
                }
            } else if isEpisode {
                let res = try await APIService.shared.getEpisodeDetails(url: url)
                self.episodeDetails = res.data
            } else {
                let res = try await APIService.shared.getSeriesDetails(url: url)
                self.seriesDetails = res.data
                self.selectedSeason = res.data?.seasons?.first
                self.selectedEpisode = res.data?.episodes?.first
            }
        } catch {
            print("loadDetails error: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchExtraServers(title: String, type: String, season: Int? = nil, episode: Int? = nil, year: String? = nil) async {
        isFetchingExtraServers = true
        do {
            let res = try await APIService.shared.getExtraServers(title: title, type: type, episode: episode, season: season, year: year)
            self.extraServers = res.data ?? []
        } catch {
            print("fetchExtraServers error: \(error)")
        }
        isFetchingExtraServers = false
    }
    
    func resolveWatchUrl(link: MediaLink) async -> String? {
        if !link.watchUrl.isEmpty {
            // Check if it's already a direct video stream
            if link.watchUrl.hasSuffix(".mp4") || link.watchUrl.hasSuffix(".m3u8") {
                return link.watchUrl
            }
            // Fetch video endpoint
            do {
                let res = try await APIService.shared.getVideo(url: link.watchUrl)
                if let direct = res.data?.videoUrl, !direct.isEmpty {
                    return direct
                }
                if let firstSource = res.data?.sources?.first?.url, !firstSource.isEmpty {
                    return firstSource
                }
            } catch {
                print("resolveWatchUrl error: \(error)")
            }
        }
        return link.watchUrl
    }
}
