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
    @State private var showingOrganization = false
    @State private var showingSettings = false
    @State private var showingDinnerRecommendation = false
    @State private var selectedLocation: StorageLocation?
    @State private var selectedCategory: FoodCategory?
    @State private var selectedFilter: ItemFilter = .all
    @State private var searchText = ""
    @State private var showFilters = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showSmallTitle = false
    @State private var chefButtonScale: CGFloat = 1.0

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
                                HStack(spacing: 8) {
                                    // App icon
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color(hex: "4CAF50"), Color(hex: "66BB6A")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color(hex: "4CAF50").opacity(0.3), radius: 4, x: 0, y: 2)

                                    HStack(spacing: 0) {
                                        Text("Fresh")
                                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [Color(hex: "2E7D32"), Color(hex: "388E3C")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                        Text("Keeper")
                                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [Color(hex: "4CAF50"), Color(hex: "66BB6A")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    }
                                }
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
                                // Smoothly show/hide small title with animation - appears earlier at -40
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showSmallTitle = newValue < -40
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

                // Beautiful Floating Chef Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                chefButtonScale = 0.95
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    chefButtonScale = 1.0
                                }
                            }
                            showingDinnerRecommendation = true
                        } label: {
                            ZStack {
                                // Outer glow effect
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(hex: "FF6B6B").opacity(0.3),
                                                Color(hex: "FF6B6B").opacity(0.1),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 20,
                                            endRadius: 40
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .blur(radius: 8)

                                // Main button with beautiful gradient
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "FF6B6B"),
                                                Color(hex: "FF8E53"),
                                                Color(hex: "FFA726")
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        // Inner white circle for depth
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.25),
                                                        Color.white.opacity(0.05)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 54, height: 54)
                                    )
                                    .overlay(
                                        // Top highlight for glossy effect
                                        Ellipse()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.4),
                                                        Color.clear
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .center
                                                )
                                            )
                                            .frame(width: 45, height: 25)
                                            .offset(y: -12)
                                    )

                                // Icon with subtle shadow
                                ZStack {
                                    // Shadow for icon
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black.opacity(0.2))
                                        .offset(x: 1, y: 1)
                                        .blur(radius: 1)

                                    // Main icon
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .scaleEffect(chefButtonScale)
                            .shadow(color: Color(hex: "FF6B6B").opacity(0.4), radius: 12, x: 0, y: 6)
                            .shadow(color: Color(hex: "FF8E53").opacity(0.2), radius: 8, x: 0, y: 3)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search food items...")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("FreshKeeper")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(.black)
                        .opacity(showSmallTitle ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: showSmallTitle)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        Button {
                            showingOrganization = true
                        } label: {
                            Image(systemName: "square.grid.3x3.fill")
                                .font(.title3)
                                .foregroundColor(Color(hex: "666666"))
                        }

                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                                .foregroundColor(Color(hex: "666666"))
                        }
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
            .sheet(isPresented: $showingOrganization) {
                OrganizationView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingDinnerRecommendation) {
                DinnerRecommendationView()
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
        .contentShape(Rectangle())
        .zIndex(1)
    }

    private var categoryFilterSection: some View {
        VStack(spacing: 8) {
            categoryFilterHeader
            categoryFilterChips
        }
        .padding(.vertical, 8)
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

