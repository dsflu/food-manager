//
//  FoodItem.swift
//  FreshKeeper
//

import Foundation
import SwiftData

@Model
final class FoodItem {
    var id: UUID
    var name: String
    var quantity: Int
    var storageLocation: StorageLocation
    var category: FoodCategory
    var dateAdded: Date
    @Attribute(.externalStorage) var photoData: Data?
    var notes: String

    init(
        name: String,
        quantity: Int,
        storageLocation: StorageLocation,
        category: FoodCategory = .other,
        photoData: Data? = nil,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.storageLocation = storageLocation
        self.category = category
        self.dateAdded = Date()
        self.photoData = photoData
        self.notes = notes
    }
}

enum StorageLocation: String, Codable, CaseIterable {
    case fridge = "Fridge"
    case freezer1 = "Freezer 1"
    case freezer2 = "Freezer 2"

    var icon: String {
        switch self {
        case .fridge: return "refrigerator"
        case .freezer1: return "snowflake"
        case .freezer2: return "snowflake.circle"
        }
    }

    var color: String {
        switch self {
        case .fridge: return "blue"
        case .freezer1: return "cyan"
        case .freezer2: return "teal"
        }
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
