//
//  CategoryBadgeView.swift
//  Barangku
//
//  Created by Isa Setiawan Abdurrazaq on 21/02/26.
//

import SwiftUI

/// Badge kecil untuk menampilkan kategori
struct CategoryBadgeView: View {
    let category: Category
    var showIcon: Bool = true
    var size: BadgeSize = .regular
    
    enum BadgeSize {
        case small, regular, large
        
        var font: Font {
            switch self {
            case .small: return .caption2
            case .regular: return .caption
            case .large: return .subheadline
            }
        }
        
        var hPadding: CGFloat {
            switch self {
            case .small: return 6
            case .regular: return 10
            case .large: return 14
            }
        }
        
        var vPadding: CGFloat {
            switch self {
            case .small: return 3
            case .regular: return 5
            case .large: return 7
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if showIcon {
                Image(systemName: category.icon)
                    .font(size.font)
            }
            Text(category.localizedName)
                .font(size.font)
                .fontWeight(.medium)
        }
        .padding(.horizontal, size.hPadding)
        .padding(.vertical, size.vPadding)
        .background(category.color.opacity(0.15))
        .foregroundStyle(category.color)
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(Category.allCases) { category in
            CategoryBadgeView(category: category)
        }
    }
    .padding()
}
