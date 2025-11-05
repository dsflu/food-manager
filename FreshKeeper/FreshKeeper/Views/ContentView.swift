//
//  ContentView.swift
//  FreshKeeper
//

import SwiftUI
import SwiftData

enum ItemFilter {
    case all
    case expiringSoon
    case expired
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodItem.dateAdded, order: .reverse) private var foodItems: [FoodItem]
    @Query(sort: \StorageLocation.sortOrder) private var storageLocations: [StorageLocation]
    @Query(sort: \FoodCategory.sortOrder) private var foodCategories: [FoodCategory]
    @State private var showingAddItem = false
    @State private var showingManageStorage = false
    @State private var selectedLocation: StorageLocation?
    @State private var selectedCategory: FoodCategory?
    @State private var selectedFilter: ItemFilter = .all
    @State private var searchText = ""
    @State private var showFilters = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showSmallTitle = false

    var filteredItems: [FoodItem] {
        var items = foodItems

        // Filter by status (all/expiring/expired)
        switch selectedFilter {
        case .all:
            break // Show all
        case .expiringSoon:
            items = items.filter { $0.isExpiringSoon && !$0.isExpired }
        case .expired:
            items = items.filter { $0.isExpired }
        }

        // Filter by storage location
        if let location = selectedLocation {
            items = items.filter { $0.storageLocation?.id == location.id }
        }

        // Filter by category
        if let category = selectedCategory {
            items = items.filter { $0.category?.id == category.id }
        }

        // Filter by search text
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return items
    }

    var hasActiveFilters: Bool {
        selectedLocation != nil || selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "E8F4F8"), Color(hex: "F8F9FA")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Content with Custom Header
                ScrollView {
                    VStack(spacing: 0) {
                        // CUSTOM LARGE TITLE that shrinks SLOWLY when scrolling
                        GeometryReader { geometry in
                            let offset = geometry.frame(in: .named("scroll")).minY
                            // Slower fade - over 100 points instead of 50
                            let opacity = min(max(1 - (offset / -100), 0), 1)
                            // Slower scale - over 150 points, scales to 0.6 (more visible)
                            let scale = min(max(1 - (offset / -150) * 0.4, 0.6), 1)

                            HStack {
                                Text("FreshKeeper")
                                    .font(.system(size: 34, weight: .bold, design: .default))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                            .opacity(opacity)
                            .scaleEffect(scale, anchor: .leading)
                            .animation(.easeOut(duration: 0.2), value: offset)
                            .onChange(of: offset) { oldValue, newValue in
                                scrollOffset = newValue
                                // Smoothly show/hide small title with animation
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSmallTitle = newValue < -80
                                }
                            }
                        }
                        .frame(height: 52)

                        // Header Stats
                        statsSection

                        // Location Filter (always visible)
                        locationFilterSection

                        // Category Filter (collapsible with filter button)
                        if showFilters && !foodCategories.isEmpty {
                            categoryFilterSection
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // Food Items Grid
                        if filteredItems.isEmpty {
                            emptyStateView
                        } else {
                            foodItemsGridContent
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
            }
            .navigationTitle(showSmallTitle ? "FreshKeeper" : "")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search food items...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingManageStorage = true
                    } label: {
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.title3)
                            .foregroundColor(Color(hex: "666666"))
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showFilters.toggle()
                            }
                        } label: {
                            ZStack {
                                Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                    .font(.title3)
                                    .foregroundColor(showFilters ? Color(hex: "2196F3") : Color(hex: "666666"))

                                if hasActiveFilters {
                                    Circle()
                                        .fill(Color(hex: "FF5722"))
                                        .frame(width: 8, height: 8)
                                        .offset(x: 10, y: -10)
                                }
                            }
                        }

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
            }
            .sheet(isPresented: $showingAddItem) {
                AddFoodItemView()
            }
            .sheet(isPresented: $showingManageStorage) {
                StorageManagementView()
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedFilter = .all
                    selectedLocation = nil
                    selectedCategory = nil
                }
            } label: {
                StatCard(
                    title: "Total Items",
                    value: "\(foodItems.count)",
                    icon: "square.grid.2x2.fill",
                    color: Color(hex: "4CAF50"),
                    isSelected: selectedFilter == .all
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedFilter = selectedFilter == .expiringSoon ? .all : .expiringSoon
                    selectedLocation = nil
                    selectedCategory = nil
                }
            } label: {
                StatCard(
                    title: "Expiring Soon",
                    value: "\(foodItems.filter { $0.isExpiringSoon && !$0.isExpired }.count)",
                    icon: "clock.fill",
                    color: Color(hex: "FF9800"),
                    isSelected: selectedFilter == .expiringSoon
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedFilter = selectedFilter == .expired ? .all : .expired
                    selectedLocation = nil
                    selectedCategory = nil
                }
            } label: {
                StatCard(
                    title: "Expired",
                    value: "\(foodItems.filter { $0.isExpired }.count)",
                    icon: "exclamationmark.triangle.fill",
                    color: Color(hex: "F44336"),
                    isSelected: selectedFilter == .expired
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .contentShape(Rectangle())
        .zIndex(1)
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

                ForEach(storageLocations) { location in
                    FilterChip(
                        title: location.name,
                        icon: location.icon,
                        isSelected: selectedLocation?.id == location.id
                    ) {
                        selectedLocation = selectedLocation?.id == location.id ? nil : location
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(hex: "F8F9FA"))
        .contentShape(Rectangle())
        .zIndex(1)
    }

    private var categoryFilterSection: some View {
        VStack(spacing: 8) {
            categoryFilterHeader
            categoryFilterChips
        }
        .padding(.vertical, 8)
        .background(Color(hex: "F8F9FA"))
        .contentShape(Rectangle())
        .zIndex(1)
    }

    private var categoryFilterHeader: some View {
        HStack {
            Text("Filter by Category")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "666666"))
                .padding(.leading, 16)

            Spacer()

            if hasActiveFilters {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedFilter = .all
                        selectedLocation = nil
                        selectedCategory = nil
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                        Text("Clear Filters")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color(hex: "FF5722"))
                    .padding(.trailing, 16)
                }
            }
        }
    }

    private var categoryFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(foodCategories) { category in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = selectedCategory?.id == category.id ? nil : category
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(category.icon)
                                .font(.system(.caption, design: .rounded))
                            Text(category.name)
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedCategory?.id == category.id ? Color(hex: "2196F3") : Color.white)
                        .foregroundColor(selectedCategory?.id == category.id ? .white : Color(hex: "1A1A1A"))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal)
        }
    }

    private var foodItemsGridContent: some View {
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

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            if hasActiveFilters {
                // Empty state with filters active
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "4CAF50"), Color(hex: "2196F3")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(0.3)

                Text("No items found")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "1A1A1A"))

                Text("Try adjusting your filters")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "666666"))

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedFilter = .all
                        selectedLocation = nil
                        selectedCategory = nil
                        searchText = ""
                    }
                } label: {
                    Label("Clear All Filters", systemImage: "xmark.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(hex: "2196F3"))
                        .cornerRadius(12)
                }
                .padding(.top)
            } else {
                // Empty state without filters
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
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "1A1A1A"))

                Text("Start by adding your first food item")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "666666"))

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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isSelected: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            // Icon with colored background
            ZStack {
                Circle()
                    .fill(isSelected ? color : color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : color)
            }

            // Value
            Text(value)
                .font(.system(.title, design: .rounded))
                .fontWeight(.heavy)
                .foregroundColor(Color(hex: "1A1A1A"))

            // Title
            Text(title)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "666666"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(isSelected ? color.opacity(0.1) : Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(isSelected ? 0.1 : 0.05), radius: isSelected ? 8 : 5, x: 0, y: isSelected ? 4 : 2)
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
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                }
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color(hex: "4CAF50") : Color.white)
            .foregroundColor(isSelected ? .white : Color(hex: "1A1A1A"))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(.borderless)
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
