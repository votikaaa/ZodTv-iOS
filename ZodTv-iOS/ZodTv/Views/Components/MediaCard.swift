//
//  MediaCard.swift
//  ZodTv
//
//  Exact 1:1 replica of Android Movie/Series Card
//

import SwiftUI

struct MediaCard: View {
    let item: MediaItem
    let width: CGFloat
    let height: CGFloat
    var onClick: (() -> Void)? = nil
    
    init(item: MediaItem, width: CGFloat = 135, height: CGFloat = 200, onClick: (() -> Void)? = nil) {
        self.item = item
        self.width = width
        self.height = height
        self.onClick = onClick
    }
    
    var body: some View {
        Button(action: {
            onClick?()
        }) {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    // Poster Image
                    ZStack {
                        AppColors.cardBg
                        
                        if let imgUrl = item.imageFull ?? item.image, let url = URL(string: imgUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ZStack {
                                        AppColors.cardBg
                                        ProgressView()
                                            .tint(AppColors.bronzeGold)
                                    }
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: width, height: height)
                                        .clipped()
                                case .failure:
                                    ZStack {
                                        AppColors.cardBg
                                        Image(systemName: "film")
                                            .font(.system(size: 30))
                                            .foregroundColor(AppColors.textMuted)
                                    }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "film")
                                .font(.system(size: 30))
                                .foregroundColor(AppColors.textMuted)
                        }
                    }
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.cinemaBorder, lineWidth: 0.8)
                    )
                    
                    // Top Badges (Rating & Quality)
                    HStack(spacing: 4) {
                        if let quality = item.quality, !quality.isEmpty {
                            Text(quality)
                                .font(AppFont.cairo(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(AppColors.bronzeGoldDark.opacity(0.85))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        
                        if let rating = item.rating, !rating.isEmpty, rating != "0" {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(AppColors.ratingGold)
                                Text(rating)
                                    .font(AppFont.cairo(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.75))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    .padding(6)
                    
                    // Watch progress bar if available
                    if let lastPos = item.lastPosition, let totalDur = item.totalDuration, totalDur > 0 {
                        let progress = min(1.0, max(0.0, Double(lastPos) / Double(totalDur)))
                        VStack {
                            Spacer()
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.2))
                                    Rectangle()
                                        .fill(AppColors.bronzeGold)
                                        .frame(width: geo.size.width * progress)
                                }
                            }
                            .frame(height: 3)
                            .clipShape(RoundedRectangle(cornerRadius: 1.5))
                        }
                    }
                }
                
                // Title
                Text(item.title)
                    .font(AppFont.cairo(size: 13, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.trailing)
                    .frame(width: width, alignment: .trailing)
                
                // Year & Type
                if let year = item.year, !year.isEmpty {
                    Text(year)
                        .font(AppFont.cairo(size: 11, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: width, alignment: .trailing)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
