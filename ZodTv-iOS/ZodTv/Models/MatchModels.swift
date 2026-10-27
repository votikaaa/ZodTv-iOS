//
//  MatchModels.swift
//  ZodTv
//
//  Exact 1:1 replica of Android MatchModels.kt
//

import Foundation

struct MatchResponse: Codable {
    let status: String?
    let date: String?
    let leagues: [League]?
}

struct League: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let logo: String
    let matches: [MatchData]

    enum CodingKeys: String, CodingKey {
        case name = "league_name"
        case logo = "league_logo"
        case matches
    }
}

struct MatchData: Codable, Identifiable, Hashable {
    var id: String { "\(teamA)_\(teamB)_\(time)" }
    let teamA: String
    let teamB: String
    let logoA: String
    let logoB: String
    let scoreA: String
    let scoreB: String
    let time: String
    let status: String
    let channel: String
    let url: String?

    enum CodingKeys: String, CodingKey {
        case teamA = "team_a"
        case teamB = "team_b"
        case logoA = "logo_a"
        case logoB = "logo_b"
        case scoreA = "score_a"
        case scoreB = "score_b"
        case time, status, channel, url
    }
}

struct ResolveEmbedResponse: Codable {
    let success: Bool?
    let data: ResolveEmbedData?
    let error: String?
}

struct ResolveEmbedData: Codable {
    let albaplayerBase: String?
    let selectedServer: Int?
    let directSource: String?
    let servers: [EmbedServerItem]?

    enum CodingKeys: String, CodingKey {
        case albaplayerBase = "albaplayer_base"
        case selectedServer = "selected_server"
        case directSource = "direct_source"
        case servers
    }
}

struct EmbedServerItem: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let albaplayerUrl: String
    let directSource: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case albaplayerUrl = "albaplayer_url"
        case directSource = "direct_source"
    }
}
