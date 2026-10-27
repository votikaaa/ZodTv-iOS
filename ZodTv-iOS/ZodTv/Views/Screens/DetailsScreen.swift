//
//  DetailsScreen.swift
//  ZodTv
//
//  Exact 1:1 replica of Android DetailsScreen.kt
//

import SwiftUI

struct DetailsScreen: View {
    let mediaItem: MediaItem
    @StateObject private var viewModel = DetailsViewModel()
    
    var onPlayVideo: (String, String) -> Void // (title, streamUrl)
    var onBack: () -> Void
    
    @State private var isFavorite: Bool = false
    @State private var selectedSeasonIndex: Int = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(AppColors.bronzeGold)
                    Text("جاري تحميل التفاصيل...")
                        .font(AppFont.cairo(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Backdrop Image Header
                        backdropHeader
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Title & Meta Info
                            titleAndMetaSection
                            
                            // Action Buttons (Play & Add to Favorites)
                            actionButtonsSection
                            
                            // Story / Description
                            synopsisSection
                            
                            // Series Seasons & Episodes (if series)
                            if let series = viewModel.seriesDetails, let seasons = series.seasons, !seasons.isEmpty {
                                seasonsAndEpisodesSection(series: series, seasons: seasons)
                            }
                            
                            // Servers List (for Movie or Episode)
                            serversSection
                            
                            // Cast Members
                            castSection
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer().frame(height: 40)
                    }
                }
            }
            
            // Top Back Button
            VStack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 48)
                Spacer()
            }
        }
        .onAppear {
            self.isFavorite = AuthManager.shared.isFavorite(item: mediaItem)
            Task {
                await viewModel.loadDetails(url: mediaItem.url ?? "", type: mediaItem.type ?? "movie")
            }
        }
    }
    
    // MARK: - Backdrop Header
    private var backdropHeader: some View {
        ZStack(alignment: .bottom) {
            let posterUrl = viewModel.movieDetails?.poster ?? viewModel.seriesDetails?.poster ?? mediaItem.imageFull ?? mediaItem.image
            if let img = posterUrl, let url = URL(string: img) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle().fill(AppColors.cinemaSurface)
                    }
                }
                .frame(height: 380)
                .clipped()
            }
            
            // Heavy Cinematic Gradient Wash
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.4), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: 380)
    }
    
    // MARK: - Title & Meta Info
    private var titleAndMetaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            let title = viewModel.movieDetails?.title ?? viewModel.seriesDetails?.title ?? mediaItem.title
            let year = viewModel.movieDetails?.year ?? viewModel.seriesDetails?.year ?? mediaItem.year ?? ""
            let rating = viewModel.movieDetails?.rating ?? viewModel.seriesDetails?.rating ?? mediaItem.rating ?? ""
            let duration = viewModel.movieDetails?.duration ?? ""
            let quality = viewModel.movieDetails?.quality ?? mediaItem.quality ?? ""
            
            Text(title)
                .font(AppFont.cairo(size: 22, weight: .black))
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                if !rating.isEmpty && rating != "0" {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.ratingGold)
                        Text(rating)
                            .font(AppFont.cairo(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                if !year.isEmpty {
                    Text(year)
                        .font(AppFont.cairo(size: 11, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                if !duration.isEmpty {
                    Text("•  \(duration)")
                        .font(AppFont.cairo(size: 11, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                if !quality.isEmpty {
                    Text(quality)
                        .font(AppFont.cairo(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColors.bronzeGoldDark)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            // Big Primary Play Button
            Button(action: {
                let title = viewModel.movieDetails?.title ?? mediaItem.title
                if let firstServer = viewModel.extraServers.first {
                    Task {
                        if let stream = await viewModel.resolveWatchUrl(link: firstServer) {
                            onPlayVideo(title, stream)
                        }
                    }
                } else if let links = viewModel.movieDetails?.links, let first = links.first {
                    Task {
                        if let stream = await viewModel.resolveWatchUrl(link: first) {
                            onPlayVideo(title, stream)
                        }
                    }
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16))
                    Text("مشاهدة الآن")
                        .font(AppFont.cairo(size: 14, weight: .bold))
                }
                .foregroundColor(AppColors.cinemaBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(AppColors.bronzeGold)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Add to My List (Favorite Toggle)
            Button(action: {
                AuthManager.shared.toggleFavorite(item: mediaItem)
                self.isFavorite.toggle()
            }) {
                VStack(spacing: 2) {
                    Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18))
                        .foregroundColor(isFavorite ? AppColors.bronzeGold : .white)
                }
                .frame(width: 52, height: 48)
                .background(AppColors.cinemaSurfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Synopsis / Story
    private var synopsisSection: some View {
        let desc = viewModel.movieDetails?.description ?? viewModel.seriesDetails?.description ?? ""
        return Group {
            if !desc.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("القصة")
                        .font(AppFont.cairo(size: 14, weight: .bold))
                        .foregroundColor(AppColors.bronzeGold)
                    Text(desc)
                        .font(AppFont.cairo(size: 13, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                        .lineSpacing(4)
                }
            }
        }
    }
    
    // MARK: - Seasons and Episodes (for Series)
    private func seasonsAndEpisodesSection(series: SeriesDetails, seasons: [Season]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("الحلقات والمواسم")
                .font(AppFont.cairo(size: 15, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            // Seasons Picker Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<seasons.count, id: \.self) { idx in
                        let s = seasons[idx]
                        let isSelected = selectedSeasonIndex == idx
                        Button(action: { selectedSeasonIndex = idx }) {
                            Text(s.title.isEmpty ? "الموسم \(s.number)" : s.title)
                                .font(AppFont.cairo(size: 12, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? AppColors.cinemaBlack : .white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(isSelected ? AppColors.bronzeGold : AppColors.cinemaSurfaceElevated)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            // Episodes List
            if let episodes = series.episodes {
                LazyVStack(spacing: 10) {
                    ForEach(episodes) { ep in
                        Button(action: {
                            Task {
                                let epRes = try? await APIService.shared.getEpisodeDetails(url: ep.url ?? "")
                                if let firstLink = epRes?.data?.links?.first {
                                    if let stream = await viewModel.resolveWatchUrl(link: firstLink) {
                                        onPlayVideo("\(series.title ?? "") - \(ep.title)", stream)
                                    }
                                }
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppColors.bronzeGold)
                                
                                Text(ep.title)
                                    .font(AppFont.cairo(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(AppColors.cinemaSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Servers Section
    private var serversSection: some View {
        Group {
            let servers = !viewModel.extraServers.isEmpty ? viewModel.extraServers : (viewModel.movieDetails?.links ?? [])
            if !servers.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("سيرفرات المشاهدة")
                        .font(AppFont.cairo(size: 14, weight: .bold))
                        .foregroundColor(AppColors.bronzeGold)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(servers) { server in
                                Button(action: {
                                    Task {
                                        if let stream = await viewModel.resolveWatchUrl(link: server) {
                                            onPlayVideo(viewModel.movieDetails?.title ?? mediaItem.title, stream)
                                        }
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "server.rack")
                                            .font(.system(size: 11))
                                        Text(server.quality ?? "سيرفر مباشر")
                                            .font(AppFont.cairo(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(AppColors.cinemaSurfaceElevated)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Cast Members Section
    private var castSection: some View {
        let cast = viewModel.movieDetails?.cast ?? viewModel.seriesDetails?.cast ?? []
        return Group {
            if !cast.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("طاقم العمل")
                        .font(AppFont.cairo(size: 14, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(cast) { member in
                                VStack(spacing: 6) {
                                    if let img = member.image, let url = URL(string: img) {
                                        AsyncImage(url: url) { phase in
                                            if let image = phase.image {
                                                image.resizable().aspectRatio(contentMode: .fill)
                                            } else {
                                                Circle().fill(AppColors.cinemaSurfaceElevated)
                                            }
                                        }
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                    } else {
                                        Circle().fill(AppColors.cinemaSurfaceElevated).frame(width: 50, height: 50)
                                    }
                                    
                                    Text(member.name)
                                        .font(AppFont.cairo(size: 10, weight: .regular))
                                        .foregroundColor(AppColors.textSecondary)
                                        .lineLimit(1)
                                        .frame(width: 60)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
