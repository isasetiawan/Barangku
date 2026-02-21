//
//  AddItemView.swift
//  Barangku
//
//  Created by Isa Setiawan Abdurrazaq on 21/02/26.
//

import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedCategory: Category = .other
    @State private var quantity = 1
    @State private var notes = ""
    @State private var selectedImage: UIImage?
    @State private var imageData: Data?
    
    // Detection
    @State private var detectionService = ObjectDetectionService()
    @State private var showDetectionResults = false
    @State private var hasAutoFilled = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Foto Section
                    photoSection
                    
                    // MARK: - Detection Results
                    if detectionService.isProcessing {
                        detectionLoadingView
                    } else if !detectionService.detectionResults.isEmpty && showDetectionResults {
                        detectionResultsView
                    }
                    
                    // MARK: - Form Fields
                    formSection
                }
                .padding()
            }
            .navigationTitle("Tambah Barang")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") { saveItem() }
                        .fontWeight(.semibold)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Foto Barang", systemImage: "photo")
                .font(.headline)
            
            PhotoPickerView(
                selectedImage: $selectedImage,
                imageData: $imageData
            ) { image in
                runDetection(on: image)
            }
        }
    }
    
    // MARK: - Detection Loading
    
    private var detectionLoadingView: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("Mendeteksi objek...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Detection Results
    
    private var detectionResultsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
                Text("Hasil Deteksi AI")
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation { showDetectionResults = false }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            
            ForEach(detectionService.detectionResults.prefix(3)) { result in
                Button {
                    applyDetectionResult(result)
                } label: {
                    HStack {
                        Image(systemName: result.category.icon)
                            .foregroundStyle(result.category.color)
                            .frame(width: 28)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.suggestedName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(result.category.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(Int(result.confidence * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 6)
                }
                .tint(.primary)
            }
            
            if !hasAutoFilled {
                Text("Ketuk hasil untuk mengisi otomatis")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: 16) {
            // Nama
            VStack(alignment: .leading, spacing: 6) {
                Label("Nama Barang", systemImage: "tag")
                    .font(.headline)
                TextField("Masukkan nama barang", text: $name)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Kategori
            VStack(alignment: .leading, spacing: 6) {
                Label("Kategori", systemImage: "square.grid.2x2")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Category.allCases) { category in
                            CategoryChip(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation(.spring(duration: 0.2)) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                }
            }
            
            // Jumlah
            VStack(alignment: .leading, spacing: 6) {
                Label("Jumlah", systemImage: "number")
                    .font(.headline)
                
                HStack {
                    Button {
                        if quantity > 1 { quantity -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                    
                    Text("\(quantity)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(minWidth: 50)
                    
                    Button {
                        quantity += 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Catatan
            VStack(alignment: .leading, spacing: 6) {
                Label("Catatan", systemImage: "note.text")
                    .font(.headline)
                TextEditor(text: $notes)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
            }
        }
    }
    
    // MARK: - Actions
    
    private func runDetection(on image: UIImage) {
        Task {
            await detectionService.detect(image: image)
            
            await MainActor.run {
                showDetectionResults = true
                
                // Auto-fill dari top result
                if let top = detectionService.topResult, !hasAutoFilled {
                    applyDetectionResult(top)
                }
            }
        }
    }
    
    private func applyDetectionResult(_ result: DetectionResult) {
        withAnimation {
            name = result.suggestedName
            selectedCategory = result.category
            hasAutoFilled = true
        }
    }
    
    private func saveItem() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let item = Item(
            name: trimmedName,
            category: selectedCategory,
            quantity: quantity,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            photoData: imageData
        )
        
        modelContext.insert(item)
        dismiss()
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? category.color.opacity(0.2) : Color(.systemGray6))
            .foregroundStyle(isSelected ? category.color : .secondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? category.color : .clear, lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    AddItemView()
        .modelContainer(for: Item.self, inMemory: true)
}
