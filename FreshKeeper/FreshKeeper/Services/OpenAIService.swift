//
//  OpenAIService.swift
//  FreshKeeper
//
//  Service for integrating OpenAI GPT-4 Vision API for food identification
//

import Foundation
import Security
import UIKit

// MARK: - Response Models
struct OpenAIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}

struct FoodIdentificationResult: Codable {
    let foodName: String
    let category: String
    let confidence: String
    let additionalInfo: String?

    // Custom decoder to handle various response formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.foodName = try container.decode(String.self, forKey: .foodName)
        self.category = try container.decode(String.self, forKey: .category)
        self.confidence = try container.decode(String.self, forKey: .confidence)
        self.additionalInfo = try container.decodeIfPresent(String.self, forKey: .additionalInfo)
    }

    init(foodName: String, category: String, confidence: String, additionalInfo: String?) {
        self.foodName = foodName
        self.category = category
        self.confidence = confidence
        self.additionalInfo = additionalInfo
    }
}

// MARK: - Model Configuration
enum ModelPurpose {
    case vision      // For image identification
    case reasoning   // For text reasoning/recommendations (future)
}

struct OpenAIModel {
    let id: String
    let name: String
    let description: String
    let supportsVision: Bool
    let costEstimate: String  // Per image for vision, per 1K tokens for text

    // Vision-capable models for food identification
    // Only working, cost-effective options
    static let visionModels = [
        OpenAIModel(
            id: "gpt-4.1-nano",
            name: "GPT-4.1 Nano ⭐",
            description: "Cheapest & fast: $0.10/1M tokens",
            supportsVision: true,
            costEstimate: "~$0.000008 per image"
        ),
        OpenAIModel(
            id: "gpt-4o-mini",
            name: "GPT-4o Mini 🎯",
            description: "Best accuracy: $0.15/1M tokens",
            supportsVision: true,
            costEstimate: "~$0.000013 per image"
        )
    ]

    // Text-only models for future recommendation feature
    static let reasoningModels = [
        OpenAIModel(
            id: "gpt-4.1-nano",
            name: "GPT-4.1 Nano ⭐",
            description: "Cheapest: $0.10/1M tokens",
            supportsVision: false,
            costEstimate: "$0.10 per 1M tokens"
        ),
        OpenAIModel(
            id: "gpt-4o-mini",
            name: "GPT-4o Mini 🎯",
            description: "Reliable: $0.15/1M tokens",
            supportsVision: false,
            costEstimate: "$0.15 per 1M tokens"
        )
    ]

    // For current implementation, only expose vision models
    static var availableModels: [OpenAIModel] {
        return visionModels
    }
}

// MARK: - OpenAI Service
class OpenAIService {
    static let shared = OpenAIService()

    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let defaultModel = "gpt-4.1-nano"  // Default to cheapest working model

    private init() {}

    /// Check if we have a valid API configuration
    var hasValidConfiguration: Bool {
        return getAPIKey() != nil
    }

    // MARK: - API Key Management

    /// Securely stores the API key in iOS Keychain
    func saveAPIKey(_ apiKey: String) -> Bool {
        let data = apiKey.data(using: .utf8)!

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.freshkeeper.openai",
            kSecAttrAccount: "api-key",
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // First delete any existing key
        SecItemDelete(query as CFDictionary)

        // Add the new key
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieves the API key from iOS Keychain
    func getAPIKey() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.freshkeeper.openai",
            kSecAttrAccount: "api-key",
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data,
           let apiKey = String(data: data, encoding: .utf8) {
            return apiKey
        }

        return nil
    }

    /// Checks if an API key is configured
    var hasAPIKey: Bool {
        getAPIKey() != nil
    }

    /// Deletes the API key from Keychain
    func deleteAPIKey() -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.freshkeeper.openai",
            kSecAttrAccount: "api-key"
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    // MARK: - Model Management

    /// Saves the selected model to Keychain for a specific purpose
    func saveSelectedModel(_ modelId: String, for purpose: ModelPurpose = .vision) -> Bool {
        let account = purpose == .vision ? "selected-vision-model" : "selected-reasoning-model"
        let data = modelId.data(using: .utf8)!

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.freshkeeper.openai",
            kSecAttrAccount: account,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // First delete any existing model
        SecItemDelete(query as CFDictionary)

        // Add the new model
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieves the selected model from Keychain for a specific purpose
    func getSelectedModel(for purpose: ModelPurpose = .vision) -> String {
        let account = purpose == .vision ? "selected-vision-model" : "selected-reasoning-model"

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.freshkeeper.openai",
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data,
           let modelId = String(data: data, encoding: .utf8) {
            return modelId
        }

        return defaultModel // Return default if no model saved
    }

    /// Legacy method for backward compatibility - uses vision model
    func getSelectedModel() -> String {
        return getSelectedModel(for: .vision)
    }

    /// Legacy method for backward compatibility - saves vision model
    func saveSelectedModel(_ modelId: String) -> Bool {
        return saveSelectedModel(modelId, for: .vision)
    }

    /// Deletes all OpenAI configuration (API key and models)
    func deleteAllConfiguration() -> Bool {
        let apiKeyDeleted = deleteAPIKey()

        // Delete vision model
        let visionQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.freshkeeper.openai",
            kSecAttrAccount: "selected-vision-model"
        ]
        let visionStatus = SecItemDelete(visionQuery as CFDictionary)

        // Delete reasoning model (for future use)
        let reasoningQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.freshkeeper.openai",
            kSecAttrAccount: "selected-reasoning-model"
        ]
        let reasoningStatus = SecItemDelete(reasoningQuery as CFDictionary)

