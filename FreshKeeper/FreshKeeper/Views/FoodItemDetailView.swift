//
//  FoodItemDetailView.swift
//  FreshKeeper
//

import SwiftUI
import SwiftData

struct FoodItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var item: FoodItem
    @State private var showDeleteConfirmation = false
    @State private var showUpdateAnimation = false
    @State private var showEditLocation = false
    @State private var showEditCategory = false
    @State private var showEditExpiry = false
    @State private var showEditName = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Photo Section
                if let photoData = item.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                } else {
                    ZStack {
                        LinearGradient(
                            colors: [
                                Color(hex: "E3F2FD"),
                                Color(hex: "BBDEFB")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        Text(item.category?.icon ?? "📦")
                            .font(.system(size: 120))
                    }
                    .frame(height: 300)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                }

                // Info Cards
                VStack(spacing: 16) {
                    // Quantity Card with Update Controls
                    VStack(spacing: 20) {
                        HStack {
                            Label("Current Stock", systemImage: "cube.box.fill")
                                .font(.headline)
                                .foregroundColor(Color(hex: "666666"))
                            Spacer()
                        }

                        HStack(spacing: 20) {
                            Button {
                                decreaseQuantity()
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(item.quantity > 1 ? Color(hex: "FF5722") : .gray)
                            }
                            .disabled(item.quantity <= 0)

                            VStack(spacing: 4) {
                                Text("\(item.quantity)")
                                    .font(.system(size: 56, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "4CAF50"), Color(hex: "2196F3")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .scaleEffect(showUpdateAnimation ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: showUpdateAnimation)

                                Text("items")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "666666"))
                            }
                            .frame(minWidth: 120)

                            Button {
                                increaseQuantity()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(hex: "4CAF50"))
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)

                    // Details Card
                    VStack(spacing: 16) {
                        EditableDetailRow(
                            icon: "mappin.and.ellipse",
                            label: "Storage Location",
                            value: item.storageLocation?.name ?? "Unknown",
                            onEdit: { showEditLocation = true }
                        )

                        Divider()

                        EditableDetailRow(
                            icon: "tag.fill",
                            label: "Category",
                            value: item.category != nil ? "\(item.category!.icon) \(item.category!.name)" : "Unknown",
                            onEdit: { showEditCategory = true }
                        )

                        Divider()

                        DetailRow(
                            icon: "calendar",
                            label: "Date Added",
                            value: formatDate(item.dateAdded)
                        )

                        if item.expiryDate != nil {
                            Divider()

                            EditableDetailRow(
                                icon: "calendar.badge.clock",
                                label: "Expiry Date",
                                value: formatExpiryDate(),
                                isWarning: item.isExpired || item.isExpiringSoon,
                                onEdit: { showEditExpiry = true }
                            )
                        } else {
                            Divider()

                            Button {
                                showEditExpiry = true
                            } label: {
                                HStack {
                                    Label("Add Expiry Date", systemImage: "calendar.badge.plus")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(hex: "2196F3"))

                                    Spacer()

                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(Color(hex: "2196F3"))
                                }
                            }
                        }

                        if !item.notes.isEmpty {
                            Divider()

                            VStack(alignment: .leading, spacing: 8) {
                                Label("Notes", systemImage: "note.text")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: "666666"))

                                Text(item.notes)
                                    .font(.body)
                                    .foregroundColor(Color(hex: "1A1A1A"))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)

                    // Delete Button
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Item", systemImage: "trash.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(hex: "F8F9FA"))
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditName = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(Color(hex: "2196F3"))
                }
            }
        }
        .confirmationDialog(
            "Delete this item?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteItem()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showEditLocation) {
            EditLocationSheet(item: item)
        }
        .sheet(isPresented: $showEditCategory) {
            EditCategorySheet(item: item)
        }
        .sheet(isPresented: $showEditExpiry) {
            EditExpirySheet(item: item)
        }
        .sheet(isPresented: $showEditName) {
            EditNameSheet(item: item)
        }
    }

    private func increaseQuantity() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            item.quantity += 1
            triggerUpdateAnimation()
        }
    }

    private func decreaseQuantity() {
        if item.quantity > 1 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                item.quantity -= 1
                triggerUpdateAnimation()
            }
        } else {
            // If quantity would be 0, show confirmation before deleting
            showDeleteConfirmation = true
        }
    }

    private func triggerUpdateAnimation() {
        showUpdateAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showUpdateAnimation = false
        }
    }

    private func deleteItem() {
        modelContext.delete(item)
        dismiss()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatExpiryDate() -> String {
        guard let expiryDate = item.expiryDate else { return "Not set" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateStr = formatter.string(from: expiryDate)

        if item.isExpired {
            let days = abs(item.daysUntilExpiry ?? 0)
            return "\(dateStr) (Expired \(days)d ago)"
        } else if let days = item.daysUntilExpiry {
            return days == 0 ? "\(dateStr) (Today!)" : "\(dateStr) (\(days)d left)"
        }
        return dateStr
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "666666"))

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(Color(hex: "1A1A1A"))
        }
    }
}

