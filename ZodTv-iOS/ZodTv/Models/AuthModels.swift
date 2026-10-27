//
//  AuthModels.swift
//  ZodTv
//
//  Exact 1:1 replica of Android AuthModels.kt & DeviceStatusResponse.kt
//

import Foundation

struct DeviceStatusResponse: Codable {
    let status: String?
    let message: String?
}

struct LoginRequest: Codable {
    let username: String
    let password: String
    let deviceId: String?

    init(username: String, password: String, deviceId: String? = nil) {
        self.username = username
        self.password = password
        self.deviceId = deviceId
    }
}

struct RegisterRequest: Codable {
    let username: String
    let password: String
    let deviceId: String?

    init(username: String, password: String, deviceId: String? = nil) {
        self.username = username
        self.password = password
        self.deviceId = deviceId
    }
}

struct AuthResponse: Codable {
    let status: String?
    let message: String?
    let token: String?
    let username: String?
    let error: String?
}

struct WatchHistoryRequest: Codable {
    let mediaId: String
    let title: String
    let progress: String
    let poster: String?
}

struct WatchHistoryResponse: Codable {
    let mediaId: String
    let title: String
    let progress: String
    let poster: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case mediaId, title, progress, poster
        case updatedAt = "updated_at"
    }
}

struct UserStatusResponse: Codable {
    let username: String?
    let points: Int?
    let isBanned: Bool?
    let history: [WatchHistoryResponse]?

    enum CodingKeys: String, CodingKey {
        case username, points
        case isBanned = "is_banned"
        case history
    }
}
