//
//  ItemDetailView.swift
//  Barangku
//
//  Created by Isa Setiawan Abdurrazaq on 21/02/26.
//

import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var item: Item
    
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false
    
    // Edit state
    @State private var editName = ""
    @State private var editCategory: Category = .other
    @State private var editQuantity = 1
    @State private var editNotes = ""
    @State private var editImage: UIImage?
    @State private var editImageData: Data?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Foto
                    photoSection
                    
                    // MARK: - Info
                    infoSection
                    
                    // MARK: - Edit / Delete buttons
                    if !isEditing {
                        actionButtons
                    }
                }
                .padding()
            }
            .navigationTitle(isEditing ? "Edit Barang" : item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isEditing {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Batal") {
                            cancelEditing()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Simpan") {
                            saveEdits()
                        }
                        .fontWeight(.semibold)
                        .disabled(editName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } else {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .alert("Hapus Barang", isPresented: $showDeleteConfirmation) {
                Button("Hapus", role: .destructive) { deleteItem() }
                Button("Batal", role: .cancel) { }
            } message: {
                Text("Apakah kamu yakin ingin menghapus \"\(item.name)\"?")
            }
        }
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        Group {
            if isEditing {
                PhotoPickerView(
                    selectedImage: $editImage,
                    imageData: $editImageData
                )
            } else if let data = item.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                // No photo placeholder
                VStack(spacing: 8) {
                    Image(systemName: item.category.icon)
                        .font(.system(size: 50))
                        .foregroundStyle(item.category.color.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(item.category.color.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // MARK: - Info Section
    
    private var infoSection: some View {
        VStack(spacing: 16) {
            if isEditing {
                editFormFields
            } else {
                displayFields
            }
        }
    }
    
    private var displayFields: some View {
        VStack(spacing: 14) {
            // Nama & Badge
            HStack {
                Text(item.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                CategoryBadgeView(category: item.category, size: .large)
            }
            
            Divider()
            
            // Jumlah
            HStack {
                Label("Jumlah", systemImage: "number")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(item.quantity)")
                    .font(.headline)
            }
            
            Divider()
            
            // Tanggal
            HStack {
                Label("Ditambahkan", systemImage: "calendar")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(item.createdAt, style: .date)
                    .font(.subheadline)
            }
            
            // Catatan
            if !item.notes.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    Label("Catatan", systemImage: "note.text")
                        .foregroundStyle(.secondary)
                    Text(item.notes)
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var editFormFields: some View {
        VStack(spacing: 16) {
            // Nama
            VStack(alignment: .leading, spacing: 6) {
                Label("Nama Barang", systemImage: "tag")
                    .font(.headline)
                TextField("Nama barang", text: $editName)
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
                                isSelected: editCategory == category
                            ) {
                                withAnimation(.spring(duration: 0.2)) {
                                    editCategory = category
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
                        if editQuantity > 1 { editQuantity -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                    Text("\(editQuantity)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(minWidth: 50)
                    Button {
                        editQuantity += 1
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
                TextEditor(text: $editNotes)
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
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                startEditing()
            } label: {
                Label("Edit", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                showDeleteConfirmation = true
            } label: {
                Label("Hapus", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Actions
    
    private func startEditing() {
        editName = item.name
        editCategory = item.category
        editQuantity = item.quantity
        editNotes = item.notes
        editImageData = item.photoData
        if let data = item.photoData {
            editImage = UIImage(data: data)
        }
        withAnimation { isEditing = true }
    }
    
    private func cancelEditing() {
        withAnimation { isEditing = false }
    }
    
    private func saveEdits() {
        item.name = editName.trimmingCharacters(in: .whitespaces)
        item.category = editCategory
        item.quantity = editQuantity
        item.notes = editNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        item.photoData = editImageData
        
        withAnimation { isEditing = false }
    }
    
    private func deleteItem() {
        modelContext.delete(item)
        dismiss()
    }
}

#Preview {
    ItemDetailView(item: Item(
        name: "MacBook Pro",
        category: .electronics,
        quantity: 1,
        notes: "MacBook Pro M3 14 inch"
    ))
    .modelContainer(for: Item.self, inMemory: true)
}
