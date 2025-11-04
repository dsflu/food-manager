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

### Hardware
- **For iPhone Testing**: iPhone running iOS 17.0 or later (optimized for iPhone 16)
- **For Mac Testing**: Mac with Apple Silicon (M1/M2/M3) or Intel processor running macOS 14.0 (Sonoma) or later
- **USB-C or Lightning cable** (for iPhone connection)

### Software
- **macOS**: Version 14.0 (Sonoma) or later
- **Xcode**: Version 15.0 or later (free from App Store)
- **Apple ID**: Free Apple ID account (no paid developer account needed for personal testing)
- **Git**: Comes pre-installed on macOS

## Prerequisites Installation

### Step 1: Install Xcode

1. **Open the App Store** on your Mac
2. **Search for "Xcode"**
3. **Click "Get"** or the cloud download icon (it's ~7-15 GB, will take time)
4. **Wait for installation** to complete (can take 30-60 minutes)
5. **Open Xcode** for the first time
   - Agree to the license agreement
   - Install additional components when prompted
6. **Verify installation**:
   ```bash
   xcode-select --version
   # Should show: xcode-select version 2395 or similar
   ```

### Step 2: Install Command Line Tools (if not already installed)

```bash
xcode-select --install
```

If already installed, you'll see: "command line tools are already installed"

### Step 3: Verify Git Installation

```bash
git --version
# Should show: git version 2.39.0 or similar
```

## Complete Installation Guide

### Step 1: Clone the Repository

Open Terminal and run:

```bash
# Navigate to where you want to store the project
cd ~/Desktop  # or any folder you prefer

# Clone the repository
git clone https://github.com/YOUR_USERNAME/food-manager.git

# Navigate into the project
cd food-manager
```

### Step 2: Open the Project in Xcode

```bash
# Open the Xcode project
open FreshKeeper/FreshKeeper.xcodeproj
```

Xcode will launch and open the project.

## Testing Options

You have two options for testing the app:

---

## Option A: Test on Your iPhone 16 (Recommended for Full Experience)

This option allows you to test all features including the camera.

### Step 1: Enable Developer Mode on iPhone

**First time only:**

1. Connect your iPhone to your Mac via USB cable
2. On your iPhone, go to **Settings** → **Privacy & Security**
3. Scroll down to **Developer Mode**
4. Toggle it **ON**
5. Tap **Restart** when prompted
6. After restart, confirm when asked

### Step 2: Trust Your Mac

1. When you connect your iPhone, a popup will appear on iPhone
2. Tap **Trust** and enter your iPhone passcode

### Step 3: Set Up Signing in Xcode

1. In Xcode, in the left sidebar (Project Navigator), click on **FreshKeeper** (the blue project icon at the top)
2. Select the **FreshKeeper** target (under TARGETS)
3. Click the **Signing & Capabilities** tab
4. Under "Signing", check **"Automatically manage signing"**
5. Click the **Team** dropdown:
   - If you see your Apple ID, select it
   - If not, click **Add an Account...**
6. **Add Apple ID** (if needed):
   - Click **Add an Account...**
   - Click the **+** button
   - Choose **Apple ID**
   - Sign in with your Apple ID and password
   - Click **Next**
   - Use two-factor authentication if prompted
7. After signing in, select your account from the **Team** dropdown
8. You should see a checkmark with no errors

**Common signing section fields:**
- ✅ Automatically manage signing: **Checked**
- Team: **Your Name (Personal Team)**
- Bundle Identifier: **com.freshkeeper.app**

### Step 4: Select Your iPhone as Target

1. At the top of Xcode, find the device selector (next to the Play/Stop buttons)
2. Click the device dropdown
3. Select your **iPhone 16** from the list (should show your device name)
4. It might say "iPhone 16 (iOS 17.x)"

### Step 5: Build and Run

1. Click the **Play button** (▶) in the top-left, or press **⌘R**
2. Xcode will:
   - Compile the code
   - Install the app on your iPhone
   - Launch the app
3. **First time**: You may see "Untrusted Developer" on iPhone:
   - Go to **Settings** → **General** → **VPN & Device Management**
   - Find your Apple ID under "Developer App"
   - Tap it and tap **Trust "Your Apple ID"**
   - Tap **Trust** again to confirm
   - Go back to the app and launch it

### Step 6: Grant Permissions

When you first use the app:
1. **Camera Access**: Tap **OK** when prompted to allow camera access
2. **Photo Library**: Tap **OK** when prompted to allow photo library access

**You're ready to use the app!** 🎉

---

## Option B: Test on Mac Simulator

This option is faster but camera features won't work (can still select photos from simulated library).

### Step 1: Select a Simulator

1. In Xcode, click the device dropdown at the top
2. Hover over **iOS Simulators**
3. Select **iPhone 16 Pro** or **iPhone 15 Pro** (or any recent iPhone model)

### Step 2: Build and Run

1. Click the **Play button** (▶) or press **⌘R**
2. Wait for the simulator to boot (first time takes 1-2 minutes)
3. The app will automatically install and launch

### Step 3: Test the App

**Note**: In the simulator:
- ✅ You can add food items
- ✅ You can update quantities
- ✅ You can filter and search
- ✅ You can select photos from simulated photo library
- ❌ Camera won't work (will show error or fallback to library)

**Adding sample photos in simulator:**
1. Drag and drop images from your Mac into the Simulator window
2. Photos will be saved to the simulated photo library
3. Use "Choose from Library" option in the app

---

## Step-by-Step: First Time Usage

### 1. Launch the App

The app opens to the main inventory view (empty at first).

### 2. Add Your First Food Item

1. **Tap the green (+) button** in the top-right corner
2. **Add a photo**:
   - Tap the dashed photo area
   - Choose **"Take Photo"** (on real iPhone) or **"Choose from Library"**
   - Take a photo of a food item (e.g., chicken breast package)
   - Adjust and confirm
3. **Enter details**:
   - **Food Name**: "Chicken Breast"
   - **Quantity**: Tap + to increase (e.g., 4 packages)
   - **Storage Location**: Tap "Freezer 1"
   - **Category**: Tap "🥩 Meat"
   - **Notes** (optional): "Expires 2024-12-31"
4. **Tap "Add to Inventory"**

### 3. View Your Inventory

- Your item appears as a card in the grid
- Shows the photo, name, quantity, and location badge
- Top shows stats: Total Items and Total Stock

### 4. Filter and Search

- **Filter by location**: Tap "All", "Fridge", "Freezer 1", or "Freezer 2" chips
- **Search**: Pull down slightly to reveal search bar, type food name

### 5. Update Stock

1. **Tap on a food item card**
2. View full details and large photo
3. **Update quantity**:
   - Tap **+** to increase (added more)
   - Tap **-** to decrease (used some)
4. Changes save automatically

### 6. Delete an Item

**Option 1**: Reduce quantity to 0
- Tap **-** until it reaches 0
- Confirm deletion

**Option 2**: Delete directly
- Open the item detail
- Scroll down and tap **"Delete Item"**
- Confirm

---

## Troubleshooting

### Issue: "Failed to code sign"

**Solution**:
1. Xcode → Preferences → Accounts
2. Select your Apple ID
3. Click **Download Manual Profiles**
4. Try building again

### Issue: "Untrusted Developer" on iPhone

**Solution**:
1. Settings → General → VPN & Device Management
2. Find your Apple ID under Developer App
3. Tap Trust

### Issue: iPhone not appearing in Xcode

**Solution**:
1. Disconnect and reconnect the cable
2. Unlock your iPhone
3. Tap "Trust This Computer"
4. In Xcode: Window → Devices and Simulators → Check if device appears

### Issue: "iPhone is busy: Preparing debugger support"

**Solution**:
1. Wait 1-2 minutes for Xcode to finish processing
2. Keep iPhone unlocked and connected

### Issue: Simulator is slow

**Solution**:
1. Use a newer simulator (iPhone 15/16 Pro)
2. Close other apps to free RAM
3. Reduce simulator window size

### Issue: Camera permission denied

**Solution**:
1. iPhone Settings → FreshKeeper
2. Enable Camera and Photos permissions
3. Restart the app

### Issue: Build fails with "Swift version error"

**Solution**:
1. Select project in Xcode
2. Build Settings tab
3. Search "Swift Language Version"
4. Set to "Swift 5"

### Issue: "No team found"

**Solution**:
1. You need an Apple ID
2. Xcode → Preferences → Accounts
3. Click + → Add Apple ID
4. Sign in with your free Apple ID

---

## Testing Checklist

Use this to verify everything works:

### Basic Features
- [ ] App launches successfully
- [ ] Main screen loads with stats and grid
- [ ] Empty state shows when no items

### Adding Items
- [ ] Can tap + button to open add screen
- [ ] Can take photo (real device) or choose from library
- [ ] Can enter food name
- [ ] Can adjust quantity with +/- buttons
- [ ] Can select storage location
- [ ] Can select category
- [ ] Can add notes
- [ ] Item appears in main grid after adding

### Viewing & Navigation
- [ ] Can see all items in grid layout
- [ ] Can tap item to see details
- [ ] Photos display correctly
- [ ] Stats update correctly (Total Items, Total Stock)
- [ ] Time stamps show correctly ("just now", "2 days ago", etc.)

### Filtering & Search
- [ ] Can tap location filters (All, Fridge, Freezer 1, Freezer 2)
- [ ] Grid updates to show only filtered items
- [ ] Search bar appears when pulling down
- [ ] Search filters items by name
- [ ] Can clear search and filters

### Updating Stock
- [ ] Can tap + to increase quantity
- [ ] Can tap - to decrease quantity
- [ ] Number animates when changed
- [ ] Changes persist after closing app

### Deleting Items
- [ ] Can delete via "Delete Item" button
- [ ] Confirmation dialog appears
- [ ] Item removed from grid after deletion
- [ ] Can cancel deletion
- [ ] When quantity reaches 0, deletion prompt appears

### Data Persistence
- [ ] Close and reopen app - items still there
- [ ] Add item, close app, reopen - item persists
- [ ] Update quantity, close app, reopen - change persists

### UI/UX
- [ ] Animations are smooth
- [ ] Colors and gradients look good
- [ ] Text is readable
- [ ] Buttons are easy to tap
- [ ] Navigation is intuitive

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