//
//  PhotoPickerView.swift
//  Barangku
//
//  Created by Isa Setiawan Abdurrazaq on 21/02/26.
//

import SwiftUI
import PhotosUI

/// View untuk memilih foto dari library atau kamera
struct PhotoPickerView: View {
    @Binding var selectedImage: UIImage?
    @Binding var imageData: Data?
    
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showSourcePicker = false
    @State private var showGallery = false
    
    var onImageSelected: ((UIImage) -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            if let image = selectedImage {
                // Tampilkan foto yang sudah dipilih
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            withAnimation {
                                selectedImage = nil
                                imageData = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .shadow(radius: 3)
                        }
                        .padding(8)
                    }
            } else {
                // Placeholder - tombol untuk pilih foto
                Button {
                    showSourcePicker = true
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("Ambil atau pilih foto")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Foto akan dianalisis otomatis untuk mendeteksi barang")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundStyle(.quaternary)
                    )
                }
            }
        }
        .confirmationDialog("Pilih Sumber Foto", isPresented: $showSourcePicker) {
            Button("Kamera") {
                showCamera = true
            }
            
            Button("Galeri Foto") {
                showGallery = true
            }
            
            Button("Batal", role: .cancel) { }
        }
        .photosPicker(isPresented: $showGallery, selection: $photosPickerItem, matching: .images)
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: $selectedImage)
                .ignoresSafeArea()
        }
        .onChange(of: photosPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        selectedImage = uiImage
                        imageData = uiImage.jpegData(compressionQuality: 0.8)
                        onImageSelected?(uiImage)
                    }
                }
                // Reset supaya onChange bisa trigger lagi untuk foto berikutnya
                await MainActor.run {
                    photosPickerItem = nil
                }
            }
        }
        .onChange(of: selectedImage) { oldVal, newVal in
            if let image = newVal, oldVal == nil || imageData == nil {
                imageData = image.jpegData(compressionQuality: 0.8)
                onImageSelected?(image)
            }
        }
    }
}

// MARK: - Camera UIImagePickerController Wrapper

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
