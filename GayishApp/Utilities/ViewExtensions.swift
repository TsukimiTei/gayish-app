//
//  ViewExtensions.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI

// MARK: - View扩展

extension View {
    /// 添加彩虹渐变边框
    func rainbowBorder(lineWidth: CGFloat = 2, cornerRadius: CGFloat = 16) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "FF6B9D"),
                            Color(hex: "C06BFF"),
                            Color(hex: "6B9DFF")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: lineWidth
                )
        )
    }
    
    /// 添加卡片样式
    func cardStyle(backgroundColor: Color = Color.white.opacity(0.2)) -> some View {
        self
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                    .fill(backgroundColor)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    /// 添加主按钮样式
    func primaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                    .fill(Color.white)
            )
            .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    /// 添加次要按钮样式
    func secondaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                    .fill(Color.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                            .stroke(Color.white, lineWidth: 2)
                    )
            )
    }
    
    /// 条件修饰符
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Animation扩展

extension Animation {
    /// 弹簧动画（预设）
    static var customSpring: Animation {
        .spring(
            response: Constants.Animation.springResponse,
            dampingFraction: Constants.Animation.springDamping
        )
    }
    
    /// 平滑进出动画
    static var smoothEaseInOut: Animation {
        .easeInOut(duration: 0.3)
    }
}

// MARK: - 自定义过渡效果

extension AnyTransition {
    /// 缩放+淡入淡出组合
    static var scaleAndFade: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }
    
    /// 从底部滑入
    static var slideFromBottom: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }
    
    /// 从顶部滑入
    static var slideFromTop: AnyTransition {
        .move(edge: .top).combined(with: .opacity)
    }
}
