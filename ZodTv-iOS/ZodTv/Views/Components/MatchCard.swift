//
//  MatchCard.swift
//  ZodTv
//
//  Exact 1:1 replica of Android Match Card from MatchScreen.kt
//

import SwiftUI

struct MatchCard: View {
    let match: MatchData
    var onClick: (() -> Void)? = nil
    
    var isLive: Bool {
        return match.status.contains("مباشر") || match.status.contains("جارية") || match.status.contains("الشوط")
    }
    
    var isFinished: Bool {
        return match.status.contains("انتهت")
    }
    
    var body: some View {
        Button(action: {
            onClick?()
        }) {
            VStack(spacing: 10) {
                // League or Status Bar
                HStack {
                    if isLive {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(AppColors.errorRed)
                                .frame(width: 6, height: 6)
                            Text("مباشر")
                                .font(AppFont.cairo(size: 10, weight: .bold))
                                .foregroundColor(AppColors.errorRed)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.errorRed.opacity(0.15))
                        .clipShape(Capsule())
                    } else if isFinished {
                        Text("انتهت")
                            .font(AppFont.cairo(size: 10, weight: .bold))
                            .foregroundColor(AppColors.textMuted)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppColors.cinemaSurfaceElevated)
                            .clipShape(Capsule())
                    } else {
                        Text(match.time)
                            .font(AppFont.cairo(size: 10, weight: .bold))
                            .foregroundColor(AppColors.bronzeGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppColors.bronzeSurface)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    if !match.channel.isEmpty {
                        Text(match.channel)
                            .font(AppFont.cairo(size: 10, weight: .regular))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // Teams & Score
                HStack(alignment: .center, spacing: 12) {
                    // Team A
                    VStack(spacing: 6) {
                        AsyncImage(url: URL(string: match.logoA)) { phase in
                            if let img = phase.image {
                                img.resizable().aspectRatio(contentMode: .fit)
                            } else {
                                Circle().fill(AppColors.cinemaSurfaceElevated)
                            }
                        }
                        .frame(width: 40, height: 40)
                        
                        Text(match.teamA)
                            .font(AppFont.cairo(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Score or Time
                    VStack(spacing: 2) {
                        if !match.scoreA.isEmpty && !match.scoreB.isEmpty {
                            Text("\(match.scoreA) - \(match.scoreB)")
                                .font(AppFont.cairo(size: 18, weight: .black))
                                .foregroundColor(isLive ? AppColors.bronzeGold : AppColors.textPrimary)
                        } else {
                            Text("VS")
                                .font(AppFont.cairo(size: 14, weight: .bold))
                                .foregroundColor(AppColors.textMuted)
                        }
                    }
                    .frame(width: 60)
                    
                    // Team B
                    VStack(spacing: 6) {
                        AsyncImage(url: URL(string: match.logoB)) { phase in
                            if let img = phase.image {
                                img.resizable().aspectRatio(contentMode: .fit)
                            } else {
                                Circle().fill(AppColors.cinemaSurfaceElevated)
                            }
                        }
                        .frame(width: 40, height: 40)
                        
                        Text(match.teamB)
                            .font(AppFont.cairo(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(14)
            .background(AppColors.cinemaDarkCharcoal)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppColors.cinemaBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
