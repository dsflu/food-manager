//
//  FoodItem.swift
//  FreshKeeper
//

import Foundation
import SwiftData

// MARK: - Recipe Model
@Model
final class Recipe {
    var id: UUID
    var dishName: String
    var cuisine: String
    var ingredients: Data // JSON encoded array of ingredients
    var recipe: Data // JSON encoded array of steps
    var cookingTime: String
    var difficulty: String
    var videoSearchChinese: String?
    var videoSearchEnglish: String?
    var videoLink: String?
    var reason: String
    var dateCreated: Date
    var isFavorite: Bool

    init(
        dishName: String,
        cuisine: String,
        ingredients: Data,
        recipe: Data,
        cookingTime: String,
        difficulty: String,
        videoSearchChinese: String? = nil,
        videoSearchEnglish: String? = nil,
        videoLink: String? = nil,
        reason: String,
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.dishName = dishName
        self.cuisine = cuisine
        self.ingredients = ingredients
        self.recipe = recipe
        self.cookingTime = cookingTime
        self.difficulty = difficulty
        self.videoSearchChinese = videoSearchChinese
        self.videoSearchEnglish = videoSearchEnglish
        self.videoLink = videoLink
        self.reason = reason
        self.dateCreated = Date()
        self.isFavorite = isFavorite
    }
}

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
final class FoodCategory {
    var id: UUID
    var name: String
    var icon: String
    var sortOrder: Int
    var isDefault: Bool

    @Relationship(deleteRule: .nullify, inverse: \FoodItem.category)
    var items: [FoodItem]?

    init(name: String, icon: String = "📦", sortOrder: Int = 0, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
        self.isDefault = isDefault
    }

    // Default categories
    static func createDefaults() -> [FoodCategory] {
        return [
            FoodCategory(name: "Meat", icon: "🥩", sortOrder: 0, isDefault: true),
            FoodCategory(name: "Vegetables", icon: "🥬", sortOrder: 1, isDefault: true),
            FoodCategory(name: "Fruits", icon: "🍎", sortOrder: 2, isDefault: true),
            FoodCategory(name: "Dairy", icon: "🥛", sortOrder: 3, isDefault: true),
            FoodCategory(name: "Bread", icon: "🍞", sortOrder: 4, isDefault: true),
            FoodCategory(name: "Beverages", icon: "🧃", sortOrder: 5, isDefault: true),
            FoodCategory(name: "Prepared Meals", icon: "🍱", sortOrder: 6, isDefault: true),
            FoodCategory(name: "Other", icon: "📦", sortOrder: 7, isDefault: true)
        ]
    }
}

@Model
final class FoodItem {
    var id: UUID
    var name: String
    var quantity: Int
    var dateAdded: Date
    var expiryDate: Date?
    @Attribute(.externalStorage) var photoData: Data?
    var notes: String

    var storageLocation: StorageLocation?
    var category: FoodCategory?

    init(
        name: String,
        quantity: Int,
        expiryDate: Date? = nil,
        photoData: Data? = nil,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.storageLocation = nil
        self.category = nil
        self.dateAdded = Date()
        self.expiryDate = expiryDate
        self.photoData = photoData
        self.notes = notes
    }

    var daysUntilExpiry: Int? {
        guard let expiryDate = expiryDate else { return nil }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: expiryDate).day
        return days
    }

    var isExpired: Bool {
        guard let days = daysUntilExpiry else { return false }
        return days < 0
    }

    var isExpiringSoon: Bool {
        guard let days = daysUntilExpiry else { return false }
        return days >= 0 && days <= 3
    }
}
