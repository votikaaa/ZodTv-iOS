//
//  Models.swift
//  ZodTv
//
//  Exact 1:1 replica of Android Models.kt
//

import Foundation

// MARK: - Media Response
struct MediaResponse: Codable {
    let success: Bool?
    let data: MediaData?
    let error: String?
}

struct MediaData: Codable {
    let items: [MediaItem]?
    let totalPages: Int?
    let currentPage: Int?
    let count: Int?
}

// MARK: - Media Item
struct MediaItem: Codable, Identifiable, Hashable {
    var id: String {
        return url ?? title + (year ?? "")
    }
    
    let title: String
    let url: String?
    let itemId: String?
    let image: String?
    let imageFull: String?
    let backdropUrl: String?
    let rating: String?
    let quality: String?
    let year: String?
    let tags: [String]?
    let type: String? // "movie", "series", "anime", etc.
    let episodeCount: String?
    let parentUrl: String?
    var lastPosition: Int64?
    var totalDuration: Int64?
    let parentTitle: String?
    let seasonNumber: Int?
    let episodeNumber: Int?

    enum CodingKeys: String, CodingKey {
        case title, url, rating, quality, year, tags, type
        case itemId = "id"
        case image
        case imageFull = "image_full"
        case backdropUrl
        case episodeCount
        case parentUrl
        case lastPosition
        case totalDuration
        case parentTitle
        case seasonNumber
        case episodeNumber
    }

    var displayImage: String {
        return imageFull ?? image ?? ""
    }
}

// MARK: - Movie Details
struct MovieDetailsResponse: Codable {
    let success: Bool?
    let data: MovieDetails?
    let error: String?
}

struct MovieDetails: Codable {
    let type: String?
    let title: String?
    let description: String?
    let poster: String?
    let posterThumb: String?
    let rating: String?
    let year: String?
    let duration: String?
    let language: String?
    let quality: String?
    let country: String?
    let categories: [String]?
    let trailer: String?
    let trailerUrl: String?
    let youtube: String?
    let links: [MediaLink]?
    let gallery: [String]?
    let cast: [CastMember]?

    enum CodingKeys: String, CodingKey {
        case type, title, description, poster, rating, year, duration, language, quality, country, categories, trailer, youtube, links, gallery, cast
        case posterThumb = "poster_thumb"
        case trailerUrl = "trailer_url"
    }
}

// MARK: - Series Details
struct SeriesDetailsResponse: Codable {
    let success: Bool?
    let data: SeriesDetails?
    let error: String?
}

struct SeriesDetails: Codable {
    let type: String?
    let title: String?
    let description: String?
    let poster: String?
    let posterThumb: String?
    let rating: String?
    let year: String?
    let status: String?
    let categories: [String]?
    let trailer: String?
    let trailerUrl: String?
    let youtube: String?
    let cast: [CastMember]?
    let episodes: [Episode]?
    let episodeCount: Int?
    let seasons: [Season]?

    enum CodingKeys: String, CodingKey {
        case type, title, description, poster, rating, year, status, categories, trailer, youtube, cast, episodes, seasons
        case posterThumb = "poster_thumb"
        case trailerUrl = "trailer_url"
        case episodeCount
    }
}

// MARK: - Season & Episode
struct Season: Codable, Identifiable, Hashable {
    var id: String { seasonId ?? "\(number)" }
    let seasonId: String?
    let number: Int
    let title: String
    let url: String?
    let isCurrent: Bool?
    let source: String?

    enum CodingKeys: String, CodingKey {
        case seasonId = "id"
        case number, title, url
        case isCurrent = "is_current"
        case source
    }
}

struct Episode: Codable, Identifiable, Hashable {
    let id: String
    let url: String?
    let title: String
    let date: String?
    let thumbnail: String?
}

// MARK: - Cast Member
struct CastMember: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let url: String
    let image: String?
}

// MARK: - Media Links & Extra Servers
struct MediaLink: Codable, Identifiable, Hashable {
    var id: String { linkId.isEmpty ? watchUrl : linkId }
    let linkId: String
    let watchUrl: String
    let downloadUrl: String
    let size: String?
    let quality: String?
    let referer: String?
    let origin: String?
}

struct ExtraServersResponse: Codable {
    let success: Bool?
    let data: [MediaLink]?
    let error: String?
}

// MARK: - Video Details & Sources
struct VideoResponse: Codable {
    let success: Bool?
    let data: VideoData?
    let error: String?
}

struct VideoData: Codable {
    let videoUrl: String?
    let title: String?
    let poster: String?
    let sources: [VideoSource]?
}

struct VideoSource: Codable, Identifiable, Hashable {
    var id: String { url }
    let url: String
    let type: String
    let quality: String?
}

// MARK: - Episode Details
struct EpisodeDetailsResponse: Codable {
    let success: Bool?
    let data: EpisodeDetails?
    let error: String?
}

struct EpisodeDetails: Codable {
    let type: String?
    let title: String?
    let seriesUrl: String?
    let seriesTitle: String?
    let prevEpisode: String?
    let nextEpisode: String?
    let description: String?
    let poster: String?
    let posterThumb: String?
    let rating: String?
    let categories: [String]?
    let links: [MediaLink]?

    enum CodingKeys: String, CodingKey {
        case type, title, seriesUrl, seriesTitle, prevEpisode, nextEpisode, description, poster, rating, categories, links
        case posterThumb = "poster_thumb"
    }
}

// MARK: - Categories
struct CategoryItem: Codable, Identifiable, Hashable {
    var id: String { slug ?? catId ?? name }
    let name: String
    let slug: String?
    let catId: String?

    enum CodingKeys: String, CodingKey {
        case name, slug
        case catId = "id"
    }
}

struct CategoriesResponse: Codable {
    let success: Bool?
    let provider: String?
    let data: [String: [CategoryItem]]?
    let error: String?
}

// MARK: - Live TV Channel Models
struct ChannelCategory: Identifiable, Hashable {
    let id: String
    let name: String
    let channels: [ChannelItem]
}

struct ChannelItem: Codable, Identifiable, Hashable {
    var id: String { "\(name)_\(url)" }
    let name: String
    let url: String
    let logo: String?
    let category: String?
    let userAgent: String?
    let referer: String?
    let headers: [String: String]?
}
