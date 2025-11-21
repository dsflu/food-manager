//
//  CategoryManagementView.swift
//  FreshKeeper
//

import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FoodCategory.sortOrder) private var categories: [FoodCategory]

    @State private var showingAddCategory = false
    @State private var editingCategory: FoodCategory?
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F9FA")
                    .ignoresSafeArea()

                if categories.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Info Card
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(Color(hex: "2196F3"))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Manage Categories")
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "1A1A1A"))

                                    Text("Drag to reorder or add custom categories. Default categories cannot be deleted.")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(hex: "666666"))

                                    // Check if missing new defaults
                                    if hasMissingDefaults {
                                        Button {
                                            addMissingDefaults()
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.caption2)
                                                Text("Add New Cooking Categories")
                                            }
                                            .font(.system(.caption, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(hex: "4CAF50"))
                                            .padding(.top, 4)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(hex: "E3F2FD"))
                            .cornerRadius(12)
                            .padding(.horizontal)

                            // Categories List with optional reordering
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
                                        if !category.isDefault {
                                            modelContext.delete(category)
                                        }
                                    }
                                }
                            }
                            .listStyle(PlainListStyle())
                            .environment(\.editMode, $editMode)
                            .frame(height: CGFloat(min(categories.count * 80, 600)))
                            .scrollDisabled(categories.count <= 8)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Food Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Edit/Reorder button
                        Button {
                            withAnimation {
                                editMode = editMode == .active ? .inactive : .active
                            }
                        } label: {
                            Text(editMode == .active ? "Done" : "Reorder")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "2196F3"))
                        }

                        // Add button
                        Button {
                            showingAddCategory = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(Color(hex: "4CAF50"))
                        }
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

            Text("Add your first category")
                .font(.system(.body, design: .rounded))
                .foregroundColor(Color(hex: "666666"))

            Button {
                showingAddCategory = true
            } label: {
                Label("Add Category", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "4CAF50"))
                    .cornerRadius(12)
            }
        }
    }

    private func deleteCategory(_ category: FoodCategory) {
        guard !category.isDefault else { return }
        modelContext.delete(category)
    }

    private var hasMissingDefaults: Bool {
        let defaultCategories = FoodCategory.createDefaults()
        let existingNames = Set(categories.map { $0.name })
        return defaultCategories.contains { !existingNames.contains($0.name) }
    }

    private func addMissingDefaults() {
        let defaultCategories = FoodCategory.createDefaults()
        let existingNames = Set(categories.map { $0.name })
        let maxSortOrder = categories.map { $0.sortOrder }.max() ?? -1

        var newSortOrder = maxSortOrder + 1
        for defaultCategory in defaultCategories {
            if !existingNames.contains(defaultCategory.name) {
                let newCategory = FoodCategory(
                    name: defaultCategory.name,
                    icon: defaultCategory.icon,
                    sortOrder: newSortOrder,
                    isDefault: true
                )
                modelContext.insert(newCategory)
                newSortOrder += 1
            }
        }

        try? modelContext.save()
    }

    private func moveCategories(from source: IndexSet, to destination: Int) {
        // Create a mutable array from the sorted categories
        var mutableCategories = Array(categories)

        // Move the items
        mutableCategories.move(fromOffsets: source, toOffset: destination)

        // Update sortOrder for all categories
        for (index, category) in mutableCategories.enumerated() {
            category.sortOrder = index
        }

        // Save changes
        try? modelContext.save()
    }
}

