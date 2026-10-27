//
//  NetflixBottomBar.swift
//  ZodTv
//
//  Exact 1:1 replica of Android NetflixBottomBar from MainActivity.kt
//

import SwiftUI

enum MainTab: String, CaseIterable {
    case home = "home"
    case explore = "explore"
    case library = "library"
    case more = "more"
    case account = "account"
    
    var title: String {
        switch self {
        case .home: return "الرئيسية"
        case .explore: return "اكتشف"
        case .library: return "قائمتي"
        case .more: return "المزيد"
        case .account: return "حسابي"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .explore: return "safari.fill"
        case .library: return "bookmark.fill"
        case .more: return "square.grid.2x2.fill"
        case .account: return "person.crop.circle.fill"
        }
    }
}

struct NetflixBottomBar: View {
    @Binding var selectedTab: MainTab
    
    var body: some View {
        VStack(spacing: 0) {
            // 0.5dp Subtle Divider matching Android
            Rectangle()
                .fill(Color(hex: 0x1E1E24))
                .frame(height: 0.5)
            
            HStack(spacing: 0) {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    let isSelected = selectedTab == tab
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            ZStack {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.bronzeSurface)
                                        .frame(width: 44, height: 28)
                                }
                                Image(systemName: tab.iconName)
                                    .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? AppColors.bronzeGold : AppColors.textMuted)
                            }
                            
                            Text(tab.title)
                                .font(AppFont.cairo(size: 11, weight: isSelected ? .bold : .regular))
                                .foregroundColor(isSelected ? AppColors.bronzeGold : AppColors.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 56)
            .padding(.horizontal, 4)
            .background(Color.black)
        }
        .background(Color.black.ignoresSafeArea(edges: .bottom))
    }
}
