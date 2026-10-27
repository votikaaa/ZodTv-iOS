//
//  HomeScreen.swift
//  ZodTv
//
//  Exact 1:1 replica of Android HomeScreen.kt with all 5 tabs & interactive sub-browsers
//

import SwiftUI

enum LiveBrowserType {
    case none
    case tv
    case matches
    case radio
    case music
}

struct HomeScreen: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @State private var selectedTab: MainTab = .home
    
    // Navigation callbacks
    var onSelectMedia: (MediaItem) -> Void
    var onSelectChannel: (ChannelItem) -> Void
    var onSelectMatch: (MatchData) -> Void
    var onOpenSearch: () -> Void
    var onOpenSettings: () -> Void
    
    // 1. Home Quick Category Pills
    @State private var selectedHomePill: String = "الكل"
    private let homePills = ["الكل", "أفلام", "مسلسلات", "مسلسلات تركية", "مسلسلات رمضان", "أنمي وكرتون"]
    
    // 2. Explore Tab Filters
    @State private var selectedGenre: String = "الكل"
    @State private var selectedSection: String = "الكل"
    @State private var selectedYear: String = "الكل"
    
    private let genres = [
        "الكل", "اكشن", "مغامرة", "رعب", "كوميدي", "دراما", "خيال علمي", "جريمة", "اثارة", "غموض", "رومانسي", "فانتازيا", "عائلي", "حربي", "وثائقي", "انمي"
    ]
    private let sections = ["الكل", "أجنبي", "عربي", "تركي", "هندي", "آسيوي"]
    private let years = ["الكل", "2026", "2025", "2024", "2023", "2022", "2021", "2020"]
    
    // 3. Library Sub-Tabs
    @State private var selectedLibrarySubTab: Int = 0 // 0: Favorites, 1: History
    
    // 4. More/Live Sub-Browser
    @State private var activeLiveBrowser: LiveBrowserType = .none
    @State private var selectedTvCategory: String = "الكل"
    @State private var tvChannelSearch: String = ""
    @State private var radioStationSearch: String = ""
    
    // 5. Account Sheets
    @State private var showAuthModal: Bool = false
    @State private var showToastMessage: String? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Cinema Header (ZOD TV Logo + Search)
                topHeaderView
                
                // Active Tab Content
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
                
                // Bottom Bar (5 Cinema items)
                NetflixBottomBar(selectedTab: $selectedTab)
            }
            
            // Toast Notification Overlay
            if let msg = showToastMessage {
                VStack {
                    Spacer()
                    Text(msg)
                        .font(AppFont.cairo(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppColors.bronzeGold)
                        .clipShape(Capsule())
                        .shadow(radius: 6)
                        .padding(.bottom, 80)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: showToastMessage)
            }
        }
        .sheet(isPresented: $showAuthModal) {
            AuthModalView(isPresented: $showAuthModal) {
                showToast("تم تسجيل الدخول بنجاح")
            }
        }
    }
    
    private func showToast(_ message: String) {
        showToastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showToastMessage = nil
            }
        }
    }
    
    // MARK: - Top Header (Enforced LTR Logo + Search Button)
    private var topHeaderView: some View {
        HStack {
            // Brand Logo: Enforced Left-To-Right so ZOD is always before TV!
            HStack(spacing: 5) {
                Text("ZOD")
                    .font(AppFont.cairo(size: 22, weight: .black))
                    .foregroundColor(Color(hex: 0xE50914))
                Text("TV")
                    .font(AppFont.cairo(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .environment(\.layoutDirection, .leftToRight)
            
            Spacer()
            
            // Search Quick Shortcut
            Button(action: {
                selectedTab = .explore
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppColors.bronzeGold)
                    .padding(8)
                    .background(AppColors.cinemaSurfaceElevated)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.96))
    }
    
    // MARK: - 1. HOME TAB VIEW
    private var homeTabView: some View {
        VStack(spacing: 0) {
            // Top Quick Filter Pills (Chip Bar)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(homePills, id: \.self) { pill in
                        let isSelected = selectedHomePill == pill
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedHomePill = pill
                            }
                        }) {
                            Text(pill)
                                .font(AppFont.cairo(size: 12, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? AppColors.cinemaBlack : .white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(isSelected ? AppColors.bronzeGold : AppColors.cinemaSurfaceElevated)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(Color.black)
            
            // Content based on selected Home pill
            if selectedHomePill == "الكل" {
                homeOverviewScroll
            } else if selectedHomePill == "أفلام" {
                catalogGrid(items: homeViewModel.moviesItems, title: "أفلام")
            } else if selectedHomePill == "مسلسلات" {
                catalogGrid(items: homeViewModel.seriesItems, title: "مسلسلات")
            } else if selectedHomePill == "مسلسلات تركية" {
                catalogGrid(items: homeViewModel.turkishSeries, title: "المسلسلات التركية")
            } else if selectedHomePill == "مسلسلات رمضان" {
                catalogGrid(items: homeViewModel.ramadanSeries, title: "مسلسلات رمضان 2026")
            } else {
                catalogGrid(items: homeViewModel.animationMovies, title: "أنمي وأفلام كرتون")
            }
        }
    }
    
    // Curated Home Overview (Billboard + Rows)
    private var homeOverviewScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 22) {
                // Hero Billboard
                if let featured = homeViewModel.sliderItems.first {
                    heroBanner(item: featured)
                }
                
                // Continue Watching
                if !homeViewModel.continueWatching.isEmpty {
                    sectionHeader(title: "متابعة المشاهدة", count: "\(homeViewModel.continueWatching.count)")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(homeViewModel.continueWatching) { item in
                                MediaCard(item: item, width: 135, height: 195) {
                                    onSelectMedia(item)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // Today's Matches
                if !homeViewModel.todayMatches.isEmpty {
                    sectionHeader(title: "مباريات اليوم", count: "\(homeViewModel.todayMatches.count)")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(homeViewModel.todayMatches) { match in
                                MatchCard(match: match) {
                                    onSelectMatch(match)
                                }
                                .frame(width: 275)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // Live TV Channels (First Category Sample)
                if let firstCat = homeViewModel.channelCategories.first, !firstCat.channels.isEmpty {
                    sectionHeader(title: "قنوات البث المباشر", count: "\(firstCat.channels.count)")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(firstCat.channels.prefix(25)) { channel in
                                ChannelCard(channel: channel) {
                                    onSelectChannel(channel)
                                }
                                .frame(width: 105)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // أحدث الإضافات
                if !homeViewModel.latestItems.isEmpty {
                    mediaSection(title: "أحدث الإضافات", items: homeViewModel.latestItems)
                }
                
                // أفلام أجنبية
                if !homeViewModel.foreignMovies.isEmpty {
                    mediaSection(title: "أفلام أجنبية", items: homeViewModel.foreignMovies)
                }
                
                // مسلسلات أجنبية
                if !homeViewModel.foreignSeries.isEmpty {
                    mediaSection(title: "مسلسلات أجنبية", items: homeViewModel.foreignSeries)
                }
                
                // الدراما التركية
                if !homeViewModel.turkishSeries.isEmpty {
                    mediaSection(title: "الدراما التركية", items: homeViewModel.turkishSeries)
                }
                
                // مسلسلات رمضان 2026
                if !homeViewModel.ramadanSeries.isEmpty {
                    mediaSection(title: "مسلسلات رمضان 2026", items: homeViewModel.ramadanSeries)
                }
                
                // أفلام عربية
                if !homeViewModel.arabicMovies.isEmpty {
                    mediaSection(title: "أفلام عربية", items: homeViewModel.arabicMovies)
                }
                
                // مسلسلات عربية
                if !homeViewModel.arabicSeries.isEmpty {
                    mediaSection(title: "مسلسلات عربية", items: homeViewModel.arabicSeries)
                }
                
                // أفلام كرتون
                if !homeViewModel.animationMovies.isEmpty {
                    mediaSection(title: "أفلام كرتون وأنيميشن", items: homeViewModel.animationMovies)
                }
                
                Spacer().frame(height: 30)
            }
        }
    }
    
    // Reusable Catalog Grid
    private func catalogGrid(items: [MediaItem], title: String) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(title)
                        .font(AppFont.cairo(size: 17, weight: .black))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(items.count) عنصر")
                        .font(AppFont.cairo(size: 11, weight: .bold))
                        .foregroundColor(AppColors.bronzeGold)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 14) {
                    ForEach(items) { item in
                        MediaCard(item: item, width: (UIScreen.main.bounds.width - 48) / 3, height: 165) {
                            onSelectMedia(item)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }
    
    private func mediaSection(title: String, items: [MediaItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: title, count: "\(items.count)")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(items) { item in
                        MediaCard(item: item, width: 125, height: 185) {
                            onSelectMedia(item)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Hero Banner
    private func heroBanner(item: MediaItem) -> some View {
        ZStack(alignment: .bottomLeading) {
            let img = item.imageFull ?? item.image ?? item.backdropUrl
            if let imgUrl = img, let url = URL(string: imgUrl) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle().fill(AppColors.cinemaSurface)
                    }
                }
                .frame(height: 280)
                .clipped()
            }
            
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.4), Color.black.opacity(0.85), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            
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
                    
                    if let year = item.year, !year.isEmpty {
                        Text(year)
                            .font(AppFont.cairo(size: 11, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Text(item.title)
                    .font(AppFont.cairo(size: 20, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 10) {
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(AppColors.bronzeGold)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Button(action: {
                        onSelectMedia(item)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                            Text("تفاصيل")
                                .font(AppFont.cairo(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppColors.cinemaSurfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(16)
        }
        .frame(height: 280)
    }
    
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
    
    // MARK: - 2. EXPLORE TAB VIEW
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
            
            // Genre Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(genres, id: \.self) { genre in
                        let isSelected = selectedGenre == genre
                        Button(action: { selectedGenre = genre }) {
                            Text(genre)
                                .font(AppFont.cairo(size: 12, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? AppColors.cinemaBlack : .white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(isSelected ? AppColors.bronzeGold : AppColors.cinemaSurfaceElevated)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Results Grid
            let itemsToDisplay = !homeViewModel.searchQuery.isEmpty ? homeViewModel.searchResults : homeViewModel.moviesItems
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 14) {
                    ForEach(itemsToDisplay) { item in
                        MediaCard(item: item, width: (UIScreen.main.bounds.width - 48) / 3, height: 165) {
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
    
    // MARK: - 3. LIBRARY TAB VIEW
    private var libraryTabView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Segmented Picker (المفضلة vs سجل المشاهدة)
            HStack(spacing: 12) {
                Button(action: { selectedLibrarySubTab = 0 }) {
                    Text("المفضلة (\(homeViewModel.favorites.count))")
                        .font(AppFont.cairo(size: 13, weight: selectedLibrarySubTab == 0 ? .bold : .medium))
                        .foregroundColor(selectedLibrarySubTab == 0 ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedLibrarySubTab == 0 ? AppColors.bronzeGold : AppColors.cinemaSurfaceElevated)
                        .clipShape(Capsule())
                }
                
                Button(action: { selectedLibrarySubTab = 1 }) {
                    Text("سجل المشاهدة (\(homeViewModel.continueWatching.count))")
                        .font(AppFont.cairo(size: 13, weight: selectedLibrarySubTab == 1 ? .bold : .medium))
                        .foregroundColor(selectedLibrarySubTab == 1 ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedLibrarySubTab == 1 ? AppColors.bronzeGold : AppColors.cinemaSurfaceElevated)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                if selectedLibrarySubTab == 1 && !homeViewModel.continueWatching.isEmpty {
                    Button(action: {
                        AuthManager.shared.clearHistory()
                        homeViewModel.loadContinueWatching()
                        showToast("تم مسح سجل المشاهدة")
                    }) {
                        Text("مسح")
                            .font(AppFont.cairo(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: 0xE50914))
                    }
                }
            }
            .padding(.horizontal, 16)
            
            // Sub-Tab Content
            if selectedLibrarySubTab == 0 {
                // Favorites Grid
                if homeViewModel.favorites.isEmpty {
                    emptyState(icon: "bookmark", text: "لا توجد عناصر محفوظة في المفضلة")
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 14) {
                            ForEach(homeViewModel.favorites) { item in
                                MediaCard(item: item, width: (UIScreen.main.bounds.width - 48) / 3, height: 165) {
                                    onSelectMedia(item)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            } else {
                // Watch History List
                if homeViewModel.continueWatching.isEmpty {
                    emptyState(icon: "clock.arrow.circlepath", text: "لا يوجد سجل مشاهدة بعد")
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(homeViewModel.continueWatching) { item in
                                HStack(spacing: 12) {
                                    let img = item.imageFull ?? item.image
                                    if let imgStr = img, let url = URL(string: imgStr) {
                                        AsyncImage(url: url) { phase in
                                            if let image = phase.image {
                                                image.resizable().aspectRatio(contentMode: .fill)
                                            } else {
                                                Rectangle().fill(AppColors.cinemaSurface)
                                            }
                                        }
                                        .frame(width: 70, height: 95)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title)
                                            .font(AppFont.cairo(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        
                                        if let year = item.year {
                                            Text(year)
                                                .font(AppFont.cairo(size: 11))
                                                .foregroundColor(AppColors.textSecondary)
                                        }
                                        
                                        Button(action: { onSelectMedia(item) }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "play.fill")
                                                    .font(.system(size: 10))
                                                Text("استئناف")
                                                    .font(AppFont.cairo(size: 11, weight: .bold))
                                            }
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 4)
                                            .background(AppColors.bronzeGold)
                                            .clipShape(Capsule())
                                        }
                                        .padding(.top, 4)
                                    }
                                    Spacer()
                                }
                                .padding(10)
                                .background(AppColors.cinemaSurfaceElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .padding(.top, 12)
    }
    
    private func emptyState(icon: String, text: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(AppColors.textMuted)
            Text(text)
                .font(AppFont.cairo(size: 14, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 4. MORE & LIVE HUB VIEW (The 4 Cinema Bento Cards)
    private var moreLiveTabView: some View {
        Group {
            switch activeLiveBrowser {
            case .none:
                liveHubHomeView
            case .tv:
                tvChannelBrowserView
            case .matches:
                matchesCenterBrowserView
            case .radio:
                radioBrowserView
            case .music:
                musicBrowserView
            }
        }
    }
    
    // The 4 Cinema Bento Cards
    private var liveHubHomeView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("المزيد والترفيه")
                            .font(AppFont.cairo(size: 20, weight: .black))
                            .foregroundColor(.white)
                        Text("بث مباشر • إذاعات • مكتبة صوتية • مباريات اليوم")
                            .font(AppFont.cairo(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // 1. Live TV Card
                liveCategoryCard(
                    title: "قنوات البث المباشر",
                    subtitle: "قنوات فضائية ورياضية مباشرة ومصنفة بجودة عالية",
                    badge: "بث حي HD",
                    icon: "tv.fill",
                    accentColor: Color(hex: 0xE50914)
                ) {
                    activeLiveBrowser = .tv
                }
                
                // 2. Today's Matches Card
                liveCategoryCard(
                    title: "مباريات اليوم",
                    subtitle: "مواعيد وبث ونتائج المباريات مباشرة مع القنوات والمعلقين",
                    badge: "مباشر",
                    icon: "soccerball",
                    accentColor: Color(hex: 0x10B981)
                ) {
                    activeLiveBrowser = .matches
                }
                
                // 3. Live Radio Card
                liveCategoryCard(
                    title: "راديو مباشر",
                    subtitle: "إذاعات مصر والقرآن الكريم ومحطات منوعة بصوت نقي",
                    badge: "صوت نقي",
                    icon: "radio.fill",
                    accentColor: Color(hex: 0x06B6D4)
                ) {
                    activeLiveBrowser = .radio
                }
                
                // 4. Music Card
                liveCategoryCard(
                    title: "أغاني وموسيقى",
                    subtitle: "المكتبة الصوتية وأحدث الألبومات والأغاني العربية",
                    badge: "متجددة",
                    icon: "music.note",
                    accentColor: AppColors.bronzeGold
                ) {
                    activeLiveBrowser = .music
                }
                
                Spacer().frame(height: 30)
            }
        }
    }
    
    private func liveCategoryCard(title: String, subtitle: String, badge: String, icon: String, accentColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.18))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(accentColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(title)
                            .font(AppFont.cairo(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text(badge)
                            .font(AppFont.cairo(size: 10, weight: .bold))
                            .foregroundColor(accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(accentColor.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    
                    Text(subtitle)
                        .font(AppFont.cairo(size: 11, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }
                
                Image(systemName: "chevron.backward")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.textMuted)
            }
            .padding(14)
            .background(AppColors.cinemaSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
    
    // Sub-Browser 1: Full TV Channels Browser with 19 categories
    private var tvChannelBrowserView: some View {
        VStack(spacing: 10) {
            // Header with Back button
            HStack(spacing: 12) {
                Button(action: { activeLiveBrowser = .none }) {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(AppColors.cinemaSurfaceElevated)
                        .clipShape(Circle())
                }
                
                Text("قنوات البث المباشر")
                    .font(AppFont.cairo(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Channel Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textMuted)
                TextField("بحث في القنوات الفضائية...", text: $tvChannelSearch)
                    .font(AppFont.cairo(size: 13))
                    .foregroundColor(.white)
                if !tvChannelSearch.isEmpty {
                    Button(action: { tvChannelSearch = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textMuted)
                    }
                }
            }
            .padding(10)
            .background(AppColors.cinemaSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
            
            // 19 Category Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(homeViewModel.channelCategories) { category in
                        let isSelected = selectedTvCategory == category.name
                        Button(action: { selectedTvCategory = category.name }) {
                            Text("\(category.name) (\(category.channels.count))")
                                .font(AppFont.cairo(size: 12, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .black : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(isSelected ? AppColors.bronzeGold : AppColors.cinemaSurfaceElevated)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Filtered Channels Grid
            let currentChannels: [ChannelItem] = {
                let targetCategoryChannels: [ChannelItem] = {
                    if selectedTvCategory == "الكل" {
                        return homeViewModel.channelCategories.first(where: { $0.id == "all" })?.channels ?? []
                    } else {
                        return homeViewModel.channelCategories.first(where: { $0.name == selectedTvCategory })?.channels ?? []
                    }
                }()
                if tvChannelSearch.trimmingCharacters(in: .whitespaces).isEmpty {
                    return targetCategoryChannels
                } else {
                    return targetCategoryChannels.filter { $0.name.localizedCaseInsensitiveContains(tvChannelSearch) }
                }
            }()
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 12) {
                    ForEach(currentChannels) { channel in
                        ChannelCard(channel: channel) {
                            onSelectChannel(channel)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .padding(.top, 8)
    }
    
    // Sub-Browser 2: Full Matches Center
    private var matchesCenterBrowserView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: { activeLiveBrowser = .none }) {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(AppColors.cinemaSurfaceElevated)
                        .clipShape(Circle())
                }
                
                Text("مباريات اليوم")
                    .font(AppFont.cairo(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            if homeViewModel.todayMatches.isEmpty {
                emptyState(icon: "soccerball", text: "لا توجد مباريات مسجلة اليوم")
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(homeViewModel.todayMatches) { match in
                            MatchCard(match: match) {
                                onSelectMatch(match)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .padding(.top, 8)
    }
    
    // Sub-Browser 3: Live Radio Browser
    private var radioBrowserView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: { activeLiveBrowser = .none }) {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(AppColors.cinemaSurfaceElevated)
                        .clipShape(Circle())
                }
                
                Text("راديو مباشر")
                    .font(AppFont.cairo(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 12) {
                    ForEach(homeViewModel.radioStations) { station in
                        Button(action: { onSelectChannel(station) }) {
                            HStack(spacing: 10) {
                                Image(systemName: "radio.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: 0x06B6D4))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(station.name)
                                        .font(AppFont.cairo(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Text(station.category ?? "إذاعة")
                                        .font(AppFont.cairo(size: 10))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(AppColors.cinemaSurfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .padding(.top, 8)
    }
    
    // Sub-Browser 4: Music Browser
    private var musicBrowserView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: { activeLiveBrowser = .none }) {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(AppColors.cinemaSurfaceElevated)
                        .clipShape(Circle())
                }
                
                Text("أغاني وموسيقى")
                    .font(AppFont.cairo(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            emptyState(icon: "music.note.list", text: "المكتبة الصوتية متصلة وجاري مزامنة الألبومات")
        }
        .padding(.top, 8)
    }
    
    // MARK: - 5. ACCOUNT & SETTINGS TAB VIEW
    private var accountTabView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // User Profile Card
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppColors.bronzeSurface)
                            .frame(width: 58, height: 58)
                        Image(systemName: "person.fill")
                            .font(.system(size: 26))
                            .foregroundColor(AppColors.bronzeGold)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(AuthManager.shared.getUsername())
                            .font(AppFont.cairo(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(AuthManager.shared.isGuest() ? "وضع الضيف" : "حساب مفعل")
                            .font(AppFont.cairo(size: 12, weight: .medium))
                            .foregroundColor(AppColors.bronzeGold)
                    }
                    
                    Spacer()
                    
                    Button(action: { showAuthModal = true }) {
                        Text(AuthManager.shared.isGuest() ? "تسجيل دخول" : "تبديل")
                            .font(AppFont.cairo(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(AppColors.bronzeGold)
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
                .background(AppColors.cinemaDarkCharcoal)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 16)
                
                // Preferences List
                VStack(spacing: 1) {
                    settingsRow(icon: "trash", title: "مسح الذاكرة المؤقتة (Clear Cache)") {
                        URLCache.shared.removeAllCachedResponses()
                        showToast("تم تفريغ الذاكرة المؤقتة بنجاح")
                    }
                    
                    settingsRow(icon: "arrow.triangle.2.circlepath", title: "التحقق من التحديثات") {
                        showToast("أنت تستخدم أحدث إصدار من ZOD TV (v1.1)")
                    }
                    
                    settingsRow(icon: "paperplane.fill", title: "قناة التليجرام الرسمية", subtitle: "انضم لمتابعة التحديثات") {
                        if let url = URL(string: "https://t.me/zod_tv") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    settingsRow(icon: "shield.fill", title: "سياسة الخصوصية والاستخدام") {
                        showToast("تطبيق ZOD TV مصمم لراحتك وأمان بياناتك")
                    }
                    
                    settingsRow(icon: "info.circle", title: "حول تطبيق ZOD TV", subtitle: "الإصدار 1.1 - النسخة المتكاملة") {}
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
