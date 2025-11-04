//
//  FoodItemCard.swift
//  FreshKeeper
//

import SwiftUI

struct FoodItemCard: View {
    let item: FoodItem
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            ZStack(alignment: .topTrailing) {
                if let photoData = item.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 140)
                        .clipped()
                        .drawingGroup() // Optimize rendering performance
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
                            .font(.system(size: 50))
                    }
                    .frame(height: 140)
                }

                // Location Badge
                HStack(spacing: 4) {
                    Image(systemName: item.storageLocation.icon)
                        .font(.caption2)
                    Text(item.storageLocation.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .padding(8)
            }

            // Info Section
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack {
                    Label("\(item.quantity)", systemImage: "cube.box.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(timeAgo(from: item.dateAdded))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(isPressed ? 0.15 : 0.08), radius: isPressed ? 8 : 5, x: 0, y: isPressed ? 4 : 2)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50) {
            // On release
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }

    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
