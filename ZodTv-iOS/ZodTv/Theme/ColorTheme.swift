//
//  ColorTheme.swift
//  ZodTv
//
//  Cinema Premium Palette (Warm Charcoal & Bronze / Champagne Gold)
//  Exact 1:1 replica of Android Color.kt
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct AppColors {
    // ---- Cinema Premium Palette ----
    static let cinemaBlack = Color(hex: 0x09090B)           // Warm deep cinema black base
    static let cinemaDarkCharcoal = Color(hex: 0x121215)    // Dark charcoal for cards and bottom navigation
    static let cinemaSurface = Color(hex: 0x18181D)         // Primary surface container
    static let cinemaSurfaceElevated = Color(hex: 0x22222A) // Elevated pills, dialogs, focused items
    static let cinemaBorder = Color(hex: 0x2B2B36)          // Subtle structural borders
    static let cinemaBorderLight = Color.white.opacity(0.12)// 12% white outline

    // Bronze & Champagne Gold Accents
    static let bronzeGold = Color(hex: 0xDEAC5D)            // Primary gold/bronze CTA & active indicators
    static let bronzeGoldLight = Color(hex: 0xEED09D)       // Champagne gold for highlights
    static let bronzeGoldDark = Color(hex: 0xB8822B)        // Deep bronze
    static let bronzeSurface = Color(hex: 0x2A2014)         // Subtle tinted container for active states

    // Text & Content Hierarchy
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: 0xA1A1AA)
    static let textMuted = Color(hex: 0x71717A)

    // Status & Indicators
    static let ratingGold = Color(hex: 0xFFC107)
    static let successGreen = Color(hex: 0x4ADE80)
    static let errorRed = Color(hex: 0xEF4444)

    // Backwards-Compatible Aliases
    static let orangeAccent = bronzeGold
    static let cardBg = Color(hex: 0x141418)
    static let surfaceColor = Color(hex: 0x1A1A20)
    static let deepBlack = cinemaBlack
    static let glassWhite = Color.white.opacity(0.08)
    static let glassBlack = Color.black.opacity(0.6)
    static let zodRed = Color(hex: 0xD32F2F)
}
