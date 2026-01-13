//
//  ImagePickerService.swift
//  Gayish
//
//  Created on 2026-01-13.
//

import SwiftUI
import PhotosUI

/// 图片选择服务
struct ImagePickerService {
    /// 显示图片选择器
    static func makeImagePicker(onSelect: @escaping (UIImage) -> Void) -> some View {
        ImagePicker(onSelect: onSelect)
    }
}

/// UIKit图片选择器封装
struct ImagePicker: UIViewControllerRepresentable {
    let onSelect: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.onSelect(image)
                        }
                    }
                }
            }
        }
    }
}
