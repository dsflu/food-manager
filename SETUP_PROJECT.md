# FreshKeeper - Project Setup Instructions

## Issue: Xcode Project File Corrupted

The `.xcodeproj` file was invalid. Follow these steps to create a proper Xcode project and add the source files.

**Estimated time: 3 minutes**

---

## Step-by-Step Setup

### Step 1: Create New Xcode Project

1. **Open Xcode** on your Mac
2. **Create a new project**:
   - Click "Create New Project" or File → New → Project
3. **Choose template**:
   - Select **iOS** tab at the top
   - Choose **App** template
   - Click **Next**
4. **Configure project**:
   - **Product Name**: `FreshKeeper`
   - **Team**: Select your Apple ID (or add it)
   - **Organization Identifier**: `com.freshkeeper` (or your own)
   - **Interface**: **SwiftUI** ⚠️ Important!
   - **Language**: **Swift**
   - **Storage**: **SwiftData** ⚠️ Important!
   - ❌ Uncheck "Include Tests"
   - Click **Next**
5. **Save location**:
   - Navigate to: `/Users/flu/Codes/fun/food-manager/`
   - ⚠️ **IMPORTANT**: Xcode will create a "FreshKeeper" folder
   - You'll see: `/Users/flu/Codes/fun/food-manager/FreshKeeper/`
   - Click **Create**

### Step 2: Close the Default Files

Xcode created some default files we don't need:

1. **Delete these files** (select and press Delete key, choose "Move to Trash"):
   - `ContentView.swift` (in FreshKeeper folder)
   - `Item.swift` (in FreshKeeper folder)

### Step 3: Add Our Source Files

Now we'll add the files we already have:

1. **In Finder**:
   - Navigate to `/Users/flu/Codes/fun/food-manager/FreshKeeper/FreshKeeper/`
   - You should see:
     - `Models/` folder
     - `Views/` folder
     - `Utilities/` folder
     - `FreshKeeperApp.swift`
     - `Info.plist`

2. **Back in Xcode**:
   - In the left sidebar (Project Navigator), you should see the FreshKeeper group
   - **Drag and drop** these items from Finder into Xcode's FreshKeeper group:
     - `Models` folder
     - `Views` folder
     - `Utilities` folder

3. **When prompted "Choose options"**:
   - ✅ Check **"Copy items if needed"** (should already be checked)
   - ✅ Check **"Create groups"** (not "Create folder references")
   - ✅ Make sure **FreshKeeper** target is checked
   - Click **Finish**

### Step 4: Replace FreshKeeperApp.swift

1. **Delete the default FreshKeeperApp.swift**:
   - In Xcode left sidebar, find `FreshKeeperApp.swift`
   - Right-click → Delete → Move to Trash

2. **Add our FreshKeeperApp.swift**:
   - From Finder, drag `/Users/flu/Codes/fun/food-manager/FreshKeeper/FreshKeeper/FreshKeeperApp.swift`
   - Drop it in Xcode left sidebar into the FreshKeeper group
   - Choose options: Copy items, Create groups, FreshKeeper target checked
   - Click Finish

### Step 5: Update Info.plist with Permissions

1. **In Xcode left sidebar**, click on **FreshKeeper** (the blue project icon at the top)
2. Select **FreshKeeper** target (under TARGETS)
3. Click **Info** tab
4. Find **Custom iOS Target Properties** section
5. **Add Camera Permission**:
   - Hover over any row and click the **+** button
   - In the dropdown, type: `NSCameraUsageDescription`
   - Set Value to: `FreshKeeper needs access to your camera to take photos of your food items for easy identification.`
6. **Add Photo Library Permission**:
   - Click **+** again
   - Type: `NSPhotoLibraryUsageDescription`
   - Set Value to: `FreshKeeper needs access to your photo library to let you choose photos of your food items.`

### Step 6: Verify File Structure

In Xcode's left sidebar, you should now see:

```
FreshKeeper
├── FreshKeeperApp.swift
├── Models
│   └── FoodItem.swift
├── Views
│   ├── ContentView.swift
│   ├── FoodItemCard.swift
│   ├── AddFoodItemView.swift
│   └── FoodItemDetailView.swift
├── Utilities
│   └── CameraView.swift
└── Assets.xcassets
```

### Step 7: Build and Run

1. **Select a target device**:
   - Top bar in Xcode: Select your iPhone 16 or a simulator (e.g., iPhone 16 Pro)

2. **Build the project**:
   - Press **⌘B** or Product → Build
   - Wait for build to complete (should show "Build Succeeded")

3. **Run the app**:
   - Press **⌘R** or click the Play button ▶️
   - App should launch on your device or simulator

---

## ✅ Success!

If the app launches, you're all set! The project is now properly configured.

---

## ⚠️ If You Get Errors

### Error: "No such module 'SwiftData'"

**Fix**:
1. Click FreshKeeper project (blue icon)
2. Select FreshKeeper target
3. General tab
4. Minimum Deployments → iOS: Set to **17.0**

### Error: "Cannot find 'FoodItem' in scope"

**Fix**: Make sure you added the Models folder correctly
1. Check Models/FoodItem.swift is in the project
2. Select it → Right sidebar → Target Membership → Check FreshKeeper

### Error: Build failed with Swift errors

**Fix**: Clean build folder
1. Product → Clean Build Folder (⌘⇧K)
2. Try building again (⌘B)

---

## Alternative: Quick Script Method

If you prefer, you can use this Terminal command to set up the project structure:

```bash
cd /Users/flu/Codes/fun/food-manager
# This will be added in the next commit
```

---

## Need Help?

If you encounter issues:
1. Make sure you selected **SwiftUI** and **SwiftData** when creating the project
2. Make sure iOS deployment target is **17.0 or higher**
3. Check that all files have **FreshKeeper** target membership
4. Try Clean Build Folder (⌘⇧K) and rebuild

---

**Once you complete these steps, continue with the QUICKSTART.md or README.md guides!**