        // Also delete legacy model key if exists
        let legacyQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "com.freshkeeper.openai",
            kSecAttrAccount: "selected-model"
        ]
        SecItemDelete(legacyQuery as CFDictionary)

        let modelsDeleted = (visionStatus == errSecSuccess || visionStatus == errSecItemNotFound) &&
                           (reasoningStatus == errSecSuccess || reasoningStatus == errSecItemNotFound)

        return apiKeyDeleted && modelsDeleted
    }

    // MARK: - Food Identification

    /// Identifies food from an image using GPT-5 or GPT-4 Vision
    func identifyFood(from image: UIImage) async throws -> FoodIdentificationResult {
        guard let apiKey = getAPIKey() else {
            throw OpenAIError.noAPIKey
        }

        // Resize image for optimal cost/performance
        // Since we're using "detail": "low", OpenAI will resize to 512x512 anyway
        // Pre-resizing saves upload bandwidth and processing time
        let resizedImage = resizeImage(image, maxDimension: 1024) ?? image

        // Compress and encode image
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.7),
              imageData.count < 20_000_000 else { // Max 20MB
            throw OpenAIError.imageTooLarge
        }

        let base64Image = imageData.base64EncodedString()
        let selectedModel = getSelectedModel()

        print("Using model: \(selectedModel)")
        print("Image data size: \(imageData.count) bytes")
        print("Base64 string length: \(base64Image.count) characters")

        // Both GPT-4 and GPT-5 models use the same Chat Completions API format for vision
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Build request body with correct parameter based on model
        var requestBody: [String: Any] = [
            "model": selectedModel,
            "messages": [
                [
                    "role": "system",
                    "content": """
                    You are a food identification expert. Analyze the image and identify the food item.

                    You must respond with ONLY a valid JSON object, no other text before or after.
                    Use this exact format:
                    {
                        "foodName": "specific name of the food",
                        "category": "exactly one of: Vegetables, Meat, Fruits, Dairy & Eggs, Seasonings & Sauces, Grains & Pasta, Canned & Packaged, Frozen, Snacks, Beverages, Other",
                        "confidence": "exactly one of: high, medium, low",
                        "additionalInfo": "brief note if relevant or null"
                    }

                    Rules:
                    - Be specific with food names (e.g., "Granny Smith Apples" not just "Apples")
                    - Category must be EXACTLY one of the 11 options listed above (case-sensitive including ampersands)
                    - Use "Vegetables" for all vegetables including tofu
                    - Use "Meat" for all meats, poultry, seafood, and fish
                    - Use "Dairy & Eggs" for milk, cheese, yogurt, eggs, and dairy products
                    - Use "Seasonings & Sauces" for soy sauce, cooking oil, vinegar, garlic, ginger, spices, condiments, and sauces
                    - Use "Grains & Pasta" for rice, noodles, pasta, flour, bread, and grain-based staples
                    - Use "Canned & Packaged" for canned vegetables, canned beans, canned soup, canned tomatoes, jarred items, and pre-packaged shelf-stable foods
                    - Use "Frozen" for frozen foods, ice cream, and frozen meals
                    - Use "Snacks" for chips, nuts, crackers, and snack items
                    - Confidence must be EXACTLY one of: high, medium, low
                    - Do not include any markdown formatting or code blocks
                    - Return only the JSON object, nothing else
                    """
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "What food is in this image?"
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)",
                                "detail": "low"  // Use low detail for faster processing and lower cost
                            ]
                        ]
                    ]
                ]
            ]
        ]

        // Add model-specific parameters
        if selectedModel.starts(with: "gpt-5") {
            // GPT-5 models may have different requirements
            requestBody["max_completion_tokens"] = 150
            // GPT-5 may only support default temperature
            // Don't set temperature, use default (1.0)
            print("Using GPT-5 parameters: max_completion_tokens=150, default temperature")
        } else {
            // GPT-4 models use standard parameters
            requestBody["max_tokens"] = 150
            requestBody["temperature"] = 0.2
            print("Using GPT-4 parameters: max_tokens=150, temperature=0.2")
        }

        // Log the request structure (without the full base64 data)
        var debugRequest = requestBody
        if var messages = debugRequest["messages"] as? [[String: Any]],
           messages.count > 1,
           var userMessage = messages[1]["content"] as? [[String: Any]],
           userMessage.count > 1,
           var imageUrl = userMessage[1]["image_url"] as? [String: Any],
           let url = imageUrl["url"] as? String {
            // Truncate the base64 data for logging
            if url.hasPrefix("data:image/jpeg;base64,") {
                imageUrl["url"] = "data:image/jpeg;base64,[TRUNCATED]"
                userMessage[1]["image_url"] = imageUrl
                messages[1]["content"] = userMessage
                debugRequest["messages"] = messages
            }
        }
        print("Request structure: \(debugRequest)")

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Make the request
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw OpenAIError.invalidAPIKey
        }

        guard httpResponse.statusCode == 200 else {
            // Log the error response for debugging
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("API Error Response: \(errorData)")
            }
            throw OpenAIError.requestFailed(statusCode: httpResponse.statusCode)
        }

        // Log the full raw response for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("Full API Response: \(responseString)")
        }

        // Parse the response
        let openAIResponse: OpenAIResponse
        do {
            openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        } catch {
            print("Failed to decode OpenAI response: \(error)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response data: \(responseString)")
            }
            throw OpenAIError.invalidResponse
        }

        // Check if we have choices
        guard !openAIResponse.choices.isEmpty else {
            print("No choices in response")
            throw OpenAIError.noContent
        }

        guard let content = openAIResponse.choices.first?.message.content else {
            print("No content in first choice")
            throw OpenAIError.noContent
        }

        // Check if content is empty
        if content.isEmpty {
            print("Content is empty string")
            throw OpenAIError.noContent
        }

        // Log the raw response for debugging
        print("AI Response Content: \(content)")

        // The response might contain markdown formatting or extra text
        // Try to extract JSON from the response
        let cleanedContent: String
        if let jsonStart = content.firstIndex(of: "{"),
           let jsonEnd = content.lastIndex(of: "}") {
            // Extract just the JSON portion
            cleanedContent = String(content[jsonStart...jsonEnd])
        } else {
            cleanedContent = content
        }

        // Extract JSON from the response
        guard let jsonData = cleanedContent.data(using: .utf8) else {
            print("Failed to convert to data: \(cleanedContent)")
            throw OpenAIError.invalidResponse
        }

        do {
            let result = try JSONDecoder().decode(FoodIdentificationResult.self, from: jsonData)
            return result
        } catch {
            print("JSON Decoding Error: \(error)")
            print("Attempted to decode: \(cleanedContent)")

            // Try a more lenient parsing approach
            if let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                // Manually construct the result
                let foodName = jsonObject["foodName"] as? String ?? "Unknown Food"
                let category = jsonObject["category"] as? String ?? "Other"
                let confidence = jsonObject["confidence"] as? String ?? "low"
                let additionalInfo = jsonObject["additionalInfo"] as? String

                return FoodIdentificationResult(
                    foodName: foodName,
                    category: category,
                    confidence: confidence,
                    additionalInfo: additionalInfo
                )
            }

            throw OpenAIError.invalidResponse
        }
    }

    // MARK: - Helper Functions

    /// Resizes an image to fit within maxDimension while maintaining aspect ratio
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage? {
        let size = image.size

        // Don't resize if already smaller
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }

        // Calculate new size maintaining aspect ratio
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        // Create resized image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }

    /// Sends a text-only request to OpenAI for reasoning tasks
    func sendTextRequest(prompt: String) async throws -> String {
        guard let apiKey = getAPIKey() else {
            throw OpenAIError.noAPIKey
        }

        // Use the reasoning model (or vision model as fallback since they're the same for now)
        let selectedModel = getSelectedModel(for: .reasoning)

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw OpenAIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Build request body with system message to enable web search
        var requestBody: [String: Any] = [
            "model": selectedModel,
            "messages": [
                [
                    "role": "system",
                    "content": "You have the ability to search the internet for current information. When asked to create recipes or recommendations, actively search for authentic, current recipes and cooking techniques from reputable sources."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]

        // Add appropriate token limit based on model
        if selectedModel.contains("gpt-5") {
            requestBody["max_completion_tokens"] = 2000
        } else {
            requestBody["max_tokens"] = 2000
        }

        // Don't set temperature for GPT-5 models (they only support default)
        if !selectedModel.contains("gpt-5") {
            requestBody["temperature"] = 0.7
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw OpenAIError.invalidRequest
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("API Error Response: \(errorData)")
                if let error = errorData["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw OpenAIError.apiError(message)
                }
            }
            throw OpenAIError.apiError("Request failed with status code: \(httpResponse.statusCode)")
        }

        guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = jsonResponse["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.invalidResponse
        }

        return content
    }
}

// MARK: - Error Types
enum OpenAIError: LocalizedError {
    case noAPIKey
    case invalidAPIKey
    case imageTooLarge
    case invalidResponse
    case invalidRequest
    case invalidURL
    case apiError(String)
    case noContent
    case requestFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key configured. Please add your OpenAI API key in Settings."
        case .invalidAPIKey:
            return "Invalid API key. Please check your OpenAI API key."
        case .imageTooLarge:
            return "Image is too large. Please try with a smaller image."
        case .invalidResponse:
            return "Invalid response from OpenAI API."
        case .invalidRequest:
            return "Invalid request format."
        case .invalidURL:
            return "Invalid API URL."
        case .apiError(let message):
            return "API Error: \(message)"
        case .noContent:
            return "No content in response from OpenAI API."
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        }
    }
}