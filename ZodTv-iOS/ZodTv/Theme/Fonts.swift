//
//  Fonts.swift
//  ZodTv
//
//  Exact typography matching Android CairoFontFamily and ArefRuqaa
//

import SwiftUI

struct AppFont {
    static func cairo(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold:
            return Font.custom("Cairo-Bold", size: size)
        case .black:
            return Font.custom("Cairo-Black", size: size)
        case .medium, .semibold:
            return Font.custom("Cairo-Medium", size: size)
        default:
            return Font.custom("Cairo-Regular", size: size)
        }
    }

    static func arefRuqaa(size: CGFloat, bold: BooleanLiteralType = false) -> Font {
        return Font.custom(bold ? "ArefRuqaa-Bold" : "ArefRuqaa-Regular", size: size)
    }
}

// SwiftUI View Modifier for Cairo Font
extension View {
    func appFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.font(AppFont.cairo(size: size, weight: weight))
    }
}
