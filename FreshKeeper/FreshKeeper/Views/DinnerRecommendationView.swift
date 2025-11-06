//
//  DinnerRecommendationView.swift
//  FreshKeeper
//
//  AI-powered dinner recommendations based on your food inventory
//

import SwiftUI
import SwiftData

struct DinnerRecommendationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var foodItems: [FoodItem]
    @Query(sort: \Recipe.dateCreated, order: .reverse) private var savedRecipes: [Recipe]

    @State private var selectedCuisine: CuisineType = .auto
    @State private var isGenerating = false
    @State private var recommendation: DinnerRecommendation?
    @State private var errorMessage: String?
    @State private var showAPIKeyAlert = false
    @State private var showSaveConfirmation = false
    @State private var showCookbook = false

    private let openAIService = OpenAIService.shared

    // Load last recommendation on appear (only if from today)
    private var lastRecommendation: Recipe? {
        guard let mostRecent = savedRecipes.first(where: { !$0.isFavorite }) else { return nil }

        // Check if the recipe was created today
        let calendar = Calendar.current
        if calendar.isDateInToday(mostRecent.dateCreated) {
            return mostRecent
        }

        // Recipe is from a previous day, don't show it
        return nil
    }

    enum CuisineType: String, CaseIterable {
        case auto = "Smart Choice"
        case chinese = "Chinese"
        case western = "Western"

        var icon: String {
            switch self {
            case .auto: return "🤖"
            case .chinese: return "🥢"
            case .western: return "🍴"
            }
        }

        var description: String {
            switch self {
            case .auto: return "Let AI decide based on ingredients"
            case .chinese: return "Traditional Chinese regional cuisine"
            case .western: return "French & Italian cuisine only"
            }
        }
    }

    struct DinnerRecommendation {
        let dishName: String
        let cuisine: String
        let ingredients: [IngredientUsage]
        let recipe: [String]
        let cookingTime: String
        let difficulty: String
        let videoSearchChinese: String?
        let videoSearchEnglish: String?
        let videoLink: String?
        let reason: String
        let shoppingList: [String]
        var isSavedAsFavorite: Bool = false

        struct IngredientUsage {
            let foodItem: String
            let quantity: String
            let isExpiringSoon: Bool
            let fromInventory: Bool
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    headerSection

                    // Cuisine Selector
                    cuisineSelector

                    // Generate Button
                    generateButton

                    // Recommendation Result or Fresh Day Message
                    if let recommendation = recommendation {
                        recommendationCard(recommendation)
                    } else if !isGenerating && recommendation == nil {
                        freshDayCard
                    }

                    // Error Message
                    if let error = errorMessage {
                        errorCard(error)
                    }
                }
                .padding()
            }
            .background(Color(hex: "F8F9FA"))
            .navigationTitle("Tonight's Dinner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCookbook = true
                    } label: {
                        Image(systemName: "book.fill")
                            .foregroundColor(Color(hex: "FF6B6B"))
                    }
                }
            }
            .alert("API Key Required", isPresented: $showAPIKeyAlert) {
                Button("Go to Settings") {
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please configure your OpenAI API key in Settings to get dinner recommendations.")
            }
            .sheet(isPresented: $showCookbook) {
                CookbookView()
            }
            .alert("Recipe Saved!", isPresented: $showSaveConfirmation) {
                Button("OK", role: .cancel) {
                    // Dismiss immediately without lag
                    showSaveConfirmation = false
                }
                .keyboardShortcut(.defaultAction)
            } message: {
                if recommendation?.isSavedAsFavorite == true {
                    Text("This recipe has been added to your cookbook favorites.")
                } else {
                    Text("This recipe is already in your cookbook.")
                }
            }
            .onAppear {
                loadLastRecommendation()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Inventory Summary - Simple and clean
            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("\(foodItems.filter { $0.isExpiringSoon }.count)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "FF5722"))
                    Text("Expiring Soon")
                        .font(.caption)
                        .foregroundColor(Color(hex: "999999"))
                }

                VStack(spacing: 4) {
                    Text("\(foodItems.count)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "4CAF50"))
                    Text("Total Items")
                        .font(.caption)
                        .foregroundColor(Color(hex: "999999"))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    private func inventoryStat(label: String, count: Int, color: String) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: color))

            Text(label)
                .font(.caption)
                .foregroundColor(Color(hex: "999999"))
        }
    }

    private var cuisineSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Cuisine Preference", systemImage: "globe.asia.australia")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "1A1A1A"))

            VStack(spacing: 12) {
                ForEach(CuisineType.allCases, id: \.self) { type in
                    Button {
                        selectedCuisine = type
                    } label: {
                        HStack {
                            Text(type.icon)
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.rawValue)
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                Text(type.description)
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "666666"))
                            }

                            Spacer()

                            if selectedCuisine == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "4CAF50"))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(Color(hex: "CCCCCC"))
                            }
                        }
                        .padding(12)
                        .background(selectedCuisine == type ? Color(hex: "E8F5E9") : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedCuisine == type ? Color(hex: "4CAF50") : Color(hex: "E0E0E0"), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    private var generateButton: some View {
        Button {
            generateRecommendation()
        } label: {
            HStack {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "sparkles")
                }

                Text(isGenerating ? "Thinking..." : (recommendation == nil ? "Get Today's Recommendation" : "Get New Recommendation"))
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "4CAF50"), Color(hex: "45B545")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Color(hex: "4CAF50").opacity(0.3), radius: 10, x: 0, y: 4)
        }
        .disabled(isGenerating || foodItems.isEmpty)
    }

    private func recommendationCard(_ rec: DinnerRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Dish Header - Clean and lovely design
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(rec.dishName)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "1A1A1A"))

                        HStack(spacing: 6) {
                            Image(systemName: getCuisineIcon(rec.cuisine))
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "4CAF50"))
                            Text(rec.cuisine)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(Color(hex: "666666"))
                        }
                    }

                    Spacer()

                    // Lovely bookmark button
                    Button {
                        toggleFavorite()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(rec.isSavedAsFavorite ? Color(hex: "FFD700") : Color(hex: "F5F5F5"))
                                .frame(width: 40, height: 40)
                            Image(systemName: rec.isSavedAsFavorite ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 18))
                                .foregroundColor(rec.isSavedAsFavorite ? .white : Color(hex: "757575"))
                        }
                    }
                }

                // Time and difficulty pills
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                        Text(rec.cookingTime)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: "F0F4F8"))
                    .foregroundColor(Color(hex: "616161"))
                    .cornerRadius(14)

                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 11))
                        Text(rec.difficulty)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: "F0F4F8"))
                    .foregroundColor(Color(hex: "616161"))
                    .cornerRadius(14)
                }
            }

            // Why this dish
            Text(rec.reason)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Color(hex: "333333"))
                .padding(12)
                .background(Color(hex: "FFF3CD"))
                .cornerRadius(8)

            // Ingredients Section - Split by availability
            VStack(alignment: .leading, spacing: 16) {
                // Ingredients from inventory
                let inventoryIngredients = rec.ingredients.filter { $0.fromInventory }
                let toBuyIngredients = rec.ingredients.filter { !$0.fromInventory }

                if !inventoryIngredients.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "4CAF50"))
                                .font(.system(size: 14))
                            Text("From Your Inventory")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: "4CAF50"))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(inventoryIngredients.enumerated()), id: \.offset) { index, ingredient in
                                HStack {
                                    if ingredient.isExpiringSoon {
                                        Image(systemName: "clock.badge.exclamationmark.fill")
                                            .foregroundColor(Color(hex: "FF9800"))
                                            .font(.system(size: 12))
                                    } else {
                                        Circle()
                                            .fill(Color(hex: "4CAF50"))
                                            .frame(width: 6, height: 6)
                                    }

                                    Text(ingredient.foodItem)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(Color(hex: "1A1A1A"))

                                    Spacer()

                                    Text(ingredient.quantity)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(Color(hex: "666666"))

                                    if ingredient.isExpiringSoon {
                                        Text("expiring")
                                            .font(.system(.caption2, design: .rounded))
                                            .foregroundColor(Color(hex: "FF9800"))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color(hex: "FFF3E0"))
                                            .cornerRadius(4)
                                    }
                                }
                                .padding(.leading, 4)
                            }
                        }
                        .padding(12)
                        .background(Color(hex: "E8F5E9"))
                        .cornerRadius(10)
                    }
                }

                if !toBuyIngredients.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "cart.fill")
                                .foregroundColor(Color(hex: "2196F3"))
                                .font(.system(size: 14))
                            Text("Need to Buy")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: "2196F3"))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(toBuyIngredients.enumerated()), id: \.offset) { index, ingredient in
                                HStack {
                                    Circle()
                                        .fill(Color(hex: "2196F3"))
                                        .frame(width: 6, height: 6)

                                    Text(ingredient.foodItem)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(Color(hex: "1A1A1A"))

                                    Spacer()

                                    Text(ingredient.quantity)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(Color(hex: "666666"))
                                }
                                .padding(.leading, 4)
                            }
                        }
                        .padding(12)
                        .background(Color(hex: "E3F2FD"))
                        .cornerRadius(10)
                    }
                }
            }

            Divider()

            // Recipe Steps
            VStack(alignment: .leading, spacing: 8) {
                Label("Recipe", systemImage: "list.number")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)

                ForEach(Array(rec.recipe.enumerated()), id: \.offset) { index, step in
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
                }
            }

            // Additional Shopping Notes
            if !rec.shoppingList.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color(hex: "9E9E9E"))
                            .font(.system(size: 12))
                        Text("Shopping Tips")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "757575"))
                    }

                    ForEach(Array(rec.shoppingList.enumerated()), id: \.offset) { index, tip in
                        HStack(alignment: .top) {
                            Text("•")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color(hex: "9E9E9E"))
                            Text(tip)
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color(hex: "757575"))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        .padding(.leading, 4)
                    }
                }
                .padding(10)
                .background(Color(hex: "F5F5F5"))
                .cornerRadius(8)
            }

            // Video Resources
            if rec.videoSearchChinese != nil || rec.videoSearchEnglish != nil || rec.videoLink != nil {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Label("Video Tutorials", systemImage: "play.rectangle")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)

                    HStack(spacing: 12) {
                        // Bilibili - Always use Chinese search
                        if let chineseSearch = rec.videoSearchChinese,
                           let encodedSearch = chineseSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                           let url = URL(string: "https://search.bilibili.com/all?keyword=\(encodedSearch)") {
                            Link(destination: url) {
                                Label("Bilibili", systemImage: "play.circle")
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color(hex: "00A1D6").opacity(0.1))
                                    .foregroundColor(Color(hex: "00A1D6"))
                                    .cornerRadius(8)
                            }
                        }

                        // YouTube - Use Chinese for Chinese cuisine, English for Western
                        if let youtubeSearch = isChinese(cuisine: rec.cuisine) ? rec.videoSearchChinese : rec.videoSearchEnglish,
                           let encodedSearch = youtubeSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                           let url = URL(string: "https://www.youtube.com/results?search_query=\(encodedSearch)") {
                            Link(destination: url) {
                                Label("YouTube", systemImage: "play.circle")
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color(hex: "FF0000").opacity(0.1))
                                    .foregroundColor(Color(hex: "FF0000"))
                                    .cornerRadius(8)
                            }
                        }

                        if let link = rec.videoLink,
                           let url = URL(string: link) {
                            Link(destination: url) {
                                Label("Watch Tutorial", systemImage: "play.circle")
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color(hex: "4CAF50").opacity(0.1))
                                    .foregroundColor(Color(hex: "4CAF50"))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    private var freshDayCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("New Day, Fresh Ideas!")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color(hex: "1A1A1A"))

            Text("Your food inventory has been updated. Generate a new recipe for today's dinner.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Color(hex: "666666"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color(hex: "FFF9E6"), Color(hex: "FFEDD5")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
        )
    }

    private func errorCard(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(Color(hex: "FF5722"))

            Text(message)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Color(hex: "333333"))

            Spacer()
        }
        .padding()
        .background(Color(hex: "FFEBEE"))
        .cornerRadius(12)
    }

    private func generateRecommendation() {
        guard openAIService.hasValidConfiguration else {
            showAPIKeyAlert = true
            return
        }

        guard !foodItems.isEmpty else {
            errorMessage = "No food items in inventory. Add some items first!"
            return
        }

        isGenerating = true
        errorMessage = nil
        recommendation = nil

        Task {
            do {
                let result = try await generateDinnerRecommendation()
                await MainActor.run {
                    self.recommendation = result
                    self.isGenerating = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to generate recommendation: \(error.localizedDescription)"
                    self.isGenerating = false
                }
            }
        }
    }

    private func generateDinnerRecommendation() async throws -> DinnerRecommendation {
        // Prepare inventory data
        let expiringItems = foodItems.filter { $0.isExpiringSoon }
        let freshItems = foodItems.filter { !$0.isExpiringSoon && !$0.isExpired }

        let inventoryDescription = """
        Expiring Soon (use these first to reduce waste):
        \(expiringItems.map { "- \($0.name): \($0.quantity) items, expires in \($0.daysUntilExpiry ?? 0) days" }.joined(separator: "\n"))

        Fresh Items:
        \(freshItems.map { "- \($0.name): \($0.quantity) items" }.joined(separator: "\n"))
        """

        let cuisinePreference: String
        switch selectedCuisine {
        case .auto:
            cuisinePreference = "Prefer Chinese cuisine (家常菜), but suggest French or Italian if ingredients are much better suited for it"
        case .chinese:
            cuisinePreference = "Chinese cuisine ONLY (be specific: 川菜/Sichuan, 粤菜/Cantonese, 江浙菜/Jiangzhe, etc.)"
        case .western:
            cuisinePreference = "WESTERN cuisine ONLY - French or Italian ONLY. NEVER suggest Chinese dishes. Choose between authentic French (Coq au Vin, Boeuf Bourguignon, Ratatouille) or Italian (Carbonara, Risotto, Osso Buco). NO other cuisines."
        }

        let prompt = """
        You are a professional chef specializing in home cooking. SEARCH THE INTERNET for current, authentic recipes and cooking techniques. Create a delicious dinner recommendation that intelligently uses available ingredients while suggesting additional items to buy if needed.

        Available Inventory (prioritize using these, especially expiring items):
        \(inventoryDescription)

        Cuisine Preference: \(cuisinePreference)

        IMPORTANT GUIDELINES:
        1. SEARCH THE WEB for authentic, delicious recipes - don't limit yourself to only the available ingredients
        2. Create proper, restaurant-quality dishes that people actually want to eat
        3. INTELLIGENTLY use expiring items where they fit naturally in the recipe
        4. You CAN and SHOULD suggest additional ingredients to buy from the supermarket to complete the dish
        5. Mark clearly which ingredients come from inventory (with expiry status) vs. which need to be purchased
        6. For Chinese cuisine: Be specific about region (川菜/Sichuan, 粤菜/Cantonese, 江浙菜/Jiangzhe, etc.)
        7. For Western cuisine: ONLY French or Italian allowed. NEVER suggest Chinese when Western is selected.
        8. Use authentic dish names (e.g., "Coq au Vin" for French, "Carbonara" for Italian, "麻婆豆腐" for Sichuan)
        9. Recipe steps should be detailed enough for a home cook to follow - base on real recipes from the internet
        10. CRITICAL: Match cuisine selection - if Western selected, ONLY return French or Italian dishes
        11. Prioritize recipes that use at least SOME of the available inventory, especially expiring items

        LANGUAGE REQUIREMENTS:
        - If creating a Chinese dish: Write the recipe steps in Chinese (简体中文)
        - If creating a Western (French/Italian) dish: Write the recipe steps in English
        - The dish name should use authentic names in the original language

        Respond with ONLY a valid JSON object:
        {
            "dishName": "Name of the dish (use authentic names - Chinese names for Chinese dishes, French/Italian names for Western)",
            "cuisine": "Specific cuisine type (e.g., 'Italian', 'French', 'Sichuan/川菜', 'Cantonese/粤菜', NOT just 'Western' or 'Chinese')",
            "ingredients": [
                {"foodItem": "ingredient name", "quantity": "specific amount (e.g., '2 pieces', '200g')", "isExpiringSoon": true/false, "fromInventory": true/false}
            ],
            "recipe": ["Step 1 - IN CHINESE for Chinese cuisine, IN ENGLISH for Western", "Step 2...", ...],
            "cookingTime": "realistic time (e.g., '30 minutes' for Western, '30分钟' for Chinese)",
            "difficulty": "Easy/Medium/Hard for Western, 简单/中等/困难 for Chinese",
            "videoSearchChinese": "Chinese search terms - ALWAYS provide (for Chinese: '红烧肉做法', for Western: '意大利肉酱面做法')",
            "videoSearchEnglish": "English search terms - ONLY for Western cuisine (like 'carbonara recipe'), null for Chinese",
            "videoLink": "specific video URL if you know a good tutorial, otherwise null",
            "reason": "Why this dish makes sense (in English for Western, in Chinese for Chinese cuisine)",
            "shoppingList": ["Items you need to buy from supermarket", "Include brand suggestions if helpful"]
        }
        """

        let response = try await openAIService.sendTextRequest(prompt: prompt)

        // Parse JSON response
        guard let jsonData = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw NSError(domain: "DinnerRecommendation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }

        // Create recommendation object
        let ingredientsArray = (json["ingredients"] as? [[String: Any]]) ?? []
        let ingredients = ingredientsArray.compactMap { dict -> DinnerRecommendation.IngredientUsage? in
            guard let foodItem = dict["foodItem"] as? String,
                  let quantity = dict["quantity"] as? String else { return nil }
            let isExpiring = dict["isExpiringSoon"] as? Bool ?? false
            let fromInventory = dict["fromInventory"] as? Bool ?? false
            return DinnerRecommendation.IngredientUsage(
                foodItem: foodItem,
                quantity: quantity,
                isExpiringSoon: isExpiring,
                fromInventory: fromInventory
            )
        }

        let rec = DinnerRecommendation(
            dishName: json["dishName"] as? String ?? "Mystery Dish",
            cuisine: json["cuisine"] as? String ?? "Fusion",
            ingredients: ingredients,
            recipe: json["recipe"] as? [String] ?? [],
            cookingTime: json["cookingTime"] as? String ?? "30 minutes",
            difficulty: json["difficulty"] as? String ?? "Medium",
            videoSearchChinese: json["videoSearchChinese"] as? String,
            videoSearchEnglish: json["videoSearchEnglish"] as? String,
            videoLink: json["videoLink"] as? String,
            reason: json["reason"] as? String ?? "A delicious meal using your available ingredients",
            shoppingList: json["shoppingList"] as? [String] ?? []
        )

        // Auto-save the recommendation (replaces today's non-favorite)
        saveToCoookbook(rec, asFavorite: false)

        return rec
    }

    private func saveToCoookbook(_ rec: DinnerRecommendation, asFavorite: Bool) {
        // Perform save operation asynchronously to prevent UI lag
        Task { @MainActor in
            // Convert ingredients and recipe to JSON data
            let ingredientsData = rec.ingredients.map { ["foodItem": $0.foodItem, "quantity": $0.quantity, "isExpiringSoon": $0.isExpiringSoon, "fromInventory": $0.fromInventory] }
            guard let ingredientsJSON = try? JSONSerialization.data(withJSONObject: ingredientsData),
                  let recipeJSON = try? JSONSerialization.data(withJSONObject: rec.recipe) else {
                return
            }

            // Check if this recipe already exists as favorite
            if asFavorite {
                let existingFavorite = savedRecipes.first { recipe in
                    recipe.isFavorite && recipe.dishName == rec.dishName
                }
                if existingFavorite != nil {
                    // Already saved as favorite
                    showSaveConfirmation = true
                    return
                }
            }

            // For non-favorites, prevent duplicates and manage history
            if !asFavorite {
                // Check if this exact recipe already exists in recent (by dish name)
                let existingRecent = savedRecipes.first { recipe in
                    !recipe.isFavorite && recipe.dishName == rec.dishName
                }

                if existingRecent != nil {
                    // Recipe already exists in recent, don't add duplicate
                    return
                }

                // Limit to 5 total recent recipes (allow multiple per day)
                let recentRecipes = savedRecipes.filter { !$0.isFavorite }.sorted { $0.dateCreated > $1.dateCreated }
                // We want maximum 5 recipes. Since we're adding 1, we should keep at most 4 existing ones
                if recentRecipes.count >= 5 {
                    // Delete all recipes after the 4th most recent
                    for recipe in recentRecipes.dropFirst(4) {
                        modelContext.delete(recipe)
                    }
                }
            }

            let recipe = Recipe(
                dishName: rec.dishName,
                cuisine: rec.cuisine,
                ingredients: ingredientsJSON,
                recipe: recipeJSON,
                cookingTime: rec.cookingTime,
                difficulty: rec.difficulty,
                videoSearchChinese: rec.videoSearchChinese,
                videoSearchEnglish: rec.videoSearchEnglish,
                videoLink: rec.videoLink,
                reason: rec.reason,
                isFavorite: asFavorite
            )

            modelContext.insert(recipe)

            do {
                try modelContext.save()
                if asFavorite {
                    recommendation?.isSavedAsFavorite = true
                    // Small delay to ensure save completes before showing confirmation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showSaveConfirmation = true
                    }
                }
            } catch {
                print("Failed to save recipe: \(error)")
            }
        }
    }

    private func toggleFavorite() {
        guard let rec = recommendation else { return }

        if rec.isSavedAsFavorite {
            // Remove from favorites
            if let existingFavorite = savedRecipes.first(where: { $0.isFavorite && $0.dishName == rec.dishName }) {
                existingFavorite.isFavorite = false
                try? modelContext.save()
                recommendation?.isSavedAsFavorite = false
            }
        } else {
            // Add to favorites
            saveToCoookbook(rec, asFavorite: true)
        }
    }

    private func isChinese(cuisine: String) -> Bool {
        let lowercased = cuisine.lowercased()
        return lowercased.contains("川") || lowercased.contains("sichuan") ||
               lowercased.contains("粤") || lowercased.contains("cantonese") ||
               lowercased.contains("江浙") || lowercased.contains("jiangzhe") ||
               lowercased.contains("湘") || lowercased.contains("hunan") ||
               lowercased.contains("鲁") || lowercased.contains("shandong") ||
               lowercased.contains("徽") || lowercased.contains("anhui") ||
               lowercased.contains("闽") || lowercased.contains("fujian") ||
               lowercased.contains("chinese") || lowercased.contains("中")
    }

    private func getCuisineIcon(_ cuisine: String) -> String {
        let lowercased = cuisine.lowercased()

        // Check for specific cuisines
        if lowercased.contains("italian") {
            return "flag.2.crossed" // Or use a pizza icon if available
        } else if lowercased.contains("french") {
            return "wineglass"
        } else if lowercased.contains("american") {
            return "flame"
        } else if lowercased.contains("mexican") {
            return "leaf"
        } else if lowercased.contains("japanese") || lowercased.contains("日本") {
            return "circle"
        } else if lowercased.contains("川") || lowercased.contains("sichuan") {
            return "flame.fill"
        } else if lowercased.contains("粤") || lowercased.contains("cantonese") {
            return "drop"
        } else if lowercased.contains("mediterranean") || lowercased.contains("greek") || lowercased.contains("spanish") {
            return "sun.max"
        } else {
            return "globe"
        }
    }

    private func loadLastRecommendation() {
        guard let lastRecipe = lastRecommendation else { return }

        // Convert JSON data back to arrays
        guard let ingredientsArray = try? JSONSerialization.jsonObject(with: lastRecipe.ingredients) as? [[String: Any]],
              let recipeSteps = try? JSONSerialization.jsonObject(with: lastRecipe.recipe) as? [String] else {
            return
        }

        let ingredients = ingredientsArray.compactMap { dict -> DinnerRecommendation.IngredientUsage? in
            guard let foodItem = dict["foodItem"] as? String,
                  let quantity = dict["quantity"] as? String else { return nil }
            let isExpiring = dict["isExpiringSoon"] as? Bool ?? false
            let fromInventory = dict["fromInventory"] as? Bool ?? true // Default to true for backward compatibility
            return DinnerRecommendation.IngredientUsage(
                foodItem: foodItem,
                quantity: quantity,
                isExpiringSoon: isExpiring,
                fromInventory: fromInventory
            )
        }

        // Check if this recipe is also saved as favorite
        let isFavorite = savedRecipes.contains { $0.isFavorite && $0.dishName == lastRecipe.dishName }

        recommendation = DinnerRecommendation(
            dishName: lastRecipe.dishName,
            cuisine: lastRecipe.cuisine,
            ingredients: ingredients,
            recipe: recipeSteps,
            cookingTime: lastRecipe.cookingTime,
            difficulty: lastRecipe.difficulty,
            videoSearchChinese: lastRecipe.videoSearchChinese,
            videoSearchEnglish: lastRecipe.videoSearchEnglish,
            videoLink: lastRecipe.videoLink,
            reason: lastRecipe.reason,
            shoppingList: [], // Empty for backward compatibility
            isSavedAsFavorite: isFavorite
        )
    }
}