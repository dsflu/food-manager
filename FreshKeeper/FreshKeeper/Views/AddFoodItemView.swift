//
//  AddFoodItemView.swift
//  FreshKeeper
//

import SwiftUI
import SwiftData

struct AddFoodItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \StorageLocation.sortOrder) private var storageLocations: [StorageLocation]
    @Query(sort: \FoodCategory.sortOrder) private var foodCategories: [FoodCategory]

    @State private var name = ""
    @State private var quantity = 1
    @State private var selectedLocation: StorageLocation?
    @State private var selectedCategory: FoodCategory?
    @State private var notes = ""
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var showImagePicker = false
    @State private var showImageOptions = false
    @State private var hasExpiryDate = false
    @State private var expiryDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // Default 7 days from now
    @State private var daysUntilExpiry = 7
    @State private var showAddCategory = false
    @State private var customCategoryName = ""
    @State private var customCategoryIcon = "📦"

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F9FA")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Photo Section
                        photoSection

                        // Input Fields
                        VStack(spacing: 16) {
                            // Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Food Name", systemImage: "text.cursor")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                TextField("e.g., Chicken Breast", text: $name)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }

                            // Quantity Stepper
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Quantity", systemImage: "cube.box.fill")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                HStack {
                                    Button {
                                        if quantity > 1 {
                                            quantity -= 1
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(quantity > 1 ? Color(hex: "FF5722") : Color(hex: "CCCCCC"))
                                    }
                                    .disabled(quantity <= 1)

                                    Spacer()

                                    Text("\(quantity)")
                                        .font(.system(.title, design: .rounded))
                                        .fontWeight(.heavy)
                                        .foregroundColor(Color(hex: "1A1A1A"))
                                        .frame(minWidth: 60)

                                    Spacer()

                                    Button {
                                        quantity += 1
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(Color(hex: "4CAF50"))
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }

                            // Storage Location Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Storage Location", systemImage: "refrigerator")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(storageLocations) { location in
                                            LocationButton(
                                                location: location,
                                                isSelected: selectedLocation?.id == location.id
                                            ) {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedLocation = location
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Category Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Category", systemImage: "tag.fill")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(foodCategories) { category in
                                            CategoryChip(
                                                category: category,
                                                isSelected: selectedCategory?.id == category.id
                                            ) {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedCategory = category
                                                }
                                            }
                                        }

                                        // Add custom category button
                                        Button {
                                            showAddCategory = true
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.system(.caption, design: .rounded))
                                                Text("Add Custom")
                                                    .font(.system(.subheadline, design: .rounded))
                                                    .fontWeight(.semibold)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(Color(hex: "E3F2FD"))
                                            .foregroundColor(Color(hex: "2196F3"))
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color(hex: "2196F3"), lineWidth: 1.5)
                                            )
                                        }
                                    }
                                }
                            }

                            // Notes Field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Notes (Optional)", systemImage: "note.text")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                TextField("Add any notes...", text: $notes, axis: .vertical)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .lineLimit(3...5)
                            }

                            // Expiry Date Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label("Best Before / Expiry", systemImage: "calendar.badge.clock")
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "1A1A1A"))

                                    Spacer()

                                    Toggle("", isOn: $hasExpiryDate)
                                        .labelsHidden()
                                        .tint(Color(hex: "4CAF50"))
                                }

                                if hasExpiryDate {
                                    VStack(spacing: 12) {
                                        // Quick days selector
                                        HStack(spacing: 8) {
                                            ForEach([3, 7, 14, 30], id: \.self) { days in
                                                Button {
                                                    daysUntilExpiry = days
                                                    expiryDate = Date().addingTimeInterval(Double(days) * 24 * 60 * 60)
                                                } label: {
                                                    Text("\(days)d")
                                                        .font(.system(.caption, design: .rounded))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(daysUntilExpiry == days ? .white : Color(hex: "1A1A1A"))
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .background(daysUntilExpiry == days ? Color(hex: "FF9800") : Color.white)
                                                        .cornerRadius(8)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                                        )
                                                }
                                            }
                                        }

                                        // Custom date picker
                                        DatePicker(
                                            "Expiry Date",
                                            selection: $expiryDate,
                                            in: Date()...,
                                            displayedComponents: .date
                                        )
                                        .datePickerStyle(.compact)
                                        .font(.system(.body, design: .rounded))
                                        .tint(Color(hex: "FF9800"))
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .onChange(of: expiryDate) { _, newDate in
                                            let days = Calendar.current.dateComponents([.day], from: Date(), to: newDate).day ?? 0
                                            daysUntilExpiry = days
                                        }

                                        // Days count display
                                        HStack {
                                            Image(systemName: "clock.fill")
                                                .foregroundColor(Color(hex: "FF9800"))
                                            Text("Expires in \(daysUntilExpiry) day\(daysUntilExpiry == 1 ? "" : "s")")
                                                .font(.system(.caption, design: .rounded))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(hex: "666666"))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "FFF3E0"))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Save Button
                        Button {
                            saveItem()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Add to Inventory")
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
            .navigationTitle("Add Food Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(image: $capturedImage)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $capturedImage)
            }
            .sheet(isPresented: $showAddCategory) {
                AddCustomCategorySheet(
                    categoryName: $customCategoryName,
                    categoryIcon: $customCategoryIcon,
                    onSave: {
                        let newCategory = FoodCategory(
                            name: customCategoryName,
                            icon: customCategoryIcon,
                            sortOrder: (foodCategories.map { $0.sortOrder }.max() ?? -1) + 1,
                            isDefault: false
                        )
                        modelContext.insert(newCategory)
                        selectedCategory = newCategory
                        customCategoryName = ""
                        customCategoryIcon = "📦"
                        showAddCategory = false
                    }
                )
            }
            .confirmationDialog("Choose Photo Source", isPresented: $showImageOptions) {
                Button("Take Photo") {
                    showCamera = true
                }
                Button("Choose from Library") {
                    showImagePicker = true
                }
                if capturedImage != nil {
                    Button("Remove Photo", role: .destructive) {
                        capturedImage = nil
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear {
                // Set default storage location to first one (Fridge)
                if selectedLocation == nil && !storageLocations.isEmpty {
                    selectedLocation = storageLocations.first
                }
                // Set default category to "Other"
                if selectedCategory == nil && !foodCategories.isEmpty {
                    selectedCategory = foodCategories.first(where: { $0.name == "Other" }) ?? foodCategories.first
                }
            }
        }
    }

    private var photoSection: some View {
        VStack(spacing: 12) {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "4CAF50"), lineWidth: 3)
                    )
                    .padding(.horizontal)
            } else {
                Button {
                    showImageOptions = true
                } label: {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "4CAF50").opacity(0.2), Color(hex: "2196F3").opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Image(systemName: "camera.fill")
                                .font(.system(size: 35))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "4CAF50"), Color(hex: "2196F3")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        VStack(spacing: 4) {
                            Text("Add Photo")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "1A1A1A"))

                            Text("Take a photo or choose from library")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "666666"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundStyle(.secondary.opacity(0.3))
                    )
                }
                .padding(.horizontal)
            }

            if capturedImage != nil {
                Button {
                    showImageOptions = true
                } label: {
                    Label("Change Photo", systemImage: "arrow.triangle.2.circlepath")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "2196F3"))
                }
            }
        }
    }

    private func saveItem() {
        // Compress image more aggressively for better performance
        let imageData = capturedImage?.jpegData(compressionQuality: 0.5)

        let item = FoodItem(
            name: name,
            quantity: quantity,
            expiryDate: hasExpiryDate ? expiryDate : nil,
            photoData: imageData,
            notes: notes
        )

        // Set relationships
        item.storageLocation = selectedLocation
        item.category = selectedCategory

        modelContext.insert(item)
        dismiss()
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(.body, design: .rounded))
            .fontWeight(.medium)
            .padding()
            .background(Color.white)
            .foregroundColor(Color(hex: "1A1A1A"))
            .tint(Color(hex: "4CAF50"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

struct LocationButton: View {
    let location: StorageLocation
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: location.icon)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(location.name)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
            }
            .frame(minWidth: 80)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(isSelected ? Color(hex: location.colorHex) : Color.white)
            .foregroundColor(isSelected ? .white : Color(hex: "1A1A1A"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: location.colorHex) : Color.gray.opacity(0.2), lineWidth: 2)
            )
        }
    }
}

