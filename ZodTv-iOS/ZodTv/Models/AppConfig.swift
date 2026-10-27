//
//  AppConfig.swift
//  ZodTv
//
//  Exact 1:1 replica of Android AppConfig.kt
//

import Foundation

struct AppConfig: Codable {
    var maintenanceMode: Bool = false
    var maintenanceMessage: String = "التطبيق في صيانة حالياً، سنعود قريباً!"
    var forceUpdate: Bool = false
    var latestVersion: String = "1.0"
    var updateUrl: String = ""
    var notificationTitle: String = ""
    var notificationMessage: String = ""
    var showMoviesAndSeries: Bool = true
    var mainProvider: String = "arabseed"
    var arabseedUrl: String = "https://arabseed.me"
    var cartoonUrl: String = "https://www.arabic-toons.com"
    var disableMovies: Bool = false
    var disableSeries: Bool = false
    var disableRamadan: Bool = false
    var disableAnime: Bool = false
    var disableCartoon: Bool = false
    var disableSearch: Bool = false
    var disableTurkish: Bool = false
    var disableLive: Bool = false
    var enableMatchEmbeds: Bool = true
    var matchEmbeds: [MatchEmbedChannel] = []

    enum CodingKeys: String, CodingKey {
        case maintenanceMode, maintenanceMessage, forceUpdate, latestVersion, updateUrl
        case notificationTitle, notificationMessage, showMoviesAndSeries
        case mainProvider = "main_provider"
        case arabseedUrl = "arabseed_url"
        case cartoonUrl = "cartoon_url"
        case disableMovies = "disable_movies"
        case disableSeries = "disable_series"
        case disableRamadan = "disable_ramadan"
        case disableAnime = "disable_anime"
        case disableCartoon = "disable_cartoon"
        case disableSearch = "disable_search"
        case disableTurkish = "disable_turkish"
        case disableLive = "disable_live"
        case enableMatchEmbeds = "enable_match_embeds"
        case matchEmbeds = "match_embeds"
    }
}

struct MatchEmbedChannel: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let url: String
    let serversCount: Int
    let logo: String?

    enum CodingKeys: String, CodingKey {
        case id, name, url, logo
        case serversCount = "servers_count"
    }

    var cleanName: String {
        return name
            .replacingOccurrences(of: #"\s*\([^)]*سيرفر[^)]*\)?"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s*\([^)]*البث[^)]*\)?"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s*\(\s*\d+\s*[^)]*\)?"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
