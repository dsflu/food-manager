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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [FoodItem.self])
    }
}
