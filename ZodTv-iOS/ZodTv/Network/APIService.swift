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
    @MainActor
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
    
    // MARK: - Home Feed
    func getHomeFeed() async throws -> HomeFeedResponse {
        return try await client.fetch(endpoint: "apiv2.php?action=home")
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
    
    // MARK: - TV Categories & Matching (Exact Android Parity)
    static let tvCategories = [
        "الكل",
        "beIN SPORTS",
        "قنوات رياضية",
        "ALKASS",
        "beIN ترفيهية",
        "سيرفر الأسطورة",
        "أخبار",
        "قنوات مصرية",
        "قنوات عربية",
        "دينية وإسلامية",
        "أطفال",
        "أفلام ومسلسلات",
        "وثائقية",
        "قنوات خليجية",
        "المغرب العربي",
        "الشام والعراق",
        "موسيقى وأغاني",
        "عالمية وترفيه",
        "بدون فئة"
    ]

    static func matchesCategory(itemCategory: String, targetCategory: String) -> Bool {
        if targetCategory == "الكل" { return true }
        if itemCategory.caseInsensitiveCompare(targetCategory) == .orderedSame { return true }
        let item = itemCategory.lowercased()
        switch targetCategory {
        case "beIN SPORTS":
            return item.contains("bein sports") || item.contains("بين سبورت") || item.contains("bein sport")
        case "قنوات رياضية":
            return item.contains("رياضية") || item.contains("sports") || item.contains("sport") || item.contains("alkass") || item.contains("الكأس") || item.contains("ssc") || item.contains("on time")
        case "ALKASS", "الكأس":
            return item.contains("alkass") || item.contains("الكأس")
        case "beIN ترفيهية":
            return item.contains("bein entertainment") || item.contains("بين ترفيهية")
        case "سيرفر الأسطورة":
            return item.contains("الأسطورة") || item.contains("ostora")
        case "أخبار":
            return item.contains("أخبار") || item.contains("news") || item.contains("الجزيرة") || item.contains("العربية") || item.contains("حدث")
        case "قنوات مصرية":
            return item.contains("مصرية") || item.contains("egypt") || item.contains("egypte") || item.contains("dmc") || item.contains("on e") || item.contains("cbc")
        case "قنوات عربية":
            return item.contains("عربية") || item.contains("arabic") || item.contains("mbc") || item.contains("rotana")
        case "دينية وإسلامية":
            return item.contains("دينية") || item.contains("إسلامية") || item.contains("قرآن") || item.contains("religious") || item.contains("quran") || item.contains("مكة") || item.contains("المدينة")
        case "أطفال":
            return item.contains("أطفال") || item.contains("kids") || item.contains("animation") || item.contains("كرتون") || item.contains("spacetoon") || item.contains("سبيستون") || item.contains("cn")
        case "أفلام ومسلسلات":
            return item.contains("أفلام") || item.contains("مسلسلات") || item.contains("movies") || item.contains("series") || item.contains("cinema") || item.contains("سينما")
        case "وثائقية":
            return item.contains("وثائقية") || item.contains("documentary") || item.contains("nat geo") || item.contains("ناشيونال")
        case "قنوات خليجية":
            return item.contains("خليجية") || item.contains("gulf") || item.contains("saudi") || item.contains("uea") || item.contains("kwt") || item.contains("دبي")
        case "المغرب العربي":
            return item.contains("المغرب") || item.contains("algeria") || item.contains("tunisia") || item.contains("morocco") || item.contains("الجزائر") || item.contains("تونس")
        case "الشام والعراق":
            return item.contains("الشام") || item.contains("العراق") || item.contains("syria") || item.contains("lebanon") || item.contains("iraq") || item.contains("سوريا") || item.contains("لبنان")
        case "موسيقى وأغاني":
            return item.contains("موسيقية") || item.contains("music") || item.contains("أغاني") || item.contains("غنائية")
        case "عالمية وترفيه":
            return item.contains("عالمية") || item.contains("ترفيهية") || item.contains("entertainment") || item.contains("france") || item.contains("turkish") || item.contains("osn")
        case "بدون فئة":
            return true
        default:
            return item.contains(targetCategory.lowercased())
        }
    }

    // MARK: - TV Channels (Full JSON Parsing)
    func getTvChannels() async throws -> [ChannelCategory] {
        let rawJs = try await client.fetchRawString(endpoint: "tv.js?t=\(Int(Date().timeIntervalSince1970 * 1000))")
        
        var cleanJson = rawJs.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanJson.hasPrefix("window.tvData = ") {
            cleanJson = String(cleanJson.dropFirst("window.tvData = ".count))
        } else if cleanJson.hasPrefix("var channels = ") {
            cleanJson = String(cleanJson.dropFirst("var channels = ".count))
        }
        if cleanJson.hasSuffix(";") {
            cleanJson = String(cleanJson.dropLast())
        }
        
        if let start = cleanJson.firstIndex(of: "["), let end = cleanJson.lastIndex(of: "]") {
            cleanJson = String(cleanJson[start...end])
        }
        
        guard let data = cleanJson.data(using: .utf8) else { return [] }
        
        var allChannels: [ChannelItem] = []
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            for c in jsonArray {
                let name = c["name"] as? String ?? ""
                let url = c["url"] as? String ?? ""
                let logo = c["logo"] as? String ?? c["imageUrl"] as? String
                let cat = c["category"] as? String ?? "عامة"
                let userAgent = c["userAgent"] as? String
                let referer = c["referer"] as? String
                if !name.isEmpty && !url.isEmpty {
                    allChannels.append(ChannelItem(
                        name: name,
                        url: url,
                        logo: logo,
                        category: cat,
                        userAgent: userAgent,
                        referer: referer,
                        headers: nil
                    ))
                }
            }
        } else if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let sources = jsonObject["sources"] as? [[String: Any]] {
                for src in sources {
                    if let cats = src["categories"] as? [[String: Any]] {
                        for cat in cats {
                            let catName = cat["category_name"] as? String ?? "عامة"
                            if let chs = cat["channels"] as? [[String: Any]] {
                                for ch in chs {
                                    let chName = ch["channel_name"] as? String ?? ""
                                    let chLogo = ch["logo"] as? String
                                    if let srvs = ch["servers"] as? [[String: Any]] {
                                        for srv in srvs {
                                            let dUrl = srv["direct_url"] as? String ?? ""
                                            if !dUrl.isEmpty {
                                                allChannels.append(ChannelItem(
                                                    name: chName,
                                                    url: dUrl,
                                                    logo: chLogo,
                                                    category: catName,
                                                    userAgent: srv["user_agent"] as? String,
                                                    referer: srv["referer"] as? String,
                                                    headers: nil
                                                ))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Group allChannels into the 19 standard Android categories
        var categoriesList: [ChannelCategory] = []
        for targetCat in Self.tvCategories {
            if targetCat == "الكل" {
                categoriesList.append(ChannelCategory(id: "all", name: "الكل", channels: Array(allChannels.prefix(400))))
            } else {
                let matched = allChannels.filter { Self.matchesCategory(itemCategory: $0.category ?? "", targetCategory: targetCat) }
                if !matched.isEmpty {
                    categoriesList.append(ChannelCategory(id: targetCat, name: targetCat, channels: matched))
                }
            }
        }
        
        return categoriesList
    }

    // MARK: - Radio Stations
    func getRadioStations() async throws -> [ChannelItem] {
        let rawJs = try await client.fetchRawString(endpoint: "radio.js?t=\(Int(Date().timeIntervalSince1970 * 1000))")
        var cleanJson = rawJs.trimmingCharacters(in: .whitespacesAndNewlines)
        if let start = cleanJson.firstIndex(of: "["), let end = cleanJson.lastIndex(of: "]") {
            cleanJson = String(cleanJson[start...end])
        }
        guard let data = cleanJson.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        
        var stations: [ChannelItem] = []
        for r in jsonArray {
            let name = r["name"] as? String ?? ""
            let url = r["url"] as? String ?? ""
            let logo = r["imageUrl"] as? String ?? r["logo"] as? String
            let cat = r["category"] as? String ?? "إذاعة"
            let ua = r["userAgent"] as? String
            let ref = r["referer"] as? String
            if !name.isEmpty && !url.isEmpty {
                stations.append(ChannelItem(name: name, url: url, logo: logo, category: cat, userAgent: ua, referer: ref, headers: nil))
            }
        }
        return stations
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
