# FreshKeeper 🥬

A beautiful iOS app for managing food inventory in your fridge and freezers. Never forget what's in stock again!

## Features

✨ **Photo Integration**
- Take photos of food items when adding them
- Choose from photo library or camera
- Visual inventory at a glance

📦 **Stock Management**
- Add new food items with quantities
- Update stock levels easily
- Automatic deletion when stock reaches 0
- Track quantity changes over time

🗂️ **Smart Organization**
- Separate storage for Fridge, Freezer 1, and Freezer 2
- Category system (Meat, Bread, Vegetables, Fruits, Dairy, etc.)
- Search functionality
- Filter by storage location

🎨 **Modern UI Design**
- Clean, concise interface
- Cute and modern design language
- Smooth animations and transitions
- Beautiful gradients and color scheme
- Card-based layout for easy browsing

## Requirements

- iOS 17.0 or later
- iPhone 16 (optimized for latest devices)
- Xcode 15.0 or later (for building)

## How to Build & Install

### Option 1: Direct Install via Xcode (Recommended)

1. **Open the project**
   ```bash
   cd FreshKeeper
   open FreshKeeper.xcodeproj
   ```

2. **Connect your iPhone 16**
   - Connect your device via USB or WiFi
   - Ensure it's unlocked and trusted

3. **Set up signing**
   - Select the FreshKeeper target
   - Go to "Signing & Capabilities"
   - Choose your Apple ID under "Team"
   - Xcode will automatically create a provisioning profile

4. **Select your device**
   - In the toolbar, select your iPhone 16 from the device dropdown

5. **Build and run**
   - Press ⌘R or click the Play button
   - The app will install and launch on your device

### Option 2: Enable Developer Mode (if required)

If this is your first time installing apps directly:

1. Go to Settings > Privacy & Security > Developer Mode
2. Enable Developer Mode
3. Restart your iPhone
4. Confirm when prompted

## Usage

### Adding Food Items

1. Tap the **+** button in the top right
2. Take a photo or choose from library
3. Enter the food name
4. Set the quantity using +/- buttons
5. Choose storage location (Fridge, Freezer 1, or Freezer 2)
6. Select a category
7. Optionally add notes
8. Tap "Add to Inventory"

### Viewing Inventory

- Browse all items in a beautiful grid layout
- See item photos, names, quantities, and storage locations
- Use the search bar to find specific items
- Filter by storage location using the chips

### Updating Stock

1. Tap on any food item card
2. Use the **+** and **-** buttons to adjust quantity
3. Changes are saved automatically
4. When quantity reaches 0, you'll be prompted to delete

### Deleting Items

- From detail view: Tap "Delete Item" button
- Or reduce quantity to 0 and confirm deletion

## App Structure

```
FreshKeeper/
├── FreshKeeperApp.swift          # App entry point
├── Models/
│   └── FoodItem.swift            # Data models
├── Views/
│   ├── ContentView.swift         # Main inventory view
│   ├── FoodItemCard.swift        # Item card component
│   ├── AddFoodItemView.swift    # Add item screen
│   └── FoodItemDetailView.swift # Item detail & update screen
├── Utilities/
│   └── CameraView.swift          # Camera integration
└── Info.plist                    # App configuration
```

## Technologies Used

- **SwiftUI** - Modern declarative UI framework
- **SwiftData** - Persistent data storage
- **UIImagePickerController** - Camera and photo library access
- **Gradients & Animations** - Beautiful, smooth UI experience

## Design Highlights

### Color Palette
- Primary Green: `#4CAF50` (Fresh, natural)
- Primary Blue: `#2196F3` (Cool, clean)
- Background: Light gradients for depth
- White cards with subtle shadows

### UI Patterns
- Card-based design for content
- Bottom-sheet modals for actions
- Smooth spring animations
- SF Symbols for consistent iconography
- Relative time stamps for freshness

## Privacy

- All data is stored locally on your device
- No data is sent to external servers
- Camera and photo library access only used for food photos
- Photos are stored securely in the app's database

## Tips

1. **Take clear photos** - Well-lit photos make items easier to identify
2. **Be consistent** - Use similar naming for related items
3. **Update regularly** - Keep your inventory current as you use items
4. **Use categories** - Helps organize and find items quickly
5. **Add notes** - Include expiration dates or cooking instructions

## Support

For issues or feature requests, please open an issue on GitHub.

## License

This project is for personal use. Feel free to modify and customize for your needs!

---

Built with ❤️ for better food management