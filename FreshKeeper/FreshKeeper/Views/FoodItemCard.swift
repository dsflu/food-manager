//
//  FoodItemCard.swift
//  FreshKeeper
//

import SwiftUI

struct FoodItemCard: View {
    let item: FoodItem

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
                if let location = item.storageLocation {
                    HStack(spacing: 4) {
                        Image(systemName: location.icon)
                            .font(.caption2)
                        Text(location.name)
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding(8)
                }
            }

            // Info Section
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "1A1A1A"))
                    .lineLimit(1)

                HStack {
                    Label("\(item.quantity)", systemImage: "cube.box.fill")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "4CAF50"))

                    Spacer()

                    Text(timeAgo(from: item.dateAdded))
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "999999"))
                }
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }

    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
