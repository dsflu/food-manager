# FreshKeeper - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- Mac with macOS 14.0+
- Xcode 15.0+ (install from App Store)
- iPhone with iOS 17.0+ or use simulator
- Apple ID (free)

---

## Option 1: Test on iPhone (Full Features)

### 1️⃣ Clone & Open
```bash
cd ~/Desktop
git clone https://github.com/YOUR_USERNAME/food-manager.git
cd food-manager
open FreshKeeper/FreshKeeper.xcodeproj
```

### 2️⃣ Connect iPhone
- Plug in your iPhone with USB cable
- Unlock and tap "Trust This Computer"
- Enable Developer Mode:
  - Settings → Privacy & Security → Developer Mode → ON
  - Restart iPhone

### 3️⃣ Sign with Apple ID
In Xcode:
1. Click **FreshKeeper** (blue icon) in left sidebar
2. Select **FreshKeeper** target
3. Click **Signing & Capabilities** tab
4. Check "Automatically manage signing"
5. Choose your Apple ID from **Team** dropdown
6. If no Apple ID, click "Add Account..." and sign in

### 4️⃣ Run the App
1. Select your iPhone from device dropdown (top bar)
2. Click ▶ (Play button) or press **⌘R**
3. Wait for build and install
4. If "Untrusted Developer" error on iPhone:
   - Settings → General → VPN & Device Management
   - Tap your Apple ID → Trust

### 5️⃣ Grant Permissions
When app launches:
- Allow Camera access
- Allow Photos access

**✅ Done! Start adding food items!**

---

## Option 2: Test on Simulator (Faster, No Camera)

### 1️⃣ Clone & Open
```bash
cd ~/Desktop
git clone https://github.com/YOUR_USERNAME/food-manager.git
cd food-manager
open FreshKeeper/FreshKeeper.xcodeproj
```

### 2️⃣ Select Simulator
In Xcode:
1. Click device dropdown (top bar)
2. Hover over **iOS Simulators**
3. Choose **iPhone 16 Pro** or **iPhone 15 Pro**

### 3️⃣ Run the App
1. Click ▶ (Play button) or press **⌘R**
2. Wait for simulator to boot (1-2 min first time)
3. App launches automatically

### 4️⃣ Add Test Photos (Optional)
- Drag images from Mac into simulator window
- Photos go to simulated photo library
- Use "Choose from Library" in app

**✅ Done! Test the app!**

---

## 📱 Using the App

### Add Your First Item
1. Tap **+ button** (top right)
2. Tap photo area → Take Photo or Choose from Library
3. Enter name: "Chicken Breast"
4. Tap **+** to set quantity: 4
5. Select location: **Freezer 1**
6. Choose category: **🥩 Meat**
7. Tap **"Add to Inventory"**

### Update Stock
1. Tap any food card
2. Use **+ / -** buttons to adjust quantity
3. Changes save automatically

### Filter & Search
- Tap location chips: All, Fridge, Freezer 1, Freezer 2
- Pull down to reveal search bar

### Delete Item
- Option 1: Reduce quantity to 0
- Option 2: Open item → Tap "Delete Item"

---

## ⚠️ Common Issues

### "Failed to code sign"
→ Xcode → Preferences → Accounts → Download Manual Profiles

### iPhone not appearing
→ Disconnect/reconnect cable, unlock iPhone, tap "Trust"

### "Untrusted Developer" on iPhone
→ Settings → General → VPN & Device Management → Trust

### Simulator is slow
→ Use iPhone 15/16 Pro simulator, close other apps

### Camera not working in simulator
→ Expected! Camera only works on real device

---

## 📋 Quick Testing Checklist

Test these key features:

- [ ] App launches
- [ ] Add item with photo
- [ ] View item in grid
- [ ] Update quantity (+/-)
- [ ] Filter by location
- [ ] Search by name
- [ ] Delete item
- [ ] Close and reopen - data persists

---

## 🆘 Need Help?

- **Full README**: See [README.md](README.md) for detailed guide
- **Troubleshooting**: Check README troubleshooting section
- **Project Context**: See [claude.md](claude.md) for technical details

---

## 🎯 Tips for Best Experience

1. Use real iPhone for full camera functionality
2. Take well-lit photos for easy identification
3. Use consistent naming (e.g., "Chicken Breast" not "chicken")
4. Add expiration dates in notes field
5. Update stock regularly to keep inventory current

---

**Enjoy using FreshKeeper! Never forget what's in your fridge again! 🥬**
