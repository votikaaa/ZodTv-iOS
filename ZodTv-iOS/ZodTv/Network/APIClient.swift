//
//  APIClient.swift
//  ZodTv
//
//  Network Manager with async/await, matching Android ApiClient
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    let baseURL = "https://zodaq.in/ak/"
    let musicBaseURL = "https://zodaq.in/ak/songs/"
    
    private let defaultUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36"
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    func createRequest(url: URL, method: String = "GET", body: Data? = nil, customHeaders: [String: String]? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(defaultUserAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let customHeaders = customHeaders {
            for (key, value) in customHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
    
    func fetch<T: Codable>(endpoint: String, isMusic: Bool = false, queryItems: [URLQueryItem]? = nil) async throws -> T {
        let base = isMusic ? musicBaseURL : baseURL
        guard var components = URLComponents(string: base + endpoint) else {
            throw URLError(.badURL)
        }
        
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    func fetchDirect<T: Codable>(fullUrl: String) async throws -> T {
        guard let url = URL(string: fullUrl) else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    func fetchRawString(endpoint: String) async throws -> String {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, _) = try await session.data(for: request)
        return String(data: data, encoding: .utf8) ?? ""
    }

    func post<T: Codable, B: Codable>(endpoint: String, body: B, token: String? = nil) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(body)
        
        var customHeaders: [String: String] = [:]
        if let token = token {
            customHeaders["Authorization"] = token
        }
        
        let request = createRequest(url: url, method: "POST", body: bodyData, customHeaders: customHeaders)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
