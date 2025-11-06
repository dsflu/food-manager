//
//  CookbookView.swift
//  FreshKeeper
//
//  Browse and manage saved recipes
//

import SwiftUI
import SwiftData

struct CookbookView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Recipe.dateCreated, order: .reverse) private var recipes: [Recipe]

    @State private var selectedRecipe: Recipe?
    @State private var showRecipeDetail = false

    var favoriteRecipes: [Recipe] {
        recipes.filter { $0.isFavorite }
    }

    var recentRecipes: [Recipe] {
        recipes.filter { !$0.isFavorite }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !favoriteRecipes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Favorites", systemImage: "star.fill")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(Color(hex: "FFD700"))
                                .padding(.horizontal)

                            ForEach(favoriteRecipes) { recipe in
                                recipeCard(recipe, isFavorite: true)
                            }
                        }
                    }

                    if !recentRecipes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Recent", systemImage: "clock")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(Color(hex: "666666"))
                                .padding(.horizontal)

                            ForEach(recentRecipes) { recipe in
                                recipeCard(recipe, isFavorite: false)
                            }
                        }
                    }

                    if recipes.isEmpty {
                        emptyStateView
                    }
                }
                .padding(.vertical)
            }
            .background(Color(hex: "F8F9FA"))
            .navigationTitle("My Cookbook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }

    private func recipeCard(_ recipe: Recipe, isFavorite: Bool) -> some View {
        Button {
            selectedRecipe = recipe
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.dishName)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color(hex: "1A1A1A"))

                    HStack(spacing: 12) {
                        Label(recipe.cuisine, systemImage: "globe")
                            .font(.caption)
                        Label(recipe.cookingTime, systemImage: "clock")
                            .font(.caption)
                        Label(recipe.difficulty, systemImage: "chart.bar")
                            .font(.caption)
                    }
                    .foregroundColor(Color(hex: "666666"))

                    Text(formatDate(recipe.dateCreated))
                        .font(.caption2)
                        .foregroundColor(Color(hex: "999999"))
                }

                Spacer()

                HStack(spacing: 12) {
                    // Toggle favorite button
                    Button {
                        recipe.isFavorite.toggle()
                        try? modelContext.save()
                    } label: {
                        Image(systemName: recipe.isFavorite ? "star.fill" : "star")
                            .foregroundColor(Color(hex: "FFD700"))
                    }

                    // Delete button
                    Button {
                        modelContext.delete(recipe)
                        try? modelContext.save()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(Color(hex: "FF5722"))
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "CCCCCC"))

            Text("No Saved Recipes")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color(hex: "666666"))

            Text("Generate dinner recommendations and save your favorites here")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Color(hex: "999999"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Recipe Detail View
struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let recipe: Recipe

    var ingredients: [[String: Any]] {
        (try? JSONSerialization.jsonObject(with: recipe.ingredients) as? [[String: Any]]) ?? []
    }

    var recipeSteps: [String] {
        (try? JSONSerialization.jsonObject(with: recipe.recipe) as? [String]) ?? []
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.dishName)
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "1A1A1A"))

                        HStack(spacing: 16) {
                            Label(recipe.cuisine, systemImage: "globe")
                            Label(recipe.cookingTime, systemImage: "clock")
                            Label(recipe.difficulty, systemImage: "chart.bar")
                        }
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "666666"))
                    }
                    .padding()

                    // Reason
                    Text(recipe.reason)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Color(hex: "333333"))
                        .padding()
                        .background(Color(hex: "FFF3CD"))
                        .cornerRadius(12)
                        .padding(.horizontal)

                    // Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Ingredients", systemImage: "cart")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Color(hex: "1A1A1A"))
                            .padding(.horizontal)

                        ForEach(Array(ingredients.enumerated()), id: \.offset) { _, ingredient in
                            HStack {
                                Text("• \(ingredient["foodItem"] as? String ?? "")")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Color(hex: "333333"))
                                Spacer()
                                Text(ingredient["quantity"] as? String ?? "")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Color(hex: "666666"))
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    Divider()
                        .padding(.horizontal)

                    // Recipe Steps
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Instructions", systemImage: "list.number")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Color(hex: "1A1A1A"))
                            .padding(.horizontal)

                        ForEach(Array(recipeSteps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color(hex: "4CAF50"))
                                    .clipShape(Circle())

                                Text(step)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Color(hex: "333333"))
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    // Video Links
                    if recipe.videoSearchChinese != nil || recipe.videoSearchEnglish != nil {
                        Divider()
                            .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 12) {
                            Label("Video Tutorials", systemImage: "play.rectangle")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(Color(hex: "1A1A1A"))
                                .padding(.horizontal)

                            HStack(spacing: 12) {
                                if let chineseSearch = recipe.videoSearchChinese {
                                    Link(destination: URL(string: "https://search.bilibili.com/all?keyword=\(chineseSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!) {
                                        Label("Bilibili", systemImage: "play.circle")
                                            .font(.caption)
                                            .padding(8)
                                            .background(Color(hex: "00A1D6").opacity(0.1))
                                            .foregroundColor(Color(hex: "00A1D6"))
                                            .cornerRadius(8)
                                    }
                                }

                                if let englishSearch = recipe.videoSearchEnglish {
                                    Link(destination: URL(string: "https://www.youtube.com/results?search_query=\(englishSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!) {
                                        Label("YouTube", systemImage: "play.circle")
                                            .font(.caption)
                                            .padding(8)
                                            .background(Color(hex: "FF0000").opacity(0.1))
                                            .foregroundColor(Color(hex: "FF0000"))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(Color(hex: "F8F9FA"))
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