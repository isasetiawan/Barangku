//
//  Item.swift
//  Barangku
//
//  Created by Isa Setiawan Abdurrazaq on 21/02/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var name: String
    var categoryRaw: String
    var quantity: Int
    var notes: String
    @Attribute(.externalStorage) var photoData: Data?
    var createdAt: Date
    
    /// Computed property untuk Category enum
    var category: Category {
        get { Category(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
    
    init(
        name: String,
        category: Category = .other,
        quantity: Int = 1,
        notes: String = "",
        photoData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.name = name
        self.categoryRaw = category.rawValue
        self.quantity = quantity
        self.notes = notes
        self.photoData = photoData
        self.createdAt = createdAt
    }
}
