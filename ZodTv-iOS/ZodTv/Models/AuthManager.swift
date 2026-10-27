//
//  AuthManager.swift
//  ZodTv
//
//  Exact 1:1 replica of Android AuthManager.kt
//

import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    private let prefs = UserDefaults.standard
    private let tokenKey = "zodtv_token"
    private let usernameKey = "zodtv_username"
    private let isGuestKey = "zodtv_is_guest"
    private let favoritesKey = "zodtv_favorites"
    private let historyKey = "zodtv_history"
    
    private init() {}
    
    func saveAuth(response: AuthResponse) {
        prefs.setValue(response.token, forKey: tokenKey)
        prefs.setValue(response.username, forKey: usernameKey)
        prefs.setValue(false, forKey: isGuestKey)
    }
    
    func setGuestMode() {
        prefs.setValue(true, forKey: isGuestKey)
        prefs.removeObject(forKey: tokenKey)
        prefs.setValue("Guest", forKey: usernameKey)
    }
    
    func getToken() -> String? {
        return prefs.string(forKey: tokenKey)
    }
    
    func getUsername() -> String {
        return prefs.string(forKey: usernameKey) ?? "Guest"
    }
    
    func isGuest() -> Bool {
        return prefs.bool(forKey: isGuestKey)
    }
    
    func isLoggedIn() -> Bool {
        return getToken() != nil
    }
    
    func logout() {
        prefs.removeObject(forKey: tokenKey)
        prefs.removeObject(forKey: usernameKey)
        prefs.removeObject(forKey: isGuestKey)
    }
    
    // MARK: - Favorites
    func getFavorites() -> [MediaItem] {
        guard let data = prefs.data(forKey: favoritesKey),
              let items = try? JSONDecoder().decode([MediaItem].self, from: data) else {
            return []
        }
        return items
    }
    
    func isFavorite(item: MediaItem) -> Bool {
        let favs = getFavorites()
        return favs.contains(where: { $0.id == item.id })
    }
    
    func toggleFavorite(item: MediaItem) {
        var favs = getFavorites()
        if let idx = favs.firstIndex(where: { $0.id == item.id }) {
            favs.remove(at: idx)
        } else {
            favs.insert(item, at: 0)
        }
        if let encoded = try? JSONEncoder().encode(favs) {
            prefs.setValue(encoded, forKey: favoritesKey)
        }
    }
    
    // MARK: - Watch History
    func getHistory() -> [MediaItem] {
        guard let data = prefs.data(forKey: historyKey),
              let items = try? JSONDecoder().decode([MediaItem].self, from: data) else {
            return []
        }
        return items
    }
    
    func saveHistory(item: MediaItem, position: Int64, duration: Int64) {
        var hist = getHistory()
        var updatedItem = item
        updatedItem.lastPosition = position
        updatedItem.totalDuration = duration
        
        hist.removeAll(where: { $0.id == item.id })
        hist.insert(updatedItem, at: 0)
        
        // Keep last 50 items
        if hist.count > 50 {
            hist = Array(hist.prefix(50))
        }
        
        if let encoded = try? JSONEncoder().encode(hist) {
            prefs.setValue(encoded, forKey: historyKey)
        }
    }
}
