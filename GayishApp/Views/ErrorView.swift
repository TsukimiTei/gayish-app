//
//  ErrorView.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI

/// 错误提示视图
struct ErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // 错误图标
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                
                // 错误标题
                Text("分析失败")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // 错误信息
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // 操作按钮
                VStack(spacing: 16) {
                    // 重试按钮
                    Button(action: onRetry) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                            
                            Text("重新分析")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                        .foregroundColor(Color(hex: "764BA2"))
                        .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    // 返回按钮
                    Button(action: onCancel) {
                        HStack(spacing: 12) {
                            Image(systemName: "house.fill")
                                .font(.title3)
                            
                            Text("返回主页")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        )
                        .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    ErrorView(
        errorMessage: "网络连接失败，请检查网络设置",
        onRetry: {},
        onCancel: {}
    )
}
