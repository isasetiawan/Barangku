//
//  AddItemView.swift
//  Barangku
//
//  Created by Isa Setiawan Abdurrazaq on 21/02/26.
//

import SwiftUI
import SwiftData

// MARK: - Flow Steps

private enum AddItemStep {
    case pickPhoto
    case detecting
    case selectObject
    case fillForm
}

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Flow
    @State private var step: AddItemStep = .pickPhoto
    
    // Photo
    @State private var selectedImage: UIImage?
    @State private var imageData: Data?
    
    // Detection
    @State private var detectionService = ObjectDetectionService()
    
    // Form (pre-filled setelah user pilih box)
    @State private var name = ""
    @State private var selectedCategory: Category = .other
    @State private var quantity = 1
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .pickPhoto:
                    pickPhotoStep
                case .detecting:
                    detectingStep
                case .selectObject:
                    selectObjectStep
                case .fillForm:
                    fillFormStep
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
                
                if step == .fillForm {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("save") { saveItem() }
                            .fontWeight(.semibold)
                            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .onAppear { resetForm() }
        }
    }
    
    private var navigationTitle: LocalizedStringKey {
        switch step {
        case .pickPhoto: return "add_pick_photo_title"
        case .detecting: return "add_detecting_title"
        case .selectObject: return "add_select_object_title"
        case .fillForm: return "add_detail_title"
        }
    }
    
    // MARK: - Step 1: Pick Photo
    
    private var pickPhotoStep: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)
            
            Text("pick_photo_headline")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("pick_photo_subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            PhotoPickerView(
                selectedImage: $selectedImage,
                imageData: $imageData
            ) { image in
                startDetection(on: image)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Step 2: Detecting (loading)
    
    private var detectingStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.ultraThinMaterial, lineWidth: 2)
                    )
            }
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                Text("detecting_headline")
                    .font(.headline)
                Text("detecting_subtitle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Step 3: Select Object (overlay with boxes)
    
    private var selectObjectStep: some View {
        Group {
            if let image = selectedImage {
                if detectionService.detectionResults.isEmpty {
                    // Tidak ada objek terdeteksi
                    noDetectionView
                } else {
                    DetectionOverlayView(
                        image: image,
                        results: detectionService.detectionResults,
                        onSelect: { result in
                            applyDetectionResult(result)
                        }
                    )
                }
            }
        }
    }
    
    private var noDetectionView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "eye.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("no_detection_title")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("no_detection_subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button {
                    withAnimation {
                        step = .pickPhoto
                        selectedImage = nil
                        imageData = nil
                    }
                } label: {
                    Label("retry_photo", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    withAnimation { step = .fillForm }
                } label: {
                    Label("fill_manual", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .tint(Color.accentColor)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Step 4: Fill Form
    
    private var fillFormStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Thumbnail foto
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                // Form fields
                formSection
            }
            .padding()
        }
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: 16) {
            // Nama
            VStack(alignment: .leading, spacing: 6) {
                Label("field_name", systemImage: "tag")
                    .font(.headline)
                TextField(String(localized: "field_name_placeholder"), text: $name)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Kategori
            VStack(alignment: .leading, spacing: 6) {
                Label("field_category", systemImage: "square.grid.2x2")
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
                Label("field_quantity", systemImage: "number")
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
                Label("field_notes", systemImage: "note.text")
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
    
    private func startDetection(on image: UIImage) {
        withAnimation { step = .detecting }
        Task {
            await detectionService.detect(image: image)
            await MainActor.run {
                withAnimation { step = .selectObject }
            }
        }
    }
    
    private func applyDetectionResult(_ result: DetectionResult) {
        name = result.suggestedName
        selectedCategory = result.category
        withAnimation { step = .fillForm }
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
    
    private func resetForm() {
        step = .pickPhoto
        name = ""
        selectedCategory = .other
        quantity = 1
        notes = ""
        selectedImage = nil
        imageData = nil
        detectionService = ObjectDetectionService()
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
                Text(category.localizedName)
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