struct CategoryChip: View {
    let category: FoodCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(category.icon)
                    .font(.body)
                Text(category.name)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color(hex: "4CAF50") : Color.white)
            .foregroundColor(isSelected ? .white : Color(hex: "1A1A1A"))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color(hex: "4CAF50") : Color.gray.opacity(0.2), lineWidth: 1.5)
            )
        }
    }
}

struct AddCustomCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var categoryName: String
    @Binding var categoryIcon: String
    let onSave: () -> Void

    let availableIcons = [
        "🥩", "🍗", "🐟", "🥬", "🥕", "🍎", "🍊", "🥛",
        "🧀", "🍞", "🥐", "🍕", "🍔", "🍱", "🍜", "🧃",
        "☕", "🍰", "🍪", "🥫", "🌰", "🥚", "🍚", "📦"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Category Name", text: $categoryName)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Color(hex: "1A1A1A"))
                }

                Section(header: Text("Choose Icon")) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 12
                    ) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                categoryIcon = icon
                            } label: {
                                Text(icon)
                                    .font(.system(size: 32))
                                    .frame(width: 50, height: 50)
                                    .background(categoryIcon == icon ? Color(hex: "E8F4F8") : Color.clear)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(categoryIcon == icon ? Color(hex: "4CAF50") : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
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

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
