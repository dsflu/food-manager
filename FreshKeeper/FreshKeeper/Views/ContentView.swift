//
//  ContentView.swift
//  FreshKeeper
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var foodItems: [FoodItem]
    @State private var showingAddItem = false
    @State private var selectedLocation: StorageLocation?
    @State private var searchText = ""

    var filteredItems: [FoodItem] {
        var items = foodItems

        if let location = selectedLocation {
            items = items.filter { $0.storageLocation == location }
        }

        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return items.sorted { $0.dateAdded > $1.dateAdded }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "E8F4F8"), Color(hex: "F8F9FA")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header Stats
                    statsSection

                    // Location Filter
                    locationFilterSection

                    // Food Items Grid
                    if filteredItems.isEmpty {
                        emptyStateView
                    } else {
                        foodItemsGrid
                    }
                }
            }
            .navigationTitle("FreshKeeper")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search food items...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color(hex: "4CAF50"))
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddFoodItemView()
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total Items",
                value: "\(foodItems.count)",
                icon: "square.grid.2x2.fill",
                color: Color(hex: "4CAF50")
            )
            StatCard(
                title: "Total Stock",
                value: "\(foodItems.reduce(0) { $0 + $1.quantity })",
                icon: "cube.box.fill",
                color: Color(hex: "2196F3")
            )
        }
        .padding()
    }

    private var locationFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedLocation == nil
                ) {
                    selectedLocation = nil
                }

                ForEach(StorageLocation.allCases, id: \.self) { location in
                    FilterChip(
                        title: location.rawValue,
                        icon: location.icon,
                        isSelected: selectedLocation == location
                    ) {
                        selectedLocation = selectedLocation == location ? nil : location
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private var foodItemsGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(filteredItems) { item in
                    NavigationLink(destination: FoodItemDetailView(item: item)) {
                        FoodItemCard(item: item)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "refrigerator")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "4CAF50"), Color(hex: "2196F3")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.3)

            Text("Your inventory is empty")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start by adding your first food item")
                .foregroundStyle(.secondary)

            Button {
                showingAddItem = true
            } label: {
                Label("Add Food Item", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "4CAF50"))
                    .cornerRadius(12)
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Spacer()
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color(hex: "4CAF50") : Color.white)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
