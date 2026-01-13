//
//  ContentView.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AnalysisViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "667EEA"),
                        Color(hex: "764BA2")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 根据状态显示不同视图
                switch viewModel.currentState {
                case .idle:
                    UploadView(viewModel: viewModel)
                case .uploading:
                    UploadingView()
                case .analyzing:
                    AnalyzingView()
                case .revealingScore:
                    GayOMeterView(viewModel: viewModel)
                case .showingStory:
                    StoryModeView(viewModel: viewModel)
                case .error(let message):
                    ErrorView(
                        errorMessage: message,
                        onRetry: {
                            viewModel.startAnalysis()
                        },
                        onCancel: {
                            viewModel.resetToIdle()
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
