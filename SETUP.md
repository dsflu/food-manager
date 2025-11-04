# FreshKeeper - Xcode Project Setup

⚠️ **Important**: You need to create a fresh Xcode project. Don't try to open an existing .xcodeproj file.

This guide will walk you through creating the project and adding the source files. **Takes about 5 minutes.**

---

## Step-by-Step Setup (5 minutes)

### Step 1: Open Xcode

1. Open **Xcode** application
2. You'll see the welcome screen

### Step 2: Create New Project

1. Click **"Create New Project"** (big button in the center)
   - Or: File → New → Project (⌘⇧N)

### Step 3: Choose Template

1. At the top, select **iOS** tab
2. Select **App** template
3. Click **Next** button (bottom right)

### Step 4: Configure Project Settings

Fill in these **exact** values:

- **Product Name**: `FreshKeeper`
- **Team**: Select your Apple ID from dropdown
  - If you don't see your Apple ID:
    - Click "Add an Account..."
    - Sign in with your Apple ID
    - Select it from the Team dropdown
- **Organization Identifier**: `com.yourname` (or anything)
- **Bundle Identifier**: Will auto-generate (e.g., com.yourname.FreshKeeper)
- **Interface**: **SwiftUI** ⚠️ IMPORTANT
- **Language**: **Swift**
- **Storage**: **SwiftData** ⚠️ IMPORTANT
- **Include Tests**: ❌ UNCHECK this box

Click **Next**

### Step 5: Choose Save Location

⚠️ **CRITICAL**: This is where you save

1. Navigate to: `/Users/flu/Codes/fun/food-manager/`
2. ⚠️ **Important**:
   - Xcode will CREATE a "FreshKeeper" folder
   - You'll end up with: `/Users/flu/Codes/fun/food-manager/FreshKeeper/FreshKeeper.xcodeproj`
   - This will MERGE with the existing FreshKeeper folder (that's OK!)
3. Click **Create**

### Step 6: Replace Generated Files

Xcode created some default files we don't need.

1. **In Xcode's left sidebar**, you'll see:
   - FreshKeeper (folder)
     - FreshKeeperApp.swift
     - ContentView.swift ← Delete this
     - Item.swift ← Delete this
     - Assets.xcassets

2. **Delete these files**:
   - Right-click **ContentView.swift** → Delete → Move to Trash
   - Right-click **Item.swift** → Delete → Move to Trash

### Step 7: Add Our Source Files

Now add the real source code:

1. **Open Finder** (keep Xcode open)
2. Navigate to: `/Users/flu/Codes/fun/food-manager/FreshKeeper/FreshKeeper/`
3. You should see these folders:
   - **Models** (folder)
   - **Views** (folder)
   - **Utilities** (folder)

4. **Drag these 3 folders** from Finder into Xcode:
   - In Xcode left sidebar, find the "FreshKeeper" group (yellow folder icon)
   - Drag **Models**, **Views**, and **Utilities** folders and drop them on "FreshKeeper"

5. **When the dialog appears**:
   - ✅ **Copy items if needed**: CHECKED
   - ✅ **Create groups**: Selected (not "folder references")
   - ✅ **Add to targets**: FreshKeeper should be CHECKED
   - Click **Finish**

### Step 8: Replace FreshKeeperApp.swift

The generated FreshKeeperApp.swift is wrong. Replace it:

1. **In Xcode**, find and select `FreshKeeperApp.swift` in the left sidebar
2. **Delete it**: Right-click → Delete → Move to Trash
3. **In Finder**, navigate to: `/Users/flu/Codes/fun/food-manager/FreshKeeper/FreshKeeper/`
4. **Drag** `FreshKeeperApp.swift` from Finder into Xcode's FreshKeeper group
5. When prompted:
   - ✅ Copy items if needed
   - ✅ FreshKeeper target checked
   - Click Finish

### Step 9: Add Camera Permissions

1. In Xcode, click **FreshKeeper** (blue project icon at top of left sidebar)
2. Select **FreshKeeper** under TARGETS
3. Click **Info** tab
4. In the list, find any row, hover over it, click the **+** button
5. Add these two permissions:

**Permission 1:**
- Key: `Privacy - Camera Usage Description` (or type `NSCameraUsageDescription`)
- Value: `FreshKeeper needs camera access to photograph food items`

**Permission 2:**
- Click **+** again
- Key: `Privacy - Photo Library Usage Description` (or type `NSPhotoLibraryUsageDescription`)
- Value: `FreshKeeper needs photo access to select food item pictures`

### Step 10: Build and Run!

1. At the top of Xcode, find the device selector (next to Play/Stop buttons)
2. Click it and choose:
   - **Your iPhone 16** (if connected)
   - OR **iPhone 16 Pro Simulator** (for testing without camera)

3. Click the **Play button** ▶️ (or press **⌘R**)

4. Xcode will:
   - Compile the code (~30 seconds first time)
   - Install on device/simulator
   - Launch the app

### Step 11: Trust Developer (iPhone only, first time)

If testing on real iPhone and you see "Untrusted Developer":

1. On iPhone: Settings → General → VPN & Device Management
2. Find your Apple ID under "Developer App"
3. Tap it → Tap "Trust"
4. Confirm
5. Go back and launch the app

---

## ✅ You're Done!

The app should now be running. You can:
- Tap the **+** button to add food items
- Take photos (real device) or choose from library
- Track your fridge and freezer inventory

---

## 🆘 Troubleshooting

### "No such module 'SwiftData'"
→ Click FreshKeeper project → FreshKeeper target → General tab → Minimum Deployments → Set iOS to **17.0**

### "Cannot find FoodItem in scope"
→ Make sure Models folder is in the project. Check: Right-click Models/FoodItem.swift → Show File Inspector → Target Membership → FreshKeeper should be checked

### Build fails
→ Product → Clean Build Folder (⌘⇧K), then build again (⌘B)

### Xcode can't find source files
→ You may need to manually add file references:
1. Right-click FreshKeeper group → Add Files to "FreshKeeper"
2. Navigate to `/Users/flu/Codes/fun/food-manager/FreshKeeper/FreshKeeper/`
3. Select Models, Views, Utilities folders
4. Options: Copy items, Create groups, Add to FreshKeeper target
5. Click Add

---

**Total time: ~5 minutes. Then you're ready to test!** 🎉
