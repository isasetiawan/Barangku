//
//  CategoryMapper.swift
//  Barangku
//
//  Created by Isa Setiawan Abdurrazaq on 21/02/26.
//

import Foundation

/// Mapping dari label YOLO (COCO 80 classes) ke Category inventory
struct CategoryMapper {
    
    /// Map label YOLO ke Category
    static func map(label: String) -> Category {
        let lowered = label.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let category = labelToCategory[lowered] {
            return category
        }
        
        // Fallback: coba partial match
        for (key, category) in labelToCategory {
            if lowered.contains(key) || key.contains(lowered) {
                return category
            }
        }
        
        return .other
    }
    
    /// Mapping YOLO COCO label → Category
    private static let labelToCategory: [String: Category] = [
        // Electronics
        "laptop": .electronics,
        "cell phone": .electronics,
        "tv": .electronics,
        "remote": .electronics,
        "keyboard": .electronics,
        "mouse": .electronics,
        "microwave": .electronics,
        "oven": .electronics,
        "toaster": .electronics,
        "hair drier": .electronics,
        
        // Kitchen
        "bottle": .kitchen,
        "wine glass": .kitchen,
        "cup": .kitchen,
        "fork": .kitchen,
        "knife": .kitchen,
        "spoon": .kitchen,
        "bowl": .kitchen,
        "refrigerator": .kitchen,
        "sink": .kitchen,
        "dining table": .kitchen,
        "vase": .kitchen,
        
        // Furniture
        "chair": .furniture,
        "couch": .furniture,
        "bed": .furniture,
        "potted plant": .furniture,
        "clock": .furniture,
        "toilet": .furniture,
        "bench": .furniture,
        
        // Clothing / Accessories
        "tie": .clothing,
        "suitcase": .accessories,
        "handbag": .accessories,
        "backpack": .accessories,
        "umbrella": .accessories,
        "teddy bear": .accessories,
        
        // Sports
        "frisbee": .sports,
        "skis": .sports,
        "snowboard": .sports,
        "sports ball": .sports,
        "kite": .sports,
        "baseball bat": .sports,
        "baseball glove": .sports,
        "skateboard": .sports,
        "surfboard": .sports,
        "tennis racket": .sports,
        
        // Food
        "banana": .food,
        "apple": .food,
        "sandwich": .food,
        "orange": .food,
        "broccoli": .food,
        "carrot": .food,
        "hot dog": .food,
        "pizza": .food,
        "donut": .food,
        "cake": .food,
        
        // Vehicles
        "bicycle": .vehicles,
        "car": .vehicles,
        "motorcycle": .vehicles,
        "airplane": .vehicles,
        "bus": .vehicles,
        "train": .vehicles,
        "truck": .vehicles,
        "boat": .vehicles,
        
        // Animals
        "bird": .animals,
        "cat": .animals,
        "dog": .animals,
        "horse": .animals,
        "sheep": .animals,
        "cow": .animals,
        "elephant": .animals,
        "bear": .animals,
        "zebra": .animals,
        "giraffe": .animals,
        
        // Books
        "book": .books,
        
        // Tools
        "scissors": .tools,
        "toothbrush": .tools,
    ]
    
    /// Suggest nama item berdasarkan label YOLO, mengikuti locale device
    static func suggestedName(for label: String) -> String {
        let key = "item_" + label.lowercased().replacingOccurrences(of: " ", with: "_")
        return Bundle.main.localizedString(forKey: key, value: label.capitalized, table: nil)
    }
}
