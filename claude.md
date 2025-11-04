# FreshKeeper - Project Context for Claude

## Project Overview

**FreshKeeper** is an iOS food inventory management application built for iPhone 16. The app helps users track food items stored in their fridge and two freezers, preventing food waste and helping manage stock levels.

### Key Information
- **Language**: Swift
- **Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Minimum iOS Version**: 26.0
- **Target Device**: iPhone 16 (works on all iOS 26.0+ devices)
- **Architecture**: MVVM pattern with SwiftUI

## User Requirements

The user needs this app to:
1. Take photos of food items when adding them to storage
2. Track quantities of each food item
3. View current stock with pictures at any time
4. Update stock levels when items are used
5. Automatically delete items when quantity reaches 0
6. Have a modern, cute, concise UI design

### Storage Locations
- Fridge
- Freezer 1
- Freezer 2

## Project Structure

```
FreshKeeper/
├── FreshKeeper.xcodeproj/
│   └── project.pbxproj           # Xcode project configuration
└── FreshKeeper/
    ├── FreshKeeperApp.swift      # App entry point with SwiftData container
    ├── Info.plist                # Privacy permissions (camera, photo library)
    ├── Models/
    │   └── FoodItem.swift        # Data model with SwiftData @Model
    ├── Views/
    │   ├── ContentView.swift     # Main inventory grid view
    │   ├── FoodItemCard.swift    # Card component for grid items
    │   ├── AddFoodItemView.swift # Add new food item screen
    │   └── FoodItemDetailView.swift # Detail view with stock updates
    └── Utilities/
        └── CameraView.swift      # Camera & photo library integration
```

## Code Architecture

### Data Model (`Models/FoodItem.swift`)

```swift
@Model
final class FoodItem {
    var id: UUID
    var name: String
    var quantity: Int
    var storageLocation: StorageLocation
    var category: FoodCategory
    var dateAdded: Date
    @Attribute(.externalStorage) var photoData: Data?
    var notes: String
}
```

**Enums:**
- `StorageLocation`: `.fridge`, `.freezer1`, `.freezer2`
- `FoodCategory`: `.meat`, `.bread`, `.vegetables`, `.fruits`, `.dairy`, `.beverages`, `.prepared`, `.other`

### Views

1. **ContentView** - Main screen
   - Grid layout (2 columns)
   - Stats cards (Total Items, Total Stock)
   - Location filter chips
   - Search bar
   - Empty state view
   - Navigation to add/detail views

2. **FoodItemCard** - Card component
   - Photo or category emoji fallback
   - Location badge
   - Item name and quantity
   - Relative timestamp
   - Press animations

3. **AddFoodItemView** - Add new item
   - Photo capture/selection
   - Text field for name
   - Quantity stepper with +/- buttons
   - Location selector (3 buttons)
   - Category selector (horizontal scroll)
   - Notes field
   - Validation (name required)

4. **FoodItemDetailView** - Item details & updates
   - Large photo display
   - Stock update controls (+/- buttons)
   - Detail information cards
   - Delete button
   - Auto-delete confirmation when quantity reaches 0

### Camera Integration (`Utilities/CameraView.swift`)

- `CameraView`: UIImagePickerController wrapper for camera
- `ImagePicker`: UIImagePickerController wrapper for photo library
- Both use SwiftUI's `UIViewControllerRepresentable`
- Image editing enabled
- JPEG compression at 0.8 quality

## Key Features Implementation

### Photo Storage
- Photos stored as `Data` in SwiftData with `.externalStorage` attribute
- JPEG compression for efficient storage
- Fallback to category emoji if no photo

### Stock Management
- Increment/decrement with + and - buttons
- Animated number updates (spring animation)
- Confirmation dialog when reaching 0
- Automatic deletion after confirmation

### Filtering & Search
- Location filter: All, Fridge, Freezer 1, Freezer 2
- Search by name (case-insensitive)
- Filters can be combined
- Results sorted by date (newest first)

### UI Design Philosophy

**Color Palette:**
- Primary Green: `#4CAF50` (fresh, natural)
- Primary Blue: `#2196F3` (cool, clean)
- Accent Red: `#FF5722` (for decrease/delete)
- Background: `#F8F9FA` (light gray)
- Card backgrounds: White with subtle shadows

**Design Patterns:**
- Card-based layout
- Linear gradients for visual interest
- Spring animations (0.3s response, 0.6-0.7 damping)
- SF Symbols for icons
- Relative timestamps
- Empty states with guidance

**Typography:**
- Headlines: Bold, clear
- Body: Regular weight
- Captions: Secondary color
- System font (San Francisco)

## Privacy & Permissions

