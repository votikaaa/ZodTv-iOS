//
//  SplashScreen.swift
//  ZodTv
//
//  Exact 1:1 replica of Android SplashScreen.kt
//

import SwiftUI

struct SplashScreen: View {
    @ObservedObject var homeViewModel: HomeViewModel
    let onFinished: () -> Void
    
    @State private var logoAlpha: Double = 0.0
    @State private var logoScale: CGFloat = 0.94
    @State private var subtitleAlpha: Double = 0.0
    @State private var isBanned: Bool = false
    @State private var banMessage: String = ""
    @State private var deviceId: String = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Vignette gradient
            RadialGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6), Color.black.opacity(0.95)]),
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            // Brand Logo & Subtitle
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Text("ZOD")
                        .font(AppFont.cairo(size: 46, weight: .black))
                        .foregroundColor(Color(hex: 0xE50914))
                        .tracking(4)
                    
                    Text("TV")
                        .font(AppFont.cairo(size: 46, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(3)
                }
                
                Text("MOVIES  •  SERIES  •  ANIME")
                    .font(AppFont.cairo(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.60))
                    .tracking(2.5)
                    .opacity(subtitleAlpha)
                
                Spacer().frame(height: 36)
                
                // Minimalist Red Progress Spinner
                ProgressView()
                    .tint(Color(hex: 0xE50914))
                    .scaleEffect(1.2)
            }
            .scaleEffect(logoScale)
            .opacity(logoAlpha)
            
            // Bottom Tagline
            VStack {
                Spacer()
                Text("سينما بين يديك")
                    .font(AppFont.cairo(size: 11.5, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.35))
                    .tracking(1.2)
                    .padding(.bottom, 32)
                    .opacity(subtitleAlpha)
            }
            
            // Device Banned Dialog
            if isBanned {
                Color.black.opacity(0.85).ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.errorRed)
                    
                    Text("تم تعليق الجهاز")
                        .font(AppFont.cairo(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(banMessage)
                        .font(AppFont.cairo(size: 13, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("معرف الجهاز: \(deviceId)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(AppColors.textMuted)
                }
                .padding(24)
                .background(AppColors.cinemaSurfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 32)
            }
        }
        .onAppear {
            self.deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "ios-device"
            
            withAnimation(.easeOut(duration: 0.45)) {
                logoAlpha = 1.0
                logoScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.15)) {
                subtitleAlpha = 1.0
            }
            
            Task {
                // Check device ban status
                let res = await APIService.shared.checkDevice(deviceId: self.deviceId)
                if res?.status == "banned" {
                    self.banMessage = res?.message ?? "تم تعليق وصول هذا الجهاز من قبل إدارة النظام"
                    self.isBanned = true
                    return
                }
                
                // Initialize guest mode if not logged in
                if !AuthManager.shared.isLoggedIn() && !AuthManager.shared.isGuest() {
                    AuthManager.shared.setGuestMode()
                }
                
                // Refresh home feed
                await homeViewModel.refreshAll()
                
                try? await Task.sleep(nanoseconds: 600_000_000)
                onFinished()
            }
        }
    }
}
