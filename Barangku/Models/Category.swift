//
//  Category.swift
//  Barangku
//
//  Created by Isa Setiawan Abdurrazaq on 21/02/26.
//

import SwiftUI

/// Kategori inventory yang di-mapping dari label YOLO (COCO dataset)
enum Category: String, CaseIterable, Codable, Identifiable {
    case electronics = "Elektronik"
    case clothing = "Pakaian"
    case kitchen = "Dapur"
    case furniture = "Furnitur"
    case books = "Buku"
    case tools = "Alat"
    case sports = "Olahraga"
    case food = "Makanan"
    case vehicles = "Kendaraan"
    case animals = "Hewan"
    case accessories = "Aksesoris"
    case other = "Lainnya"
    
    var id: String { rawValue }
    
    /// Ikon SF Symbol untuk tiap kategori
    var icon: String {
        switch self {
        case .electronics: return "desktopcomputer"
        case .clothing: return "tshirt"
        case .kitchen: return "fork.knife"
        case .furniture: return "sofa"
        case .books: return "book"
        case .tools: return "wrench.and.screwdriver"
        case .sports: return "sportscourt"
        case .food: return "carrot"
        case .vehicles: return "car"
        case .animals: return "pawprint"
        case .accessories: return "bag"
        case .other: return "square.grid.2x2"
        }
    }
    
    /// Warna untuk badge kategori
    var color: Color {
        switch self {
        case .electronics: return .blue
        case .clothing: return .purple
        case .kitchen: return .orange
        case .furniture: return .brown
        case .books: return .green
        case .tools: return .gray
        case .sports: return .red
        case .food: return .yellow
        case .vehicles: return .indigo
        case .animals: return .mint
        case .accessories: return .pink
        case .other: return .secondary
        }
    }
}
