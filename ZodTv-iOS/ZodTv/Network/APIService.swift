//
//  APIService.swift
//  ZodTv
//
//  API Service definitions matching Android ApiService.kt
//

import Foundation
import UIKit

class APIService {
    static let shared = APIService()
    private let client = APIClient.shared
    
    // MARK: - Check Device
    func checkDevice(deviceId: String) async -> DeviceStatusResponse? {
        let deviceName = "\(UIDevice.current.model) - iOS \(UIDevice.current.systemVersion)"
        let queryItems = [
            URLQueryItem(name: "deviceId", value: deviceId),
            URLQueryItem(name: "deviceName", value: deviceName),
            URLQueryItem(name: "deviceType", value: "هاتف"),
            URLQueryItem(name: "androidVersion", value: "iOS \(UIDevice.current.systemVersion)"),
            URLQueryItem(name: "appVersion", value: "1.1")
        ]
        
        do {
            return try await client.fetch(endpoint: "bot/bot.php?action=check_device", queryItems: queryItems)
        } catch {
            print("checkDevice error: \(error)")
            return nil
        }
    }
    
    // MARK: - App Config
    func getAppConfig() async -> AppConfig {
        do {
            let timestamp = Int(Date().timeIntervalSince1970 * 1000)
            let query = [URLQueryItem(name: "t", value: "\(timestamp)")]
            return try await client.fetch(endpoint: "config.json", queryItems: query)
        } catch {
            print("getAppConfig error: \(error)")
            return AppConfig()
        }
    }
    