struct EditableDetailRow: View {
    let icon: String
    let label: String
    let value: String
    var isWarning: Bool = false
    let onEdit: () -> Void

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "666666"))

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(isWarning ? Color(hex: "FF9800") : Color(hex: "1A1A1A"))
                .fontWeight(isWarning ? .bold : .regular)

            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(Color(hex: "2196F3"))
                    .font(.title3)
            }
        }
    }
}

struct EditLocationSheet: View {
    @Environment(\.dismiss) var dismiss
    @Query(sort: \StorageLocation.sortOrder) private var storageLocations: [StorageLocation]
    @Bindable var item: FoodItem

    var body: some View {
        NavigationStack {
            List {
                ForEach(storageLocations) { location in
                    Button {
                        item.storageLocation = location
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: location.icon)
                                .foregroundColor(Color(hex: location.colorHex))
                            Text(location.name)
                                .foregroundColor(Color(hex: "1A1A1A"))
                            Spacer()
                            if item.storageLocation?.id == location.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "4CAF50"))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Change Location")
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

struct EditCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @Query(sort: \FoodCategory.sortOrder) private var foodCategories: [FoodCategory]
    @Bindable var item: FoodItem

    var body: some View {
        NavigationStack {
            List {
                ForEach(foodCategories) { category in
                    Button {
                        item.category = category
                        dismiss()
                    } label: {
                        HStack {
                            Text(category.icon)
                            Text(category.name)
                                .foregroundColor(Color(hex: "1A1A1A"))
                            Spacer()
                            if item.category?.id == category.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "4CAF50"))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Change Category")
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

struct EditExpirySheet: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var item: FoodItem
    @State private var expiryDate: Date
    @State private var hasExpiry: Bool

    init(item: FoodItem) {
        self.item = item
        _expiryDate = State(initialValue: item.expiryDate ?? Date().addingTimeInterval(7 * 24 * 60 * 60))
        _hasExpiry = State(initialValue: item.expiryDate != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Set Expiry Date", isOn: $hasExpiry)
                        .tint(Color(hex: "4CAF50"))

                    if hasExpiry {
                        DatePicker(
                            "Expiry Date",
                            selection: $expiryDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .tint(Color(hex: "FF9800"))

                        HStack(spacing: 8) {
                            ForEach([3, 7, 14, 30], id: \.self) { days in
                                Button {
                                    expiryDate = Date().addingTimeInterval(Double(days) * 24 * 60 * 60)
                                } label: {
                                    Text("\(days)d")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "E3F2FD"))
                                        .foregroundColor(Color(hex: "2196F3"))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Expiry Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        item.expiryDate = hasExpiry ? expiryDate : nil
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditNameSheet: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var item: FoodItem
    @State private var editedName: String

    init(item: FoodItem) {
        self.item = item
        _editedName = State(initialValue: item.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Food name", text: $editedName)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Color(hex: "1A1A1A"))
                }
            }
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !editedName.trimmingCharacters(in: .whitespaces).isEmpty {
                            item.name = editedName.trimmingCharacters(in: .whitespaces)
                        }
                        dismiss()
                    }
                    .disabled(editedName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
