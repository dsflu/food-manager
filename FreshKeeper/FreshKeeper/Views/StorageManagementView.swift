//
//  StorageManagementView.swift
//  FreshKeeper
//

import SwiftUI
import SwiftData

struct StorageManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \StorageLocation.sortOrder) private var storageLocations: [StorageLocation]

    @State private var showingAddLocation = false
    @State private var editingLocation: StorageLocation?
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F8F9FA")
                    .ignoresSafeArea()

                if storageLocations.isEmpty {
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
                                    Text("Manage Storage Locations")
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "1A1A1A"))

                                    Text("Add custom locations like extra freezers or storage boxes. Default locations cannot be deleted.")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(hex: "666666"))
                                }
                            }
                            .padding()
                            .background(Color(hex: "E3F2FD"))
                            .cornerRadius(12)
                            .padding(.horizontal)

                            // Storage Locations List with optional reordering
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
                                        if !location.isDefault {
                                            modelContext.delete(location)
                                        }
                                    }
                                }
                            }
                            .listStyle(PlainListStyle())
                            .environment(\.editMode, $editMode)
                            .frame(height: CGFloat(storageLocations.count * 100))
                            .scrollDisabled(true)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Storage Locations")
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
                            showingAddLocation = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(Color(hex: "4CAF50"))
                        }
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

            Text("Add your first storage location")
                .font(.system(.body, design: .rounded))
                .foregroundColor(Color(hex: "666666"))

            Button {
                showingAddLocation = true
            } label: {
                Label("Add Location", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "4CAF50"))
                    .cornerRadius(12)
            }
        }
    }

    private func deleteLocation(_ location: StorageLocation) {
        guard !location.isDefault else { return }
        modelContext.delete(location)
    }

    private func moveLocations(from source: IndexSet, to destination: Int) {
        // Create a mutable array from the sorted locations
        var mutableLocations = Array(storageLocations)

        // Move the items
        mutableLocations.move(fromOffsets: source, toOffset: destination)

        // Update sortOrder for all locations
        for (index, location) in mutableLocations.enumerated() {
            location.sortOrder = index
        }

        // Save changes
        try? modelContext.save()
    }
}

struct StorageLocationRow: View {
    let location: StorageLocation
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: location.colorHex, opacity: 0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: location.icon)
                    .font(.title3)
                    .foregroundColor(Color(hex: location.colorHex))
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(location.name)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "1A1A1A"))

                    if location.isDefault {
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

                Text("\(location.items?.count ?? 0) items")
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

                if !location.isDefault {
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
        .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 5, x: 0, y: 2)
        .confirmationDialog(
            "Delete \(location.name)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All items in this location will be moved to 'Unknown'. This action cannot be undone.")
        }
    }
}

