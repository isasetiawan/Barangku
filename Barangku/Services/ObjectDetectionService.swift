//
//  ObjectDetectionService.swift
//  Barangku
//
//  Created by Isa Setiawan Abdurrazaq on 21/02/26.
//

import UIKit
import Vision
import CoreML
import Observation

/// Hasil deteksi objek dari YOLO
struct DetectionResult: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
    let category: Category
    let suggestedName: String
}

/// Service untuk menjalankan YOLO object detection via CoreML + Vision
@Observable
class ObjectDetectionService {
    var isProcessing = false
    var detectionResults: [DetectionResult] = []
    var errorMessage: String?
    
    /// Top result dari deteksi
    var topResult: DetectionResult? {
        detectionResults.first
    }
    
    /// Deteksi objek dari UIImage
    func detect(image: UIImage) async {
        await MainActor.run {
            self.isProcessing = true
            self.errorMessage = nil
            self.detectionResults = []
        }
        
        guard let ciImage = CIImage(image: image) else {
            await MainActor.run {
                self.errorMessage = "Gagal memproses gambar"
                self.isProcessing = false
            }
            return
        }
        
        do {
            let results = try await performDetection(on: ciImage)
            await MainActor.run {
                self.detectionResults = results
                self.isProcessing = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Deteksi gagal: \(error.localizedDescription)"
                self.isProcessing = false
            }
        }
    }
    
    private func performDetection(on image: CIImage) async throws -> [DetectionResult] {
        // Coba load YOLOv3TinyInt8LUT model (dari Apple ML Models)
        // Jika tidak ada, gunakan fallback classifier
        guard let model = try? loadYOLOModel() else {
            // Fallback: gunakan Vision built-in classifier
            return try await fallbackClassification(on: image)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let results = self.processYOLOResults(request: request)
                continuation.resume(returning: results)
            }
            
            request.imageCropAndScaleOption = .scaleFill
            
            let handler = VNImageRequestHandler(ciImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Load YOLO CoreML model
    private func loadYOLOModel() throws -> VNCoreMLModel? {
        // Coba beberapa nama model yang mungkin ada di bundle
        let modelNames = ["YOLOv3TinyInt8LUT", "YOLOv3Tiny", "YOLOv3", "yolov8n", "yolov8s"]
        
        for name in modelNames {
            if let modelURL = Bundle.main.url(forResource: name, withExtension: "mlmodelc") {
                let mlModel = try MLModel(contentsOf: modelURL)
                return try VNCoreMLModel(for: mlModel)
            }
        }
        
        // Coba compiled model
        for name in modelNames {
            if let modelURL = Bundle.main.url(forResource: name, withExtension: "mlmodel") {
                let compiledURL = try MLModel.compileModel(at: modelURL)
                let mlModel = try MLModel(contentsOf: compiledURL)
                return try VNCoreMLModel(for: mlModel)
            }
        }
        
        return nil
    }
    
    /// Process YOLO detection results
    private func processYOLOResults(request: VNRequest) -> [DetectionResult] {
        // YOLO returns VNRecognizedObjectObservation
        if let observations = request.results as? [VNRecognizedObjectObservation] {
            return observations
                .compactMap { observation -> DetectionResult? in
                    guard let topLabel = observation.labels.first else { return nil }
                    let label = topLabel.identifier
                    return DetectionResult(
                        label: label,
                        confidence: topLabel.confidence,
                        category: CategoryMapper.map(label: label),
                        suggestedName: CategoryMapper.suggestedName(for: label)
                    )
                }
                .sorted { $0.confidence > $1.confidence }
        }
        
        // Fallback: bisa juga return VNClassificationObservation
        if let classifications = request.results as? [VNClassificationObservation] {
            return classifications
                .prefix(5)
                .map { classification in
                    DetectionResult(
                        label: classification.identifier,
                        confidence: classification.confidence,
                        category: CategoryMapper.map(label: classification.identifier),
                        suggestedName: CategoryMapper.suggestedName(for: classification.identifier)
                    )
                }
        }
        
        return []
    }
    
    /// Fallback: gunakan Vision built-in image classification jika YOLO model tidak tersedia
    private func fallbackClassification(on image: CIImage) async throws -> [DetectionResult] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let detections = results
                    .filter { $0.confidence > 0.1 }
                    .prefix(5)
                    .map { classification in
                        DetectionResult(
                            label: classification.identifier,
                            confidence: classification.confidence,
                            category: CategoryMapper.map(label: classification.identifier),
                            suggestedName: CategoryMapper.suggestedName(for: classification.identifier)
                        )
                    }
                
                continuation.resume(returning: Array(detections))
            }
            
            let handler = VNImageRequestHandler(ciImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
