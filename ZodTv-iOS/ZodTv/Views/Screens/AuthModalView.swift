//
//  AuthModalView.swift
//  ZodTv
//
//  Exact 1:1 replica of Android AuthScreen.kt
//

import SwiftUI

struct AuthModalView: View {
    @Binding var isPresented: Bool
    var onAuthSuccess: () -> Void
    
    @State private var isLogin: Bool = true
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.textMuted)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Brand Logo
                    HStack(spacing: 6) {
                        Text("ZOD")
                            .font(AppFont.cairo(size: 34, weight: .black))
                            .foregroundColor(.white)
                        Text("TV")
                            .font(AppFont.cairo(size: 34, weight: .bold))
                            .foregroundColor(AppColors.bronzeGold)
                    }
                    .environment(\.layoutDirection, .leftToRight)
                    
                    Text("MOVIES  •  SERIES  •  ANIME")
                        .font(AppFont.cairo(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.bronzeGold)
                        .tracking(1.5)
                    
                    Text(isLogin ? "تسجيل الدخول" : "إنشاء حساب جديد")
                        .font(AppFont.cairo(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    if let err = errorMessage {
                        Text(err)
                            .font(AppFont.cairo(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: 0xE50914))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    
                    // Input Fields
                    VStack(spacing: 14) {
                        TextField("اسم المستخدم", text: $username)
                            .font(AppFont.cairo(size: 14))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(AppColors.cinemaSurfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        SecureField("كلمة المرور", text: $password)
                            .font(AppFont.cairo(size: 14))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(AppColors.cinemaSurfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        if !isLogin {
                            SecureField("تأكيد كلمة المرور", text: $confirmPassword)
                                .font(AppFont.cairo(size: 14))
                                .foregroundColor(.white)
                                .padding(14)
                                .background(AppColors.cinemaSurfaceElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Submit Button
                    Button(action: performAuth) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text(isLogin ? "دخول" : "تسجيل حساب جديد")
                                    .font(AppFont.cairo(size: 15, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.bronzeGold)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 20)
                    
                    // Toggle Mode
                    Button(action: {
                        withAnimation {
                            isLogin.toggle()
                            errorMessage = nil
                        }
                    }) {
                        Text(isLogin ? "ليس لديك حساب؟ اضغط لإنشاء حساب جديد" : "لديك حساب بالفعل؟ اضغط لتسجيل الدخول")
                            .font(AppFont.cairo(size: 12, weight: .medium))
                            .foregroundColor(AppColors.bronzeGold)
                    }
                    .padding(.top, 10)
                    
                    // Guest Mode
                    Button(action: {
                        AuthManager.shared.setGuestMode()
                        isPresented = false
                        onAuthSuccess()
                    }) {
                        Text("الدخول كزائر (بدون حساب)")
                            .font(AppFont.cairo(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 6)
                }
            }
        }
    }
    
    private func performAuth() {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "يرجى إدخال اسم المستخدم وكلمة المرور"
            return
        }
        
        if !isLogin && password != confirmPassword {
            errorMessage = "كلمة المرور غير متطابقة"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isLogin {
                    let res = try await APIService.shared.login(req: LoginRequest(username: username, password: password))
                    if res.status == "success" {
                        AuthManager.shared.saveLogin(token: res.token ?? "", username: username)
                        await MainActor.run {
                            isLoading = false
                            isPresented = false
                            onAuthSuccess()
                        }
                    } else {
                        await MainActor.run {
                            isLoading = false
                            errorMessage = res.message ?? "فشل تسجيل الدخول"
                        }
                    }
                } else {
                    let res = try await APIService.shared.register(req: RegisterRequest(username: username, password: password))
                    if res.status == "success" {
                        AuthManager.shared.saveLogin(token: res.token ?? "", username: username)
                        await MainActor.run {
                            isLoading = false
                            isPresented = false
                            onAuthSuccess()
                        }
                    } else {
                        await MainActor.run {
                            isLoading = false
                            errorMessage = res.message ?? "فشل إنشاء الحساب"
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "حدث خطأ في الاتصال بالسيرفر"
                }
            }
        }
    }
}