struct AddStorageLocationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \StorageLocation.sortOrder) private var existingLocations: [StorageLocation]

    @State private var name = ""
    @State private var selectedIcon = "square.grid.2x2"
    @State private var selectedColor = "4CAF50"

    let availableIcons = [
        "refrigerator", "snowflake", "cube.box", "archivebox",
        "shippingbox", "cabinet", "cart", "basket",
        "square.grid.2x2", "square.grid.3x3", "tray.2", "storefront"
    ]

    let availableColors = [
        ("4CAF50", "Green"),
        ("2196F3", "Blue"),
        ("00BCD4", "Cyan"),
        ("9C27B0", "Purple"),
        ("FF9800", "Orange"),
        ("F44336", "Red"),
        ("795548", "Brown"),
        ("607D8B", "Grey")
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
                            Label("Location Name", systemImage: "text.cursor")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "1A1A1A"))

                            TextField("e.g., Garage Freezer", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        .padding(.horizontal)

                        // Icon Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Icon", systemImage: "square.grid.3x3")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "1A1A1A"))
                                .padding(.horizontal)

                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ],
                                spacing: 12
                            ) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedIcon = icon
                                        }
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedIcon == icon ? Color(hex: selectedColor) : Color.white)

                                            Image(systemName: icon)
                                                .font(.title2)
                                                .foregroundColor(selectedIcon == icon ? .white : Color(hex: "1A1A1A"))
                                        }
                                        .frame(height: 60)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedIcon == icon ? Color(hex: selectedColor) : Color.gray.opacity(0.2), lineWidth: 2)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Color Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Color", systemImage: "paintpalette")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "1A1A1A"))
                                .padding(.horizontal)

                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ],
                                spacing: 12
                            ) {
                                ForEach(availableColors, id: \.0) { colorHex, colorName in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedColor = colorHex
                                        }
                                    } label: {
                                        HStack {
                                            Circle()
                                                .fill(Color(hex: colorHex))
                                                .frame(width: 30, height: 30)

                                            Text(colorName)
                                                .font(.system(.body, design: .rounded))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(hex: "1A1A1A"))

                                            Spacer()

                                            if selectedColor == colorHex {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color(hex: colorHex))
                                            }
                                        }
                                        .padding()
                                        .background(selectedColor == colorHex ? Color(hex: colorHex).opacity(0.1) : Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedColor == colorHex ? Color(hex: colorHex) : Color.gray.opacity(0.2), lineWidth: 2)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Save Button
                        Button {
                            saveLocation()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Add Location")
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
            .navigationTitle("Add Storage Location")
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

    private func saveLocation() {
        let newSortOrder = (existingLocations.map { $0.sortOrder }.max() ?? -1) + 1

        let location = StorageLocation(
            name: name,
            icon: selectedIcon,
            colorHex: selectedColor,
            sortOrder: newSortOrder,
            isDefault: false
        )

        modelContext.insert(location)
        dismiss()
    }
}

struct EditStorageLocationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var location: StorageLocation

    let availableIcons = [
        "refrigerator", "snowflake", "cube.box", "archivebox",
        "shippingbox", "cabinet", "cart", "basket",
        "square.grid.2x2", "square.grid.3x3", "tray.2", "storefront"
    ]

    let availableColors = [
        ("4CAF50", "Green"),
        ("2196F3", "Blue"),
        ("00BCD4", "Cyan"),
        ("9C27B0", "Purple"),
        ("FF9800", "Orange"),
        ("F44336", "Red"),
        ("795548", "Brown"),
        ("607D8B", "Grey")
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
                            Label("Location Name", systemImage: "text.cursor")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "1A1A1A"))

                            TextField("Location name", text: $location.name)
                                .textFieldStyle(CustomTextFieldStyle())
                                .disabled(location.isDefault)
                        }
                        .padding(.horizontal)

                        if location.isDefault {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color(hex: "FF9800"))

                                Text("Default locations can only have their icon and color changed.")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(hex: "666666"))
                            }
                            .padding()
                            .background(Color(hex: "FFF3E0"))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        // Icon Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Icon", systemImage: "square.grid.3x3")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "1A1A1A"))
                                .padding(.horizontal)

                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ],
                                spacing: 12
                            ) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            location.icon = icon
                                        }
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(location.icon == icon ? Color(hex: location.colorHex) : Color.white)

                                            Image(systemName: icon)
                                                .font(.title2)
                                                .foregroundColor(location.icon == icon ? .white : Color(hex: "1A1A1A"))
                                        }
                                        .frame(height: 60)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(location.icon == icon ? Color(hex: location.colorHex) : Color.gray.opacity(0.2), lineWidth: 2)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Color Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Color", systemImage: "paintpalette")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "1A1A1A"))
                                .padding(.horizontal)

                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ],
                                spacing: 12
                            ) {
                                ForEach(availableColors, id: \.0) { colorHex, colorName in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            location.colorHex = colorHex
                                        }
                                    } label: {
                                        HStack {
                                            Circle()
                                                .fill(Color(hex: colorHex))
                                                .frame(width: 30, height: 30)

                                            Text(colorName)
                                                .font(.system(.body, design: .rounded))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(hex: "1A1A1A"))

                                            Spacer()

                                            if location.colorHex == colorHex {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color(hex: colorHex))
                                            }
                                        }
                                        .padding()
                                        .background(location.colorHex == colorHex ? Color(hex: colorHex).opacity(0.1) : Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(location.colorHex == colorHex ? Color(hex: colorHex) : Color.gray.opacity(0.2), lineWidth: 2)
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
            .navigationTitle("Edit Location")
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
