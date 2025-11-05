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

        // Use lightweight migration for schema changes
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

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
            // If migration fails, provide helpful error message
            print("⚠️ SwiftData Migration Error: \(error)")
            print("💡 Solution: Delete the app from your device and reinstall to start fresh.")
            print("   This happens when the database schema changes significantly.")
            fatalError("Could not create ModelContainer - see console for migration instructions")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