struct CategoryRow: View {
    let category: FoodCategory
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Text(category.icon)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(Color(hex: "F0F0F0"))
                .clipShape(Circle())

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(category.name)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "1A1A1A"))

                    if category.isDefault {
                        Text("DEFAULT")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.heavy)
                            .foregroundColor(Color(hex: "4CAF50"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "4CAF50").opacity(0.1))
                            .cornerRadius(4)
                    }
                }

                Text("\(category.items?.count ?? 0) items")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "666666"))
            }

            Spacer()

            // Actions
            HStack(spacing: 12) {
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "2196F3"))
                }

                if !category.isDefault {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "FF5722"))
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .confirmationDialog(
            "Delete \(category.name)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Items in this category will have no category. This action cannot be undone.")
        }
    }
}

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FoodCategory.sortOrder) private var existingCategories: [FoodCategory]

    @State private var name = ""
    @State private var selectedEmoji = "📦"
    @State private var showEmojiPicker = false

    let commonFoodEmojis = [
        "🥩", "🦐", "🥬", "🍎", "🥛", "🍚", "🍝", "🍞",
        "🫒", "🧂", "🥫", "🌿", "🍿", "🧃", "🍱", "🧊",
        "🧁", "📦", "🥚", "🧈", "🧀", "🥓", "🍗", "🐟",
        "🦞", "🦀", "🦑", "🥦", "🥕", "🌽", "🥒", "🍅",
        "🍆", "🥔", "🧄", "🧅", "🍄", "🌶️", "🥜", "🌰",
        "🍇", "🍊", "🍋", "🍌", "🍍", "🥭", "🍑", "🍒",
        "🍓", "🫐", "🥝", "🥥", "🍉", "🍈", "🥑", "🫘"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F9FA")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Category Name", systemImage: "text.cursor")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "1A1A1A"))

                            TextField("e.g., Sauces & Condiments", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        .padding(.horizontal)

                        // Emoji Picker
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Icon", systemImage: "face.smiling")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                Spacer()

                                Text("Selected: \(selectedEmoji)")
                                    .font(.title2)
                            }
                            .padding(.horizontal)

                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible()), count: 8),
                                spacing: 12
                            ) {
                                ForEach(commonFoodEmojis, id: \.self) { emoji in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedEmoji = emoji
                                        }
                                    } label: {
                                        Text(emoji)
                                            .font(.title2)
                                            .frame(width: 40, height: 40)
                                            .background(selectedEmoji == emoji ? Color(hex: "4CAF50").opacity(0.2) : Color.white)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedEmoji == emoji ? Color(hex: "4CAF50") : Color.gray.opacity(0.2), lineWidth: 2)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Save Button
                        Button {
                            saveCategory()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Add Category")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "4CAF50"), Color(hex: "45A049")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveCategory() {
        let newSortOrder = (existingCategories.map { $0.sortOrder }.max() ?? -1) + 1

        let category = FoodCategory(
            name: name,
            icon: selectedEmoji,
            sortOrder: newSortOrder,
            isDefault: false
        )

        modelContext.insert(category)
        dismiss()
    }
}

struct EditCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var category: FoodCategory

    let commonFoodEmojis = [
        "🥩", "🦐", "🥬", "🍎", "🥛", "🍚", "🍝", "🍞",
        "🫒", "🧂", "🥫", "🌿", "🍿", "🧃", "🍱", "🧊",
        "🧁", "📦", "🥚", "🧈", "🧀", "🥓", "🍗", "🐟",
        "🦞", "🦀", "🦑", "🥦", "🥕", "🌽", "🥒", "🍅",
        "🍆", "🥔", "🧄", "🧅", "🍄", "🌶️", "🥜", "🌰",
        "🍇", "🍊", "🍋", "🍌", "🍍", "🥭", "🍑", "🍒",
        "🍓", "🫐", "🥝", "🥥", "🍉", "🍈", "🥑", "🫘"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F9FA")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Category Name", systemImage: "text.cursor")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "1A1A1A"))

                            TextField("Category name", text: $category.name)
                                .textFieldStyle(CustomTextFieldStyle())
                                .disabled(category.isDefault)
                        }
                        .padding(.horizontal)

                        if category.isDefault {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color(hex: "FF9800"))

                                Text("Default categories can only have their icon changed.")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(hex: "666666"))
                            }
                            .padding()
                            .background(Color(hex: "FFF3E0"))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        // Emoji Picker
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Icon", systemImage: "face.smiling")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                Spacer()

                                Text("Selected: \(category.icon)")
                                    .font(.title2)
                            }
                            .padding(.horizontal)

                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible()), count: 8),
                                spacing: 12
                            ) {
                                ForEach(commonFoodEmojis, id: \.self) { emoji in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            category.icon = emoji
                                        }
                                    } label: {
                                        Text(emoji)
                                            .font(.title2)
                                            .frame(width: 40, height: 40)
                                            .background(category.icon == emoji ? Color(hex: "4CAF50").opacity(0.2) : Color.white)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(category.icon == emoji ? Color(hex: "4CAF50") : Color.gray.opacity(0.2), lineWidth: 2)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}