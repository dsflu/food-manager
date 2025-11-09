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

        // Configure navigation bar with BLACK text for large and small titles
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.91, green: 0.96, blue: 0.97, alpha: 1.0) // #E8F4F8

        // LARGE TITLE - BLACK TEXT
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        // SMALL TITLE - BLACK TEXT
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]

        // Apply to all navigation bars in the app
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FoodItem.self,
            StorageLocation.self,
            FoodCategory.self,
            Recipe.self
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

// Color extension for hex colors - shared across all views
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0

        // Use Scanner and check if scanning succeeded
        let scanner = Scanner(string: hex)
        let scanSuccess = scanner.scanHexInt64(&int)

        // If scan failed or hex is empty, default to clear/white
        guard scanSuccess, !hex.isEmpty else {
            self.init(.sRGB, red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0)
            return
        }

        let a, r, g, b: Double

        switch hex.count {
        case 3: // RGB (12-bit)
            a = 1.0
            r = Double((int >> 8) * 17) / 255.0
            g = Double((int >> 4 & 0xF) * 17) / 255.0
            b = Double((int & 0xF) * 17) / 255.0
        case 6: // RGB (24-bit)
            a = 1.0
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        case 8: // ARGB (32-bit)
            a = Double((int >> 24) & 0xFF) / 255.0
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            // Default to white for invalid hex strings
            self.init(.sRGB, red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0)
            return
        }

        // Ensure all values are strictly clamped between 0.0 and 1.0
        // Use explicit sRGB colorspace to avoid UIColor conversion issues
        self.init(
            .sRGB,
            red: max(0.0, min(1.0, r)),
            green: max(0.0, min(1.0, g)),
            blue: max(0.0, min(1.0, b)),
            opacity: max(0.0, min(1.0, a))
        )
    }
}
