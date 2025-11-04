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

                        Text(item.category.icon)
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
                                .foregroundStyle(.secondary)
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
                                    .foregroundStyle(.secondary)
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
                        DetailRow(
                            icon: "mappin.and.ellipse",
                            label: "Storage Location",
                            value: item.storageLocation?.name ?? "Unknown"
                        )

                        Divider()

                        DetailRow(
                            icon: "tag.fill",
                            label: "Category",
                            value: "\(item.category.icon) \(item.category.rawValue)"
                        )

                        Divider()

                        DetailRow(
                            icon: "calendar",
                            label: "Date Added",
                            value: formatDate(item.dateAdded)
                        )

                        if !item.notes.isEmpty {
                            Divider()

                            VStack(alignment: .leading, spacing: 8) {
                                Label("Notes", systemImage: "note.text")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                Text(item.notes)
                                    .font(.body)
                                    .foregroundColor(.primary)
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
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}