Required permissions in `Info.plist`:
- `NSCameraUsageDescription`: "FreshKeeper needs access to your camera to take photos of your food items for easy identification."
- `NSPhotoLibraryUsageDescription`: "FreshKeeper needs access to your photo library to let you choose photos of your food items."

## Data Persistence

- Uses SwiftData (iOS 26.0+)
- ModelContainer configured in `FreshKeeperApp`
- Automatic persistence - no manual save needed
- Photos stored with `.externalStorage` for optimization
- All data local to device - no cloud sync

## Installation & Testing

### Requirements
- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- Free Apple ID (no paid developer account needed)
- iOS 26.0+ device or simulator

### Quick Start
```bash
git clone https://github.com/USER/food-manager.git
cd food-manager
open FreshKeeper/FreshKeeper.xcodeproj
```

Then:
1. Select target device (iPhone or simulator)
2. Sign with Apple ID (Signing & Capabilities tab)
3. Build and run (⌘R)

## Common Development Tasks

### Adding a New Field to FoodItem

1. Update `FoodItem.swift` model
2. Update `AddFoodItemView.swift` input form
3. Update `FoodItemDetailView.swift` display
4. Update `FoodItemCard.swift` if needed

### Adding a New Storage Location

1. Add case to `StorageLocation` enum
2. Add icon and color properties
3. Update UI automatically (uses `allCases`)

### Adding a New Category

1. Add case to `FoodCategory` enum
2. Add emoji icon
3. Update UI automatically (uses `allCases`)

### Modifying Colors

- Use `Color(hex: "RRGGBB")` extension
- Primary actions: Green `#4CAF50`
- Secondary actions: Blue `#2196F3`
- Destructive: Red `#FF5722`

## Known Limitations

1. **No Cloud Sync** - Data is local only
2. **No Export** - No way to backup data yet
3. **No Expiration Tracking** - User can add to notes manually
4. **No Barcode Scanner** - Manual entry only
5. **Camera Only Works on Real Device** - Simulator only supports photo library

## Future Enhancement Ideas

- [ ] Expiration date tracking with notifications
- [ ] Barcode/QR code scanning
- [ ] iCloud sync across devices
- [ ] Export/import data (JSON/CSV)
- [ ] Shopping list generation
- [ ] Recipe suggestions based on inventory
- [ ] Dark mode support
- [ ] iPad optimization
- [ ] Widgets for quick stock view
- [ ] Siri shortcuts

## Testing Strategy

See README.md for complete testing checklist.

**Key Test Areas:**
1. Photo capture and storage
2. Stock increment/decrement
3. Auto-delete at quantity 0
4. Filtering and search
5. Data persistence
6. UI animations and interactions

## Troubleshooting Tips

### Build Issues
- Clean build folder: Product → Clean Build Folder (⌘⇧K)
- Delete derived data: ~/Library/Developer/Xcode/DerivedData
- Verify Swift version is 5.0

### Signing Issues
- Use free Apple ID (Personal Team)
- Check bundle identifier is unique
- Download manual profiles in Xcode Preferences

### Device Issues
- Enable Developer Mode on device
- Trust computer on device
- Trust developer certificate in Settings

### Simulator Issues
- Use iPhone 15/16 Pro simulators
- Reset simulator: Device → Erase All Content and Settings
- Drag images into simulator for photo library

## Git Workflow

**Main Branch**: `main` (protected)
**Development Branch**: `claude/fridge-freezer-inventory-app-011CUoRb59Abf9arM1ArKCFV`

**Commit Message Style:**
```
Add/Update/Fix: Brief description

Detailed explanation of changes:
- Bullet point 1
- Bullet point 2
```

## Important Notes for Future Claude Sessions

1. **User wants simple, concise UI** - Don't over-complicate
2. **User has 2 freezers** - Must support Freezer 1 and Freezer 2
3. **Auto-delete at 0 is required** - Don't skip this feature
4. **Photos are essential** - Camera integration is core feature
5. **iPhone 16 is target** - But should work on all iOS 26.0+ devices
6. **No cloud/backend** - Local storage only for simplicity
7. **Cute and modern** - Use gradients, animations, emojis

## Quick Reference Commands

```bash
# Open project
open FreshKeeper/FreshKeeper.xcodeproj

# Build from command line
xcodebuild -project FreshKeeper.xcodeproj -scheme FreshKeeper -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Run tests (when added)
xcodebuild test -project FreshKeeper.xcodeproj -scheme FreshKeeper -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Clean build
xcodebuild clean -project FreshKeeper.xcodeproj -scheme FreshKeeper
```

## Contact & Support

- Repository: https://github.com/dsflu/food-manager
- Issues: Use GitHub Issues
- User: Testing on personal iPhone 16

---

**Last Updated**: 2025-11-04
**iOS Target**: 26.0+
**Xcode Version**: 15.0+
**Swift Version**: 5.0