    // MARK: - Movies
    func getMovies(page: Int = 1, category: String = "", section: String = "", year: String = "", rating: String = "", provider: String? = nil) async throws -> MediaResponse {
        var query = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "section", value: section),
            URLQueryItem(name: "year", value: year),
            URLQueryItem(name: "rating", value: rating)
        ]
        if let provider = provider, !provider.isEmpty {
            query.append(URLQueryItem(name: "provider", value: provider))
        }
        return try await client.fetch(endpoint: "apiv2.php?action=movies", queryItems: query)
    }
    
    // MARK: - Series
    func getSeries(page: Int = 1, category: String = "", section: String = "", year: String = "", rating: String = "", provider: String? = nil) async throws -> MediaResponse {
        var query = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "section", value: section),
            URLQueryItem(name: "year", value: year),
            URLQueryItem(name: "rating", value: rating)
        ]
        if let provider = provider, !provider.isEmpty {
            query.append(URLQueryItem(name: "provider", value: provider))
        }
        return try await client.fetch(endpoint: "apiv2.php?action=series", queryItems: query)
    }
    
    // MARK: - Search
    func search(query: String, page: Int = 1) async throws -> MediaResponse {
        let queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        return try await client.fetch(endpoint: "apiv2.php?action=search", queryItems: queryItems)
    }
    
    // MARK: - Categories
    func getCategories(provider: String? = nil) async throws -> CategoriesResponse {
        var query: [URLQueryItem] = []
        if let provider = provider {
            query.append(URLQueryItem(name: "provider", value: provider))
        }
        return try await client.fetch(endpoint: "apiv2.php?action=categories", queryItems: query)
    }
    
    // MARK: - Turkish Content
    func getTurkishContent(page: Int = 1, type: String = "series") async throws -> MediaResponse {
        let query = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "type", value: type)
        ]
        return try await client.fetch(endpoint: "apiv2.php?action=turkish", queryItems: query)
    }
    
    // MARK: - Movie Details
    func getMovieDetails(url: String) async throws -> MovieDetailsResponse {
        return try await client.fetchDirect(fullUrl: url)
    }
    
    // MARK: - Series Details
    func getSeriesDetails(url: String) async throws -> SeriesDetailsResponse {
        return try await client.fetchDirect(fullUrl: url)
    }
    
    // MARK: - Episode Details
    func getEpisodeDetails(url: String) async throws -> EpisodeDetailsResponse {
        return try await client.fetchDirect(fullUrl: url)
    }
    
    // MARK: - Video URL & Sources
    func getVideo(url: String) async throws -> VideoResponse {
        return try await client.fetchDirect(fullUrl: url)
    }
    
    // MARK: - Extra Servers
    func getExtraServers(title: String, type: String = "movie", episode: Int? = nil, season: Int? = nil, year: String? = nil, source: String? = nil) async throws -> ExtraServersResponse {
        var query = [
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "type", value: type)
        ]
        if let ep = episode { query.append(URLQueryItem(name: "episode", value: "\(ep)")) }
        if let se = season { query.append(URLQueryItem(name: "season", value: "\(se)")) }
        if let yr = year { query.append(URLQueryItem(name: "year", value: yr)) }
        if let src = source { query.append(URLQueryItem(name: "source", value: src)) }
        
        return try await client.fetch(endpoint: "apiv2.php?action=extra_servers", queryItems: query)
    }
    
    // MARK: - Matches
    func getMatches(date: String? = nil) async throws -> MatchResponse {
        var query = [
            URLQueryItem(name: "t", value: "\(Int(Date().timeIntervalSince1970 * 1000))")
        ]
        if let date = date {
            query.append(URLQueryItem(name: "date", value: date))
        }
        return try await client.fetch(endpoint: "matchapi.php?action=matches", isMusic: true, queryItems: query)
    }
    
    // MARK: - TV Channels (JSON parsing)
    func getTvChannels() async throws -> [ChannelCategory] {
        let rawJs = try await client.fetchRawString(endpoint: "tv.js?t=\(Int(Date().timeIntervalSince1970 * 1000))")
        
        // Remove javascript variable wrapping if present: window.tvData = {...} or var channels = [...]
        var cleanJson = rawJs.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanJson.hasPrefix("window.tvData = ") {
            cleanJson = String(cleanJson.dropFirst("window.tvData = ".count))
        } else if cleanJson.hasPrefix("var channels = ") {
            cleanJson = String(cleanJson.dropFirst("var channels = ".count))
        }
        if cleanJson.hasSuffix(";") {
            cleanJson = String(cleanJson.dropLast())
        }
        
        guard let data = cleanJson.data(using: .utf8) else { return [] }
        
        // Parse channels JSON structure
        var categoriesList: [ChannelCategory] = []
        if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            for (categoryName, channelsRaw) in jsonObject {
                if let channelArray = channelsRaw as? [[String: Any]] {
                    var items: [ChannelItem] = []
                    for c in channelArray {
                        let name = c["name"] as? String ?? ""
                        let url = c["url"] as? String ?? ""
                        let logo = c["logo"] as? String
                        let userAgent = c["userAgent"] as? String
                        let referer = c["referer"] as? String
                        if !name.isEmpty && !url.isEmpty {
                            items.append(ChannelItem(name: name, url: url, logo: logo, category: categoryName, userAgent: userAgent, referer: referer, headers: nil))
                        }
                    }
                    if !items.isEmpty {
                        categoriesList.append(ChannelCategory(id: categoryName, name: categoryName, channels: items))
                    }
                }
            }
        }
        return categoriesList
    }
    
    // MARK: - Auth
    func login(req: LoginRequest) async throws -> AuthResponse {
        return try await client.post(endpoint: "bot/bot.php?action=login", body: req)
    }
    
    func register(req: RegisterRequest) async throws -> AuthResponse {
        return try await client.post(endpoint: "bot/bot.php?action=register", body: req)
    }
    
    func reportIssue(token: String, title: String, url: String, type: String = "channel") async {
        let query = [
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "url", value: url),
            URLQueryItem(name: "type", value: type)
        ]
        do {
            let _: String = try await client.fetch(endpoint: "bot/bot.php?action=report", queryItems: query)
        } catch {
            print("reportIssue error: \(error)")
        }
    }
}
