//
//  DetectionOverlayView.swift
//  Barangku
//
//  Created by Isa Setiawan Abdurrazaq on 21/02/26.
//

import SwiftUI

/// View yang menampilkan foto dengan bounding box hasil deteksi YOLO.
/// User tap salah satu box untuk memilih objek yang ingin ditambahkan.
struct DetectionOverlayView: View {
    let image: UIImage
    let results: [DetectionResult]
    let onSelect: (DetectionResult) -> Void
    
    @State private var highlightedID: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header instruksi
            Text("detection_header")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.vertical, 10)
            
            // Foto dengan bounding box overlay
            GeometryReader { geo in
                let imageSize = image.size
                let viewSize = geo.size
                let fitted = fittedRect(imageSize: imageSize, in: viewSize)
                
                ZStack(alignment: .topLeading) {
                    // Background foto
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: viewSize.width, height: viewSize.height)
                    
                    // Bounding boxes
                    ForEach(results) { result in
                        let rect = convertBoundingBox(
                            result.boundingBox,
                                imageSize: imageSize,
                                fittedRect: fitted
                            )
                            
                            let isHighlighted = highlightedID == result.id
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    highlightedID = result.id
                                }
                                // Delay sedikit supaya animasi highlight kelihatan
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    onSelect(result)
                                }
                            } label: {
                                ZStack(alignment: .topLeading) {
                                    // Box border
                                    RoundedRectangle(cornerRadius: 4)
                                        .strokeBorder(
                                            isHighlighted ? result.category.color : result.category.color.opacity(0.85),
                                            lineWidth: isHighlighted ? 3 : 2
                                        )
                                        .background(
                                            result.category.color
                                                .opacity(isHighlighted ? 0.25 : 0.08)
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                        )
                                    
                                    // Label tag
                                    labelTag(for: result)
                                        .offset(y: -24)
                                }
                            }
                            .frame(width: rect.width, height: rect.height)
                            .offset(x: rect.minX, y: rect.minY)
                        }
                    }
                }
                
                // Daftar hasil deteksi (list di bawah foto)
                if !results.isEmpty {
                    resultsList
                }
            }
            .navigationTitle("detection_title")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Label Tag
    
    private func labelTag(for result: DetectionResult) -> some View {
        HStack(spacing: 3) {
            Image(systemName: result.category.icon)
                .font(.system(size: 9))
            Text(result.suggestedName)
                .font(.system(size: 10, weight: .semibold))
            Text("\(Int(result.confidence * 100))%")
                .font(.system(size: 9))
                .opacity(0.8)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(result.category.color)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
    // MARK: - Results List (scrollable di bawah foto)
    
    private var resultsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(results) { result in
                    Button {
                        onSelect(result)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: result.category.icon)
                                .font(.caption2)
                                .foregroundStyle(result.category.color)
                            Text(result.suggestedName)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text("\(Int(result.confidence * 100))%")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            highlightedID == result.id
                                ? result.category.color.opacity(0.2)
                                : Color(.systemGray6)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(
                                    highlightedID == result.id ? result.category.color : .clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .tint(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Coordinate Conversion
    
    /// Hitung rect foto yang ter-fit di view (scaledToFit)
    private func fittedRect(imageSize: CGSize, in viewSize: CGSize) -> CGRect {
        let scale = min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
        let w = imageSize.width * scale
        let h = imageSize.height * scale
        let x = (viewSize.width - w) / 2
        let y = (viewSize.height - h) / 2
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    /// Konversi bounding box Vision (bottom-left origin, normalized) ke SwiftUI coordinate (top-left origin, pixel)
    private func convertBoundingBox(_ box: CGRect, imageSize: CGSize, fittedRect: CGRect) -> CGRect {
        let x = fittedRect.origin.x + box.origin.x * fittedRect.width
        // Vision y=0 di bottom, SwiftUI y=0 di top → flip
        let y = fittedRect.origin.y + (1 - box.origin.y - box.height) * fittedRect.height
        let w = box.width * fittedRect.width
        let h = box.height * fittedRect.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
}
