//
//  HomeScreen.swift
//  ZodTv
//
//  Exact 1:1 replica of Android HomeScreen.kt with all tabs & features
//

import SwiftUI

struct HomeScreen: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @State private var selectedTab: MainTab = .home
    
    // Navigation callbacks
    var onSelectMedia: (MediaItem) -> Void
    var onSelectChannel: (ChannelItem) -> Void
    var onSelectMatch: (MatchData) -> Void
    var onOpenSearch: () -> Void
    var onOpenSettings: () -> Void
    
    // Explore tab sub-category
    @State private var exploreCategory: String = "movies"
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Cinema Header (on Home and More tabs)
                topHeaderView
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    homeTabView
                        .tag(MainTab.home)
                    
                    exploreTabView
                        .tag(MainTab.explore)
                    
                    libraryTabView
                        .tag(MainTab.library)
                    
                    moreLiveTabView
                        .tag(MainTab.more)
                    
                    accountTabView
                        .tag(MainTab.account)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Exact Bottom Bar
                NetflixBottomBar(selectedTab: $selectedTab)
            }
        }
    }
    
    // MARK: - Top Header
    private var topHeaderView: some View {
        HStack {
            // Brand Logo
            HStack(spacing: 4) {
                Text("ZOD")
                    .font(AppFont.cairo(size: 22, weight: .black))
                    .foregroundColor(Color(hex: 0xE50914))
                Text("TV")
                    .font(AppFont.cairo(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Search Button
            Button(action: {
                selectedTab = .explore
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.bronzeGold)
                    .padding(8)
                    .background(AppColors.cinemaSurfaceElevated)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.95))
    }
    
    // MARK: - 1. Home Tab View
    private var homeTabView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 22) {
                // Hero Banner
                if let featured = homeViewModel.featuredMovies.first {
                    heroBanner(item: featured)
                }
                
                // Today's Matches (if available)
                if !homeViewModel.todayMatches.isEmpty {
                    sectionHeader(title: "مباريات اليوم", count: "\(homeViewModel.todayMatches.count)")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(homeViewModel.todayMatches) { match in
                                MatchCard(match: match) {
                                    onSelectMatch(match)
                                }
                                .frame(width: 280)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // Continue Watching
                if !homeViewModel.continueWatching.isEmpty {
                    sectionHeader(title: "متابعة المشاهدة")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(homeViewModel.continueWatching) { item in
                                MediaCard(item: item, width: 140, height: 210) {
                                    onSelectMedia(item)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // Latest Movies
                if !homeViewModel.moviesItems.isEmpty {
                    sectionHeader(title: "أحدث الأفلام", subtitle: "مشاهدة الكل >")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(homeViewModel.moviesItems) { item in
                                MediaCard(item: item) {
                                    onSelectMedia(item)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // Trending Series
                if !homeViewModel.seriesItems.isEmpty {
                    sectionHeader(title: "مسلسلات شائعة", subtitle: "مشاهدة الكل >")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(homeViewModel.seriesItems) { item in
                                MediaCard(item: item) {
                                    onSelectMedia(item)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // Turkish Series
                if !homeViewModel.turkishItems.isEmpty {
                    sectionHeader(title: "مسلسلات تركية")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(homeViewModel.turkishItems) { item in
                                MediaCard(item: item) {
                                    onSelectMedia(item)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                Spacer().frame(height: 30)
            }
        }
    }
    
    // MARK: - Hero Banner
    private func heroBanner(item: MediaItem) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let imgUrl = item.backdropUrl ?? item.imageFull ?? item.image, let url = URL(string: imgUrl) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle().fill(AppColors.cinemaSurface)
                    }
                }
                .frame(height: 250)
                .clipped()
            }
            
            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Banner Content
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    if let rating = item.rating, !rating.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundColor(AppColors.ratingGold)
                            Text(rating)
                                .font(AppFont.cairo(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    if let quality = item.quality, !quality.isEmpty {
                        Text(quality)
                            .font(AppFont.cairo(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.bronzeGoldDark)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                
                Text(item.title)
                    .font(AppFont.cairo(size: 20, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Button(action: {
                    onSelectMedia(item)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                        Text("مشاهدة الآن")
                            .font(AppFont.cairo(size: 13, weight: .bold))
                    }
                    .foregroundColor(AppColors.cinemaBlack)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(AppColors.bronzeGold)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(16)
        }
        .frame(height: 250)
    }
    
    // MARK: - Section Header
    private func sectionHeader(title: String, subtitle: String? = nil, count: String? = nil) -> some View {
        HStack {
            Text(title)
                .font(AppFont.cairo(size: 16, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            if let count = count {
                Text(count)
                    .font(AppFont.cairo(size: 11, weight: .bold))
                    .foregroundColor(AppColors.bronzeGold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(AppColors.bronzeSurface)
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            if let sub = subtitle {
                Text(sub)
                    .font(AppFont.cairo(size: 12, weight: .medium))
                    .foregroundColor(AppColors.bronzeGold)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - 2. Explore Tab View
    private var exploreTabView: some View {
        VStack(spacing: 12) {
            // Search Input Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textMuted)
                
                TextField("ابحث عن فيلم أو مسلسل أو أنمي...", text: $homeViewModel.searchQuery)
                    .font(AppFont.cairo(size: 13))
                    .foregroundColor(.white)
                    .onChange(of: homeViewModel.searchQuery) { newValue in
                        Task {
                            await homeViewModel.performSearch(query: newValue)
                        }
                    }
                
                if !homeViewModel.searchQuery.isEmpty {
                    Button(action: { homeViewModel.searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textMuted)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppColors.cinemaSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            
            // Search Results or Explore Grid
            let itemsToDisplay = !homeViewModel.searchQuery.isEmpty ? homeViewModel.searchResults : homeViewModel.moviesItems
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 16) {
                    ForEach(itemsToDisplay) { item in
                        MediaCard(item: item, width: (UIScreen.main.bounds.width - 44) / 2, height: 230) {
                            onSelectMedia(item)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - 3. Library Tab View (My List)
    private var libraryTabView: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "قائمتي المفضلة", count: "\(homeViewModel.favorites.count)")
            
            if homeViewModel.favorites.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "bookmark")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.textMuted)
                    Text("لا توجد عناصر محفوظة في قائمتك بعد")
                        .font(AppFont.cairo(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 16) {
                        ForEach(homeViewModel.favorites) { item in
                            MediaCard(item: item, width: (UIScreen.main.bounds.width - 44) / 2, height: 230) {
                                onSelectMedia(item)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.top, 12)
    }
    
    // MARK: - 4. More & Live TV Tab View
    private var moreLiveTabView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(homeViewModel.channelCategories) { category in
                    sectionHeader(title: category.name, count: "\(category.channels.count)")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(category.channels) { channel in
                                ChannelCard(channel: channel) {
                                    onSelectChannel(channel)
                                }
                                .frame(width: 110)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                Spacer().frame(height: 30)
            }
        }
    }
    
    // MARK: - 5. Account & Settings Tab View
    private var accountTabView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // User Card
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppColors.bronzeSurface)
                            .frame(width: 56, height: 56)
                        Image(systemName: "person.fill")
                            .font(.system(size: 26))
                            .foregroundColor(AppColors.bronzeGold)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AuthManager.shared.getUsername())
                            .font(AppFont.cairo(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(AuthManager.shared.isGuest() ? "وضع الضيف" : "حساب مسجل")
                            .font(AppFont.cairo(size: 12, weight: .medium))
                            .foregroundColor(AppColors.bronzeGold)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(AppColors.cinemaDarkCharcoal)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 16)
                
                // Settings List
                VStack(spacing: 1) {
                    settingsRow(icon: "trash", title: "مسح الذاكرة المؤقتة (Cache)") {
                        URLCache.shared.removeAllCachedResponses()
                    }
                    
                    settingsRow(icon: "exclamationmark.triangle", title: "الإبلاغ عن قناة أو سيرفر معطل") {
                        Task {
                            await APIService.shared.reportIssue(token: AuthManager.shared.getToken() ?? "", title: "User Report", url: "General")
                        }
                    }
                    
                    settingsRow(icon: "info.circle", title: "حول تطبيق ZOD TV", subtitle: "الإصدار 1.1") {}
                }
                .background(AppColors.cinemaDarkCharcoal)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 30)
            }
            .padding(.top, 16)
        }
    }
    
    private func settingsRow(icon: String, title: String, subtitle: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.bronzeGold)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.cairo(size: 13, weight: .medium))
                        .foregroundColor(.white)
                    if let sub = subtitle {
                        Text(sub)
                            .font(AppFont.cairo(size: 11, weight: .regular))
                            .foregroundColor(AppColors.textMuted)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.backward")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}
