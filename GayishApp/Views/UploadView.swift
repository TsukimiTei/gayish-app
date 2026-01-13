//
//  UploadView.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI

/// 上传截图视图
struct UploadView: View {
    @ObservedObject var viewModel: AnalysisViewModel
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var bounceAnimation = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Logo和标题区
            VStack(spacing: 20) {
                // Logo
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF6B9D"),
                                    Color(hex: "C06BFF")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: Color(hex: "C06BFF").opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Text("🌈")
                        .font(.system(size: 60))
                        .scaleEffect(bounceAnimation ? 1.1 : 1.0)
                }
                
                VStack(spacing: 8) {
                    Text("Gayish")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("测测这对话有多 Gay")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            // 上传按钮区
            VStack(spacing: 20) {
                // 相册选择按钮
                Button(action: {
                    showImagePicker = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title2)
                        
                        Text("从相册选择")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
                    .foregroundColor(Color(hex: "764BA2"))
                    .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                // 拍照按钮
                Button(action: {
                    showCamera = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                        
                        Text("拍摄截图")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
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
            
            Spacer()
            
            // 底部提示
            Text("请上传聊天对话截图")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 40)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerService.makeImagePicker { image in
                viewModel.selectImage(image)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                viewModel.selectImage(image)
            }
        }
        .onAppear {
            // Logo 弹跳动画
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                bounceAnimation = true
            }
        }
    }
}

/// 相机视图
struct CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    UploadView(viewModel: AnalysisViewModel())
        .background(
            LinearGradient(
                colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
