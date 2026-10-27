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

// MARK: - Home Feed Response
struct HomeFeedResponse: Codable {
    let success: Bool?
    let data: HomeFeedData?
    let error: String?
}

struct HomeFeedData: Codable {
    let slider: [MediaItem]?
    let latest: [MediaItem]?
    let turkishSeries: [MediaItem]?
    let arabicSeries: [MediaItem]?
    let foreignSeries: [MediaItem]?
    let foreignMovies: [MediaItem]?
    let arabicMovies: [MediaItem]?
    let animationMovies: [MediaItem]?
    let ramadan2026: [MediaItem]?

    enum CodingKeys: String, CodingKey {
        case slider, latest
        case turkishSeries = "turkish_series"
        case arabicSeries = "arabic_series"
        case foreignSeries = "foreign_series"
        case foreignMovies = "foreign_movies"
        case arabicMovies = "arabic_movies"
        case animationMovies = "animation_movies"
        case ramadan2026 = "ramadan_2026"
    }
}

// MARK: - Media Item
struct MediaItem: Codable, Identifiable, Hashable {
    var id: String {
        return url ?? itemId ?? title + (year ?? "")
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
    let type: String?
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
        case imageFullAlt = "imageFull"
        case backdropUrl
        case episodeCount
        case parentUrl
        case lastPosition
        case totalDuration
        case parentTitle
        case seasonNumber
        case episodeNumber
    }

    init(
        title: String,
        url: String? = nil,
        itemId: String? = nil,
        image: String? = nil,
        imageFull: String? = nil,
        backdropUrl: String? = nil,
        rating: String? = nil,
        quality: String? = nil,
        year: String? = nil,
        tags: [String]? = nil,
        type: String? = nil,
        episodeCount: String? = nil,
        parentUrl: String? = nil,
        lastPosition: Int64? = nil,
        totalDuration: Int64? = nil,
        parentTitle: String? = nil,
        seasonNumber: Int? = nil,
        episodeNumber: Int? = nil
    ) {
        self.title = title
        self.url = url
        self.itemId = itemId
        self.image = image
        self.imageFull = imageFull
        self.backdropUrl = backdropUrl
        self.rating = rating
        self.quality = quality
        self.year = year
        self.tags = tags
        self.type = type
        self.episodeCount = episodeCount
        self.parentUrl = parentUrl
        self.lastPosition = lastPosition
        self.totalDuration = totalDuration
        self.parentTitle = parentTitle
        self.seasonNumber = seasonNumber
        self.episodeNumber = episodeNumber
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = (try? container.decode(String.self, forKey: .title)) ?? ""
        self.url = try? container.decode(String.self, forKey: .url)
        
        // Flexible ID (Int or String)
        if let idStr = try? container.decode(String.self, forKey: .itemId) {
            self.itemId = idStr
        } else if let idInt = try? container.decode(Int.self, forKey: .itemId) {
            self.itemId = "\(idInt)"
        } else {
            self.itemId = nil
        }
        
        self.image = try? container.decode(String.self, forKey: .image)
        self.imageFull = (try? container.decode(String.self, forKey: .imageFull)) ?? (try? container.decode(String.self, forKey: .imageFullAlt))
        self.backdropUrl = try? container.decode(String.self, forKey: .backdropUrl)
        
        // Flexible Rating (String, Double, Int)
        if let rStr = try? container.decode(String.self, forKey: .rating) {
            self.rating = rStr
        } else if let rDbl = try? container.decode(Double.self, forKey: .rating) {
            self.rating = String(format: "%.1f", rDbl)
        } else {
            self.rating = nil
        }
        
        self.quality = try? container.decode(String.self, forKey: .quality)
        
        // Flexible Year (String, Int)
        if let yStr = try? container.decode(String.self, forKey: .year) {
            self.year = yStr
        } else if let yInt = try? container.decode(Int.self, forKey: .year) {
            self.year = "\(yInt)"
        } else {
            self.year = nil
        }
        
        self.tags = try? container.decode([String].self, forKey: .tags)
        self.type = try? container.decode(String.self, forKey: .type)
        self.episodeCount = try? container.decode(String.self, forKey: .episodeCount)
        self.parentUrl = try? container.decode(String.self, forKey: .parentUrl)
        self.lastPosition = try? container.decode(Int64.self, forKey: .lastPosition)
        self.totalDuration = try? container.decode(Int64.self, forKey: .totalDuration)
        self.parentTitle = try? container.decode(String.self, forKey: .parentTitle)
        self.seasonNumber = try? container.decode(Int.self, forKey: .seasonNumber)
        self.episodeNumber = try? container.decode(Int.self, forKey: .episodeNumber)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(itemId, forKey: .itemId)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(imageFull, forKey: .imageFull)
        try container.encodeIfPresent(backdropUrl, forKey: .backdropUrl)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(quality, forKey: .quality)
        try container.encodeIfPresent(year, forKey: .year)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(episodeCount, forKey: .episodeCount)
        try container.encodeIfPresent(parentUrl, forKey: .parentUrl)
        try container.encodeIfPresent(lastPosition, forKey: .lastPosition)
        try container.encodeIfPresent(totalDuration, forKey: .totalDuration)
        try container.encodeIfPresent(parentTitle, forKey: .parentTitle)
        try container.encodeIfPresent(seasonNumber, forKey: .seasonNumber)
        try container.encodeIfPresent(episodeNumber, forKey: .episodeNumber)
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
