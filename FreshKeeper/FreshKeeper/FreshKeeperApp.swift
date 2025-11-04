//
//  FreshKeeperApp.swift
//  FreshKeeper
//
//  A beautiful iOS app for managing food inventory in your fridge and freezers
//

import SwiftUI
import SwiftData

@main
struct FreshKeeperApp: App {
    init() {
        // Configure UI appearance for better visibility
        // Set green cursor color for TextFields
        UITextField.appearance().tintColor = UIColor(red: 0.29, green: 0.69, blue: 0.31, alpha: 1.0) // #4CAF50
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FoodItem.self,
            StorageLocation.self,
            FoodCategory.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Seed default storage locations and categories if needed
            let context = container.mainContext

            // Seed storage locations
            let locationDescriptor = FetchDescriptor<StorageLocation>()
            let existingLocations = try? context.fetch(locationDescriptor)

            if existingLocations == nil || existingLocations?.isEmpty == true {
                for location in StorageLocation.createDefaults() {
                    context.insert(location)
                }
            }

            // Seed categories
            let categoryDescriptor = FetchDescriptor<FoodCategory>()
            let existingCategories = try? context.fetch(categoryDescriptor)

            if existingCategories == nil || existingCategories?.isEmpty == true {
                for category in FoodCategory.createDefaults() {
                    context.insert(category)
                }
            }

            try? context.save()

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
