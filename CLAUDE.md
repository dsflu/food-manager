# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FreshKeeper is a SwiftUI iOS app for food inventory management using SwiftData persistence. The app tracks food items with photos, quantities, expiry dates, and storage locations, and provides AI-powered dinner recommendations based on inventory. iOS 26.0+ required.

## Build & Run Commands

### Open Project
```bash
open FreshKeeper/FreshKeeper.xcodeproj
```

### Build & Run via Xcode
1. Select the **FreshKeeper** target
2. Choose simulator or connected device (iOS 26.0+)
3. Press **⌘R** to run or **⌘B** to build only
4. For release builds: Product → Scheme → Edit Scheme → Build Configuration → Release

### Clean Build
```bash
# Via Xcode GUI: Product → Clean Build Folder (⌘⇧K)
# Via CLI:
xcodebuild clean -project FreshKeeper/FreshKeeper.xcodeproj
```

### Code Signing Setup
- Automatic signing enabled by default
- Select your Apple ID in Xcode → Signing & Capabilities → Team
- No paid developer account required for device testing

## Architecture & Data Flow

### Core Architecture Pattern
MVVM with SwiftData reactive bindings:
- **Models**: `FoodItem`, `StorageLocation`, `FoodCategory`, `Recipe` with `@Model` macro
- **Views**: SwiftUI declarative views with `@Query` for automatic data observation
- **Persistence**: SwiftData with external storage for images
- **Services**: `OpenAIService` for AI-powered features (food recognition, dinner recommendations)

### Data Model Relationships
```
StorageLocation (1) → (many) FoodItem [cascade delete]
FoodCategory (1) → (many) FoodItem [nullify delete]
FoodItem → optional StorageLocation, optional FoodCategory
```

Key design decisions:
- Images stored with `@Attribute(.externalStorage)` to prevent database bloat
- Cascade delete ensures items removed when storage location deleted
- Nullify delete allows items to exist without category

### View Hierarchy & Navigation
```
ContentView (main grid)
├── NavigationStack with custom shrinking title (gradient logo)
├── LazyVGrid of FoodItemCards
│   └── NavigationLink → FoodItemDetailView (sheet)
│       └── EditCategorySheet (category selection with light background)
├── Sheet: AddFoodItemView (with AI food recognition)
├── Sheet: OrganizationView (unified storage locations + categories management)
│   ├── StorageLocationsTab (drag to reorder, add/edit/delete)
│   └── CategoriesTab (drag to reorder, add/edit/delete, reinitialize defaults)
├── Sheet: SettingsView (OpenAI API key and model selection)
├── Sheet: DinnerRecommendationView (AI recipe generation)
│   └── Sheet: CookbookView (saved recipes with favorites)
├── Floating Action Button: Chef button for dinner recommendations
└── Filtering: location chips, category selector, search, status filter
```

### State Management Flow
1. **@Query** macros automatically fetch and observe SwiftData changes
2. **@Bindable** enables direct model property binding in edit views
3. **@Environment(\.modelContext)** provides database access
4. SwiftData auto-saves on model changes (no explicit save needed)

### Image Handling Pipeline
1. User captures/selects photo → `UIImagePickerController`
2. Compress to JPEG (50% quality) → ~200KB per image
3. Store as `Data` with external storage attribute
4. Display via `Image(uiImage:)` with fallback to category emoji

## Key Implementation Details

### SwiftData Setup (FreshKeeperApp.swift)
- ModelContainer initialized with schema for all models (FoodItem, StorageLocation, FoodCategory, Recipe)
- First-launch seeding creates default storage locations (Fridge, Freezer) and 11 food categories
- Lightweight migration handles schema changes automatically
- Color extension in FreshKeeperApp.swift for hex color support across all views

### Filtering Logic (ContentView.swift)
Filters applied in sequence:
1. Status filter (all/expiring/expired)
2. Storage location filter
3. Category filter
4. Search text filter
All filters combine with AND logic.

### Expiry Tracking
Computed properties on FoodItem model:
- `daysUntilExpiry`: Days remaining (nil if no expiry date)
- `isExpired`: Past expiry date
- `isExpiringSoon`: Within 3 days of expiry
These drive color-coded badges (red=expired, orange=expiring, blue=fresh).

### Food Categories (11 Default Categories)
The app uses simplified categories optimized for daily cooking and food storage:

**Fresh Ingredients:**
- Vegetables 🥬 - All vegetables including tofu
- Meat 🥩 - Meats, poultry, seafood, fish
- Fruits 🍎 - Fresh fruits
- Dairy & Eggs 🥛 - Milk, cheese, yogurt, eggs

**Pantry & Cooking Essentials:**
- Seasonings & Sauces 🧂 - Soy sauce, cooking oil, vinegar, garlic, ginger, spices, condiments
- Grains & Pasta 🍚 - Rice, noodles, pasta, flour, bread
- Canned & Packaged 🥫 - Canned goods, jarred items, shelf-stable packaged foods

**Other:**
- Frozen 🧊 - Frozen foods, ice cream, frozen meals
- Snacks 🍿 - Chips, nuts, crackers
- Beverages 🧃 - Drinks, juices, tea
- Other 📦 - Miscellaneous items

Users can delete any category (including defaults) and reinitialize them from the Organization settings.

