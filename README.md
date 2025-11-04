# FreshKeeper 🥬

A beautiful iOS app for managing food inventory in your fridge and freezers. Never forget what's in stock again!

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green.svg)
![SwiftData](https://img.shields.io/badge/SwiftData-✓-green.svg)

## ✨ Features

- 📸 **Photo capture** - Take photos of food items with camera or photo library
- 📦 **Stock tracking** - Add, update, and track quantities with +/- buttons
- ❄️ **Multi-storage** - Manage Fridge, Freezer 1, and Freezer 2 separately
- 🏷️ **Categories** - Organize by Meat, Bread, Vegetables, Fruits, Dairy, etc.
- 🔍 **Search & filter** - Find items quickly by name or location
- 🗑️ **Auto-delete** - Items automatically deleted when quantity reaches 0
- 🎨 **Modern UI** - Clean, cute design with smooth animations
- 🔒 **Privacy** - All data stored locally on device

## 🚀 Quick Start

### Prerequisites
- Mac with macOS 14.0+
- Xcode 15.0+ (free from App Store)
- iPhone with iOS 17.0+ OR use simulator
- Apple ID (free, no paid developer account needed)

### Installation

**Step 1: Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/food-manager.git
cd food-manager
```

**Step 2: Set up Xcode project** (takes 5 minutes)

📖 **Follow the setup guide**: [SETUP.md](SETUP.md)

This guide walks you through:
- Creating a new Xcode project (can't use pre-built .xcodeproj)
- Adding the source files
- Configuring permissions
- Building and running on iPhone or simulator

**Step 3: Run the app**
- Select your iPhone or simulator
- Press ⌘R to build and run
- Start tracking your food inventory!

## 📱 Usage

### Add Food Items
1. Tap the **+** button
2. Take a photo or choose from library
3. Enter name and quantity
4. Select storage location (Fridge, Freezer 1, Freezer 2)
5. Choose category
6. Tap "Add to Inventory"

### Update Stock
1. Tap any food item card
2. Use **+** and **-** buttons to adjust quantity
3. Changes save automatically

### Search & Filter
- Pull down to reveal search bar
- Tap location chips to filter by Fridge/Freezer

### Delete Items
- Reduce quantity to 0 (auto-delete prompt)
- Or tap "Delete Item" in detail view

## 🏗️ Project Structure

```
FreshKeeper/
├── FreshKeeper/
│   ├── FreshKeeperApp.swift          # App entry point
│   ├── Models/
│   │   └── FoodItem.swift            # SwiftData model
│   ├── Views/
│   │   ├── ContentView.swift         # Main inventory grid
│   │   ├── FoodItemCard.swift        # Card component
│   │   ├── AddFoodItemView.swift    # Add item screen
│   │   └── FoodItemDetailView.swift # Detail & update screen
│   └── Utilities/
│       └── CameraView.swift          # Camera integration
```

## 🛠️ Tech Stack

- **Language**: Swift 5.0
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Minimum iOS**: 17.0
- **Architecture**: MVVM pattern

## 📚 Documentation

- **[SETUP.md](SETUP.md)** - Step-by-step Xcode project setup (START HERE)
- **[claude.md](claude.md)** - Technical architecture and development guide

## 🎨 Design

**Color Palette:**
- Primary Green: `#4CAF50` (fresh, natural)
- Primary Blue: `#2196F3` (cool, clean)
- Accent Red: `#FF5722` (decrease/delete)

**UI Highlights:**
- Card-based layout
- Smooth spring animations
- Linear gradients
- SF Symbols icons
- Relative timestamps

## 🐛 Troubleshooting

### "Cannot open project"
→ You need to create a fresh Xcode project. Follow [SETUP.md](SETUP.md)

### "No such module 'SwiftData'"
→ Set iOS deployment target to 17.0 in Xcode

### "Cannot find FoodItem in scope"
→ Make sure all files are added to the FreshKeeper target

### More issues?
→ See detailed troubleshooting in [SETUP.md](SETUP.md)

## 🤝 Contributing

This is a personal project, but feel free to fork and customize for your own needs!

## 📄 License

MIT License - Feel free to use and modify

## 🙏 Acknowledgments

Built with ❤️ for better food management and less food waste!

---

**Ready to never forget what's in your fridge?** Follow [SETUP.md](SETUP.md) to get started! 🎉
