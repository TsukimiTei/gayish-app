//
//  UploadingView.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI

/// 上传中视图
struct UploadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            // 彩虹扫描线动画
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 280, height: 400)
                
                // 扫描线
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color(hex: "FF6B9D"),
                                Color(hex: "C06BFF"),
                                Color(hex: "6B9DFF"),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 3)
                    .offset(y: isAnimating ? 200 : -200)
            }
            
            Text("正在上传截图...")
                .font(.title2)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    UploadingView()
        .background(
            LinearGradient(
                colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