### Custom Components
- **FoodItemCard**: Grid display with photo, name, quantity, expiry badge
- **StatCard**: Metric display (Total Items, Expiring Soon, Expired)
- **FilterChip**: Selectable chip for location/category filtering
- **EditableDetailRow**: Info row with pencil icon for inline editing
- **Direct Quantity Input**: TextField with numeric keyboard for large numbers (tap to edit)
- **DinnerRecommendationView**: AI-powered recipe generation with cuisine selection
- **CookbookView**: Browse and manage saved recipes with favorites
- **OrganizationView**: Unified tabbed interface for managing storage locations and categories

### OpenAI Integration (Services/OpenAIService.swift)
- **API Key Storage**: Secure storage in iOS Keychain (never hardcoded)
- **Food Recognition**: Vision API identifies food from photos
- **Dinner Recommendations**: Text API generates recipes based on inventory
- **Model Selection**: GPT-4.1-nano (cheap) or GPT-4o-mini (accurate)
- **Image Optimization**: Auto-resize to 1024x1024, JPEG compression
- **Categories** (11 total):
  - Fresh: Vegetables, Meat, Fruits, Dairy & Eggs
  - Pantry: Seasonings & Sauces, Grains & Pasta, Canned & Packaged
  - Other: Frozen, Snacks, Beverages, Other
- **Settings View**: Configure API key and model preferences
- **Internet Search**: AI searches web for current, authentic recipes

### Performance Optimizations
- LazyVGrid for efficient scrolling with 100+ items
- External image storage prevents database file bloat
- @Bindable for precise UI updates without full re-renders
- Sorted queries at database level via @Query(sort:)
- Image compression to ~200KB before OpenAI upload

## Common Development Tasks

### Adding New Features to FoodItem
1. Add property to `FoodItem` model in `Models/FoodItem.swift`
2. Update `AddFoodItemView` to include input field
3. Update `FoodItemDetailView` to display/edit property
4. SwiftData handles migration automatically

### Creating Custom Edit Sheets
Follow pattern in `FoodItemDetailView.swift`:
```swift
.sheet(isPresented: $showingEditSheet) {
    NavigationStack {
        // Edit form content
        .navigationTitle("Edit Property")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    // Save changes
                    dismiss()
                }
            }
        }
    }
}
```

### Working with SwiftData Queries
```swift
// Basic query with sort
@Query(sort: \FoodItem.dateAdded, order: .reverse) var items: [FoodItem]

// Filtered query (must be computed property)
var filteredItems: [FoodItem] {
    items.filter { $0.storageLocation?.id == selectedLocationId }
}
```

### Testing Checklist
Manual testing focus areas:
- Add/edit/delete food items with and without photos
- AI food identification from photos
- Direct quantity input for large numbers (tap to edit)
- OpenAI API key management in Settings
- Custom categories and storage locations
- Expiry date tracking and badge colors
- Quantity updates (including reduce to 0)
- All filter combinations
- Performance with 100+ items
- Schema migration after model changes
- Dinner recommendation generation (all cuisine types)
- Recipe saving to cookbook and favorites
- Shopping list for missing ingredients
- Video tutorial links (Bilibili and YouTube)
- Recipe language (Chinese for Chinese cuisine, English for Western)

## Recent Improvements

### AI Dinner Recommendations
- **Smart Recipe Generation**: Creates personalized dinner recipes based on inventory
- **Expiry Priority**: Intelligently uses expiring items where appropriate
- **Shopping List**: Shows what you have vs. what to buy from supermarket
- **Cuisine Selection**: Smart Choice, Chinese (multiple regional styles), or Western (French/Italian)
- **Language Support**: Chinese recipes in Chinese, Western recipes in English
- **Video Tutorials**: Links to Bilibili (Chinese search) and YouTube
- **Recipe Cookbook**: Save favorites and browse recent recipes (max 5 recent)
- **Internet Search**: AI searches web for authentic, current recipes

### OpenAI Integration
- Added AI-powered food recognition using GPT-4 vision models
- Secure API key storage in iOS Keychain
- Model selection between GPT-4.1-nano (cost-effective) and GPT-4o-mini (accurate)
- Automatic category matching with app's 11 predefined categories
- Image optimization to reduce API costs

### UI/UX Improvements
- **Unified Organization View**: Combined storage locations and categories into one tabbed interface
- **Category Management**: Drag to reorder, delete any category (including defaults), reinitialize defaults
- **Gradient App Title**: Stylish "FreshKeeper" logo with leaf icon
- **Light Category Selection**: Fixed black background issue in category picker
- **Color Extension**: Robust hex color handling with proper validation and clamping

### Enhanced Quantity Input
- Direct text input for quantities (tap the number to edit)
- Numeric keyboard with validation
- Useful for large quantities (e.g., hundreds of items)
- Available in both AddFoodItemView and FoodItemDetailView

## Important Notes

### iOS Version Requirement
- Minimum iOS 26.0 required for SwiftData features
- Test on both simulator and physical device when possible

### Debug vs Release Performance
- Debug builds are 10-50x slower than release
- Always test performance in release mode before reporting issues

### Image Storage
- Photos compressed to ~200KB JPEG (50% quality)
- Stored outside main database file for performance
- Original photos not retained after compression

### Schema Migration
After changing models, users may see "persistent store migration error" on first launch. Solution: delete and reinstall app (one-time only).