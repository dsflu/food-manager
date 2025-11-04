//
//  AddFoodItemView.swift
//  FreshKeeper
//

import SwiftUI
import SwiftData

struct AddFoodItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var quantity = 1
    @State private var selectedLocation: StorageLocation = .fridge
    @State private var selectedCategory: FoodCategory = .other
    @State private var notes = ""
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var showImagePicker = false
    @State private var showImageOptions = false

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
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                TextField("e.g., Chicken Breast", text: $name)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }

                            // Quantity Stepper
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Quantity", systemImage: "cube.box.fill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                HStack {
                                    Button {
                                        if quantity > 1 {
                                            quantity -= 1
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(quantity > 1 ? Color(hex: "FF5722") : .gray)
                                    }
                                    .disabled(quantity <= 1)

                                    Spacer()

                                    Text("\(quantity)")
                                        .font(.title)
                                        .fontWeight(.bold)
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
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                HStack(spacing: 12) {
                                    ForEach(StorageLocation.allCases, id: \.self) { location in
                                        LocationButton(
                                            location: location,
                                            isSelected: selectedLocation == location
                                        ) {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedLocation = location
                                            }
                                        }
                                    }
                                }
                            }

                            // Category Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Category", systemImage: "tag.fill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(FoodCategory.allCases, id: \.self) { category in
                                            CategoryChip(
                                                category: category,
                                                isSelected: selectedCategory == category
                                            ) {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedCategory = category
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Notes Field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Notes (Optional)", systemImage: "note.text")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                TextField("Add any notes...", text: $notes, axis: .vertical)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .lineLimit(3...5)
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
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text("Take a photo or choose from library")
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
            storageLocation: selectedLocation,
            category: selectedCategory,
            photoData: imageData,
            notes: notes
        )

        modelContext.insert(item)
        dismiss()
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .foregroundColor(.primary)
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

                Text(location.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color(hex: "4CAF50") : Color.white)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "4CAF50") : Color.gray.opacity(0.2), lineWidth: 2)
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
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color(hex: "4CAF50") : Color.white)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color(hex: "4CAF50") : Color.gray.opacity(0.2), lineWidth: 1.5)
            )
        }
    }
}
