//
//  OrganizationView.swift
//  FreshKeeper
//
//  Combined view for managing storage locations and food categories

import SwiftUI
import SwiftData

struct OrganizationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F9FA")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Beautiful Custom Tab Selector
                    HStack(spacing: 0) {
                        // Locations Tab
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = 0
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "square.grid.2x2.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(selectedTab == 0 ? Color(hex: "2196F3") : Color(hex: "999999"))

                                Text("Locations")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(selectedTab == 0 ? .bold : .medium)
                                    .foregroundColor(selectedTab == 0 ? Color(hex: "2196F3") : Color(hex: "666666"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == 0 ? Color(hex: "E3F2FD") : Color.clear)
                            .cornerRadius(12)
                        }

                        // Categories Tab
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = 1
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(selectedTab == 1 ? Color(hex: "4CAF50") : Color(hex: "999999"))

                                Text("Categories")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(selectedTab == 1 ? .bold : .medium)
                                    .foregroundColor(selectedTab == 1 ? Color(hex: "4CAF50") : Color(hex: "666666"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == 1 ? Color(hex: "E8F5E9") : Color.clear)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)

                    // Tab Content
                    TabView(selection: $selectedTab) {
                        StorageLocationsTab()
                            .tag(0)

                        CategoriesTab()
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Organization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Storage Locations Tab
struct StorageLocationsTab: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StorageLocation.sortOrder) private var storageLocations: [StorageLocation]

    @State private var showingAddLocation = false
    @State private var editingLocation: StorageLocation?
    @State private var editMode: EditMode = .inactive
    @State private var showToolbar = true

    var body: some View {
        ZStack {
            if storageLocations.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 0) {
                    // Action Toolbar
                    HStack(spacing: 16) {
                        // Reorder button
                        if !storageLocations.isEmpty {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    editMode = editMode == .active ? .inactive : .active
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: editMode == .active ? "checkmark.circle.fill" : "arrow.up.arrow.down")
                                        .font(.system(.body))
                                    Text(editMode == .active ? "Done" : "Reorder")
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(editMode == .active ? Color(hex: "2196F3") : Color(hex: "E3F2FD"))
                                .foregroundColor(editMode == .active ? .white : Color(hex: "2196F3"))
                                .cornerRadius(20)
                                .shadow(color: Color(hex: "2196F3").opacity(editMode == .active ? 0.3 : 0), radius: 4, x: 0, y: 2)
                            }
                        }

                        Spacer()

                        // Add button
                        Button {
                            showingAddLocation = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(.body))
                                Text("Add Location")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "4CAF50"), Color(hex: "45A049")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(color: Color(hex: "4CAF50").opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 1)

                    // Storage Locations List
                    List {
                        ForEach(storageLocations) { location in
                            StorageLocationRow(
                                location: location,
                                onEdit: {
                                    editingLocation = location
                                },
                                onDelete: {
                                    deleteLocation(location)
                                }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                        .onMove { source, destination in
                            moveLocations(from: source, to: destination)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let location = storageLocations[index]
                                modelContext.delete(location)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .environment(\.editMode, $editMode)
                }
            }
        }
        .sheet(isPresented: $showingAddLocation) {
            AddStorageLocationView()
        }
        .sheet(item: $editingLocation) { location in
            EditStorageLocationView(location: location)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.grid.3x3")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "CCCCCC"))

            Text("No storage locations")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "1A1A1A"))

            Text("Start with default locations or create your own")
                .font(.system(.body, design: .rounded))
                .foregroundColor(Color(hex: "666666"))
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                // Initialize with defaults button
                Button {
                    initializeDefaultLocations()
                } label: {
                    Label("Initialize Fridge & Freezer", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "2196F3"), Color(hex: "1976D2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }

                // Or add custom location
                Button {
                    showingAddLocation = true
                } label: {
                    Label("Add Custom Location", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(Color(hex: "4CAF50"))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(hex: "E8F5E9"))
                        .cornerRadius(12)
                }
            }
        }
    }

    private func initializeDefaultLocations() {
        let defaultLocations = StorageLocation.createDefaults()
        for location in defaultLocations {
            modelContext.insert(location)
        }
        try? modelContext.save()
    }

    private func deleteLocation(_ location: StorageLocation) {
        // Allow deletion of all locations - users can re-add if needed
        modelContext.delete(location)
    }

    private func moveLocations(from source: IndexSet, to destination: Int) {
        var mutableLocations = Array(storageLocations)
        mutableLocations.move(fromOffsets: source, toOffset: destination)

        for (index, location) in mutableLocations.enumerated() {
            location.sortOrder = index
        }

        try? modelContext.save()
    }
}

