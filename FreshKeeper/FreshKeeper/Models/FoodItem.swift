//
//  FoodItem.swift
//  FreshKeeper
//

import Foundation
import SwiftData

@Model
final class StorageLocation {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var sortOrder: Int
    var isDefault: Bool

    @Relationship(deleteRule: .cascade, inverse: \FoodItem.storageLocation)
    var items: [FoodItem]?

    init(name: String, icon: String = "square.grid.2x2", colorHex: String = "4CAF50", sortOrder: Int = 0, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.isDefault = isDefault
    }

    // Default locations
    static func createDefaults() -> [StorageLocation] {
        return [
            StorageLocation(name: "Fridge", icon: "refrigerator", colorHex: "2196F3", sortOrder: 0, isDefault: true),
            StorageLocation(name: "Freezer", icon: "snowflake", colorHex: "00BCD4", sortOrder: 1, isDefault: true)
        ]
    }
}

@Model
final class FoodItem {
    var id: UUID
    var name: String
    var quantity: Int
    var category: FoodCategory
    var dateAdded: Date
    @Attribute(.externalStorage) var photoData: Data?
    var notes: String

    var storageLocation: StorageLocation?

    init(
        name: String,
        quantity: Int,
        category: FoodCategory = .other,
        photoData: Data? = nil,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.storageLocation = nil
        self.category = category
        self.dateAdded = Date()
        self.photoData = photoData
        self.notes = notes
    }
}

enum FoodCategory: String, Codable, CaseIterable {
    case meat = "Meat"
    case bread = "Bread"
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case dairy = "Dairy"
    case beverages = "Beverages"
    case prepared = "Prepared Meals"
    case other = "Other"

    var icon: String {
        switch self {
        case .meat: return "🥩"
        case .bread: return "🍞"
        case .vegetables: return "🥬"
        case .fruits: return "🍎"
        case .dairy: return "🥛"
        case .beverages: return "🧃"
        case .prepared: return "🍱"
        case .other: return "📦"
        }
    }
}
