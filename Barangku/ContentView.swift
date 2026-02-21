//
//  ContentView.swift
//  Barangku
//
//  Created by Isa Setiawan Abdurrazaq on 21/02/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]
    
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var showAddItem = false
    @State private var sortNewestFirst = true
    @State private var selectedItem: Item?
    @AppStorage("itemsViewMode") private var viewModeRawValue: String = ViewMode.list.rawValue
    
    private var viewMode: ViewMode {
        ViewMode(rawValue: viewModeRawValue) ?? .list
    }
    
    private enum ViewMode: String {
        case list
        case grid
    }
    
    /// Filtered items berdasarkan search dan kategori
    private var filteredItems: [Item] {
        var result = items
        
        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    private var displayedItems: [Item] {
        let sorted = filteredItems.sorted { lhs, rhs in
            sortNewestFirst ? lhs.createdAt > rhs.createdAt : lhs.createdAt < rhs.createdAt
        }
        return sorted
    }
    
    /// Hitung jumlah item per kategori
    private var categoryCounts: [Category: Int] {
        var counts: [Category: Int] = [:]
        for item in items {
            counts[item.category, default: 0] += 1
        }
        return counts
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Category Filter
                if !items.isEmpty {
                    categoryFilterBar
                }
                
                // MARK: - Item List
                if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    if viewMode == .list {
                        itemListView
                    } else {
                        itemGridView
                    }
                }
            }
            .navigationTitle("Barangku")
            .searchable(text: $searchText, prompt: "Cari barang...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if !items.isEmpty {
                        Menu {
                            Button {
                                withAnimation { sortNewestFirst = true }
                            } label: {
                                Label("Terbaru", systemImage: sortNewestFirst ? "checkmark" : "")
                            }
                            Button {
                                withAnimation { sortNewestFirst = false }
                            } label: {
                                Label("Terlama", systemImage: !sortNewestFirst ? "checkmark" : "")
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if !items.isEmpty {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModeRawValue = viewMode == .list ? ViewMode.grid.rawValue : ViewMode.list.rawValue
                            }
                        } label: {
                            Image(systemName: viewMode == .list ? "square.grid.2x2" : "list.bullet")
                        }
                        .accessibilityLabel(viewMode == .list ? "Tampilan grid" : "Tampilan list")
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddItemView()
            }
            .sheet(item: $selectedItem) { item in
                ItemDetailView(item: item)
            }
        }
    }
    
    // MARK: - Category Filter Bar
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "Semua" chip
                Button {
                    withAnimation(.spring(duration: 0.2)) {
                        selectedCategory = nil
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "tray.full")
                            .font(.caption)
                        Text("Semua")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("(\(items.count))")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(selectedCategory == nil ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                    .foregroundStyle(selectedCategory == nil ? Color.accentColor : Color.secondary)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(selectedCategory == nil ? Color.accentColor : .clear, lineWidth: 1.5)
                    )
                }
                
                // Category chips
                ForEach(Category.allCases.filter { categoryCounts[$0] ?? 0 > 0 }) { category in
                    Button {
                        withAnimation(.spring(duration: 0.2)) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.caption)
                            Text(category.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text("(\(categoryCounts[category] ?? 0))")
                                .font(.caption2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category ? category.color.opacity(0.2) : Color(.systemGray6))
                        .foregroundStyle(selectedCategory == category ? category.color : .secondary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(selectedCategory == category ? category.color : .clear, lineWidth: 1.5)
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Item List
    
    private var itemListView: some View {
        List {
            ForEach(displayedItems) { item in
                Button {
                    selectedItem = item
                } label: {
                    ItemRowView(item: item)
                }
                .tint(.primary)
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.plain)
    }
    
    private var itemGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
                ForEach(displayedItems) { item in
                    Button {
                        selectedItem = item
                    } label: {
                        ItemGridCardView(item: item)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label("Hapus", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            if items.isEmpty {
                // Belum ada barang sama sekali
                Image(systemName: "shippingbox")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("Belum Ada Barang")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Tambahkan barang pertamamu dengan\nmengambil foto untuk deteksi otomatis")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    showAddItem = true
                } label: {
                    Label("Tambah Barang", systemImage: "plus")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            } else {
                // Ada barang tapi filter tidak ada hasil
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("Tidak Ditemukan")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Coba kata kunci atau kategori lain")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Actions
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let itemsToDelete = offsets.map { displayedItems[$0] }
            for item in itemsToDelete {
                modelContext.delete(item)
            }
        }
    }
    
    private func deleteItem(_ item: Item) {
        withAnimation {
            modelContext.delete(item)
        }
    }
}

// MARK: - Item Row View

struct ItemRowView: View {
    let item: Item
    
    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            Group {
                if let data = item.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: item.category.icon)
                        .font(.title3)
                        .foregroundStyle(item.category.color)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(item.category.color.opacity(0.1))
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    CategoryBadgeView(category: item.category, showIcon: false, size: .small)
                    
                    if item.quantity > 1 {
                        Text("×\(item.quantity)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Date
            Text(item.createdAt, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Item Grid Card View

struct ItemGridCardView: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let data = item.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: item.category.icon)
                        .font(.title3)
                        .foregroundStyle(item.category.color)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(item.category.color.opacity(0.12))
                }
            }
            .frame(height: 88)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(item.name)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 6) {
                CategoryBadgeView(category: item.category, showIcon: false, size: .small)
                
                if item.quantity > 1 {
                    Text("×\(item.quantity)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: Color(.systemGray5), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
