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
        "monitor": .electronics,
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
        
        // Clothing / Accessories
        "tie": .clothing,
        "suitcase": .accessories,
        "handbag": .accessories,
        "backpack": .accessories,
        "umbrella": .accessories,
        
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
    
    /// Suggest nama item berdasarkan label YOLO (dalam Bahasa Indonesia)
    static func suggestedName(for label: String) -> String {
        let lowered = label.lowercased()
        return labelToIndonesian[lowered] ?? label.capitalized
    }
    
    private static let labelToIndonesian: [String: String] = [
        "laptop": "Laptop",
        "cell phone": "Handphone",
        "tv": "Televisi",
        "remote": "Remote",
        "keyboard": "Keyboard",
        "mouse": "Mouse",
        "bottle": "Botol",
        "wine glass": "Gelas Wine",
        "cup": "Cangkir",
        "fork": "Garpu",
        "knife": "Pisau",
        "spoon": "Sendok",
        "bowl": "Mangkuk",
        "chair": "Kursi",
        "couch": "Sofa",
        "bed": "Tempat Tidur",
        "book": "Buku",
        "clock": "Jam",
        "scissors": "Gunting",
        "backpack": "Ransel",
        "handbag": "Tas Tangan",
        "suitcase": "Koper",
        "umbrella": "Payung",
        "tie": "Dasi",
        "bicycle": "Sepeda",
        "car": "Mobil",
        "motorcycle": "Motor",
        "bus": "Bus",
        "truck": "Truk",
        "boat": "Perahu",
        "airplane": "Pesawat",
        "banana": "Pisang",
        "apple": "Apel",
        "sandwich": "Sandwich",
        "orange": "Jeruk",
        "pizza": "Pizza",
        "cake": "Kue",
        "donut": "Donat",
        "hot dog": "Hot Dog",
        "broccoli": "Brokoli",
        "carrot": "Wortel",
        "refrigerator": "Kulkas",
        "microwave": "Microwave",
        "oven": "Oven",
        "toaster": "Toaster",
        "sink": "Bak Cuci",
        "toilet": "Toilet",
        "potted plant": "Tanaman Pot",
        "vase": "Vas",
        "cat": "Kucing",
        "dog": "Anjing",
        "bird": "Burung",
        "horse": "Kuda",
        "sports ball": "Bola",
        "tennis racket": "Raket Tenis",
        "skateboard": "Skateboard",
        "surfboard": "Papan Selancar",
        "skis": "Ski",
        "frisbee": "Frisbee",
        "kite": "Layang-layang",
        "hair drier": "Pengering Rambut",
        "toothbrush": "Sikat Gigi",
        "dining table": "Meja Makan",
    ]
}