// Categories Tab
struct CategoriesTab: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodCategory.sortOrder) private var categories: [FoodCategory]

    @State private var showingAddCategory = false
    @State private var editingCategory: FoodCategory?
    @State private var editMode: EditMode = .inactive
    @State private var showToolbar = true

    var body: some View {
        ZStack {
            if categories.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 0) {
                    // Action Toolbar
                    HStack(spacing: 16) {
                        // Reorder button
                        if !categories.isEmpty {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    editMode = editMode == .active ? .inactive : .active
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: editMode == .active ? "checkmark.circle.fill" : "arrow.up.arrow.down")
                                        .font(.system(.body))
                                    Text(editMode == .active ? "Done" : "Reorder")
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(editMode == .active ? Color(hex: "4CAF50") : Color(hex: "E8F5E9"))
                                .foregroundColor(editMode == .active ? .white : Color(hex: "4CAF50"))
                                .cornerRadius(20)
                                .shadow(color: Color(hex: "4CAF50").opacity(editMode == .active ? 0.3 : 0), radius: 4, x: 0, y: 2)
                            }
                        }

                        Spacer()

                        // Add button
                        Button {
                            showingAddCategory = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(.body))
                                Text("Add Category")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "4CAF50"), Color(hex: "45A049")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(color: Color(hex: "4CAF50").opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 1)

                    // Categories List
                    List {
                        ForEach(categories) { category in
                            CategoryRow(
                                category: category,
                                onEdit: {
                                    editingCategory = category
                                },
                                onDelete: {
                                    deleteCategory(category)
                                }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                        .onMove { source, destination in
                            moveCategories(from: source, to: destination)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let category = categories[index]
                                modelContext.delete(category)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .environment(\.editMode, $editMode)
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
        }
        .sheet(item: $editingCategory) { category in
            EditCategoryView(category: category)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tag.circle")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "CCCCCC"))

            Text("No categories")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "1A1A1A"))

            Text("Start fresh with default categories or create your own")
                .font(.system(.body, design: .rounded))
                .foregroundColor(Color(hex: "666666"))
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                // Initialize with defaults button
                Button {
                    initializeDefaultCategories()
                } label: {
                    Label("Initialize Default Categories", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "2196F3"), Color(hex: "1976D2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }

                // Or add custom category
                Button {
                    showingAddCategory = true
                } label: {
                    Label("Add Custom Category", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(Color(hex: "4CAF50"))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(hex: "E8F5E9"))
                        .cornerRadius(12)
                }
            }
        }
    }

    private func initializeDefaultCategories() {
        let defaultCategories = FoodCategory.createDefaults()
        for category in defaultCategories {
            modelContext.insert(category)
        }
        try? modelContext.save()
    }

    private func deleteCategory(_ category: FoodCategory) {
        // Allow deletion of all categories - users can re-add if needed
        modelContext.delete(category)
    }

    private func moveCategories(from source: IndexSet, to destination: Int) {
        var mutableCategories = Array(categories)
        mutableCategories.move(fromOffsets: source, toOffset: destination)

        for (index, category) in mutableCategories.enumerated() {
            category.sortOrder = index
        }

        try? modelContext.save()
    }
}

