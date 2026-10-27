//
//  ChannelCard.swift
//  ZodTv
//
//  Exact 1:1 replica of Android Live TV Channel Card
//

import SwiftUI

struct ChannelCard: View {
    let channel: ChannelItem
    var onClick: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onClick?()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppColors.cinemaSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppColors.cinemaBorder, lineWidth: 1)
                        )
                    
                    if let logoUrl = channel.logo, let url = URL(string: logoUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .tint(AppColors.bronzeGold)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(12)
                            case .failure:
                                Image(systemName: "tv")
                                    .font(.system(size: 28))
                                    .foregroundColor(AppColors.bronzeGold)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "tv")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.bronzeGold)
                    }
                    
                    // Live Dot Indicator
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(AppColors.errorRed)
                                .frame(width: 7, height: 7)
                                .padding(8)
                        }
                        Spacer()
                    }
                }
                .frame(height: 90)
                
                // Channel Name
                Text(channel.name)
                    .font(AppFont.cairo(size: 12, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(.plain)
    }
}
