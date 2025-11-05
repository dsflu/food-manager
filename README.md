# 🥬 FreshKeeper

**A modern iOS app for smart food inventory management**

Never forget what's in your fridge again! Track food items, manage quantities, set expiry dates, and reduce food waste with a beautiful, intuitive interface.

![iOS](https://img.shields.io/badge/iOS-26.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green.svg)
![SwiftData](https://img.shields.io/badge/SwiftData-✓-green.svg)

---

## ✨ Key Features

### 📸 **Visual Inventory**
- Capture photos of food items with camera or photo library
- Beautiful card-based grid layout
- Clear category icons when no photo is added

### 🏷️ **Smart Organization**
- **Dynamic storage locations**: Default Fridge & Freezer + custom locations (extra fridges, freezers, pantry boxes)
- **Custom categories**: 8 defaults + create your own with custom names and emojis
- Filter by storage location with one tap
- Search by food name instantly

### ⏰ **Expiry Tracking**
- Set expiry/best-before dates with quick shortcuts (3d, 7d, 14d, 30d)
- Color-coded warnings on every card:
  - 🔴 **Red**: Expired
  - 🟠 **Orange**: Expiring soon (within 3 days)
  - 🔵 **Blue**: Good to go
- "Expires tomorrow" smart text

### 📦 **Stock Management**
- Add/update quantities with +/- buttons
- Edit all details: name, category, location, expiry date
- Auto-delete when quantity reaches 0
- Real-time updates

### 🎨 **Modern Design**
- Clean, minimalist interface
- Smooth animations and transitions
- Dark, readable text (no white-on-white!)
- SF Rounded fonts for friendly feel
- Responsive touch interactions

### 🔒 **Privacy First**
- All data stored locally on your device
- No cloud sync, no tracking
- Your food inventory is yours alone

---

## 🚀 Quick Start

### Prerequisites
- **macOS** 14.0+
- **Xcode** 15.0+ ([Free from App Store](https://apps.apple.com/app/xcode/id497799835))
- **iPhone** with iOS 26.0+ OR use Simulator
- **Apple ID** (free account, no paid developer membership needed)

### Installation (3 minutes)

**1. Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/food-manager.git
cd food-manager
```

**2. Open in Xcode**
```bash
open FreshKeeper/FreshKeeper.xcodeproj
```

**3. Configure signing** (first time only)
- Select the **FreshKeeper** target in Xcode
- Go to **Signing & Capabilities** tab
- Choose your **Team** (your Apple ID)
- Xcode will automatically create a provisioning profile

**4. Run the app**
- Select your iPhone or **"iPhone 16 Pro"** simulator
- Press **⌘R** or click the ▶️ Run button
- The app will build and launch!

**First Launch:**
- The app auto-creates default storage locations (Fridge, Freezer)
- 8 default food categories are pre-loaded
- You're ready to start adding food items!

---

## 📱 How to Use

### Adding Food Items
1. Tap the **+** button in the top-right
2. **Take a photo** or choose from library (optional)
3. Enter **food name** (e.g., "Chicken Breast")
4. Set **quantity** with +/- buttons
5. Select **storage location** (Fridge, Freezer, or your custom locations)
6. Choose **category** or create a custom one
7. **Optional**: Set expiry date, add notes
8. Tap **"Add to Inventory"**

### Managing Storage Locations
- Tap **grid icon** (top-left) to manage storage locations
- Add custom locations: "Garage Freezer", "Pantry Box", etc.
- Choose custom icons and colors
- Edit or delete custom locations (defaults are protected)

### Creating Custom Categories
- When adding food, scroll categories and tap **"+ Add Custom"**
- Enter category name (e.g., "Snacks", "Frozen Pizza")
- Pick an emoji icon from 24 options
- Your custom category is ready to use!

### Updating Stock
- Tap any food card to view details
- Use **+/-** buttons to adjust quantity
- Tap **pencil icon** in navigation bar to edit name
- Tap any field with a pencil icon to edit (location, category, expiry)

### Viewing Inventory
- **Main screen**: See all items with photos, quantities, and expiry badges
- **Filter**: Tap location chips (All, Fridge, Freezer, etc.)
- **Search**: Pull down to reveal search bar
- **Stats**: View total items and total stock at the top

---

## 🏗️ Technical Stack

| Component | Technology |
|-----------|-----------|
| **Language** | Swift 5.0 |
| **UI Framework** | SwiftUI (declarative UI) |
| **Data Persistence** | SwiftData (iOS 26+) |
| **Architecture** | MVVM pattern |
| **Min iOS Version** | 26.0 |
| **Camera** | UIImagePickerController |
| **Photo Storage** | External storage attribute (efficient) |

### Project Structure
```
FreshKeeper/
├── FreshKeeper.xcodeproj          # Xcode project (ready to open!)
├── FreshKeeper/
│   ├── FreshKeeperApp.swift      # App entry + data seeding
│   ├── Models/
│   │   └── FoodItem.swift        # Data models (FoodItem, StorageLocation, FoodCategory)
│   ├── Views/
│   │   ├── ContentView.swift     # Main inventory grid
│   │   ├── AddFoodItemView.swift # Add/create new items
│   │   ├── FoodItemDetailView.swift  # View/edit details
│   │   ├── FoodItemCard.swift    # Card component
│   │   └── StorageManagementView.swift  # Manage storage locations
│   └── Utilities/
│       └── CameraView.swift      # Camera integration
└── Assets.xcassets                # App icon, images
```

---

## 🎨 Design System

### Color Palette
| Color | Hex | Usage |
|-------|-----|-------|
| Fresh Green | `#4CAF50` | Primary actions, quantity |
| Cool Blue | `#2196F3` | Info, links |
| Urgent Orange | `#FF9800` | Expiring soon |
| Alert Red | `#F44336` | Expired, delete |
| Dark Text | `#1A1A1A` | Primary text |
| Mid Grey | `#666666` | Labels, secondary text |
| Light Grey | `#999999` | Placeholders, timestamps |

### Typography
- **Font**: SF Rounded (Apple's friendly system font)
- **Weights**: Bold for headings, Semibold for labels, Medium for body

### UI Components
- **Cards**: White background, 8pt shadow, 16pt radius
- **Buttons**: Filled or outlined with brand colors
- **Badges**: Pill-shaped with icon + text
- **Animations**: Spring animations (0.3s response, 0.7 damping)

---

## 🐛 Troubleshooting

### "Persistent store migration error"
**Solution**: Delete the app from your device and reinstall (⌘R)
- This happens after major database schema changes
- One-time issue, creates fresh database with new schema

### App runs slow on device
**Solution**: Build in **Release mode** (not Debug)
- Debug builds are 10-50x slower
- Product → Scheme → Edit Scheme → Run → Build Configuration → Release

### "No such module 'SwiftData'"
**Solution**: Check iOS deployment target
- Select FreshKeeper target → General → Deployment Info
- Ensure "Minimum Deployments" is iOS 26.0

### Camera not working
**Solution**: Grant camera permissions
- iPhone Settings → FreshKeeper → Camera → Allow

### Build failed after git pull
**Solution**: Clean build folder
- In Xcode: Product → Clean Build Folder (⌘⇧K)
- Rebuild with ⌘R

---

## 📚 Additional Resources

- **[FEATURES.md](FEATURES.md)** - Detailed feature showcase with screenshots
- **[PERFORMANCE.md](PERFORMANCE.md)** - Performance tips and optimization guide

---

## 🤝 For Your Team

### Development Setup
Each team member should:
1. Clone the repo
2. Open `FreshKeeper/FreshKeeper.xcodeproj` in Xcode
3. Select their Apple ID for code signing
4. Run on their device or simulator

### Testing Checklist
- [ ] Add food item with photo
- [ ] Add food item without photo
- [ ] Create custom category
- [ ] Create custom storage location
- [ ] Set expiry dates (test 3d, 7d, custom)
- [ ] Edit food name, category, location
- [ ] Update quantities with +/-
- [ ] Search and filter functionality
- [ ] Delete items (reduce to 0, or delete button)
- [ ] Check expiry badges on cards

---

## 🙏 Credits

Built with ❤️ for better food management and reduced food waste.

**Technologies**: SwiftUI, SwiftData, UIKit (Camera), iOS 26

---

## 📄 License

MIT License - Free to use, modify, and share!

---

**Ready to track your food inventory like a pro?** Clone and run! 🎉
