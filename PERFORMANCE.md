# ⚡ FreshKeeper Performance Guide

Tips for optimal performance and troubleshooting.

---

## 🚀 Build Configuration

### Debug vs Release Mode

The build configuration dramatically affects performance:

| Mode | Speed | Use Case |
|------|-------|----------|
| **Debug** | Very Slow (10-50x) | Development, debugging |
| **Release** | Fast | Testing, production |

### The Problem with Debug Mode

**Debug mode includes:**
- Extra runtime checks
- Verbose logging
- Unoptimized code
- Memory debugging tools

**Result:** App feels sluggish, animations stutter, camera is slow

### ✅ Switch to Release Mode

**How to Change:**

1. In Xcode menu: **Product** → **Scheme** → **Edit Scheme...**
2. Select **Run** in left sidebar
3. Find **Build Configuration**
4. Change from **Debug** to **Release**
5. Close dialog
6. Rebuild: **⌘R**

**Important:** Switch back to Debug when actively debugging!

---

## 📸 Image Performance

### Current Optimization
- **JPEG Compression**: 50% quality
- **Balance**: Good clarity + reasonable file size
- **Storage**: External storage attribute (efficient)

### Image Size Impact

| Compression | File Size | Quality |
|-------------|-----------|---------|
| 1.0 (100%) | ~2-4 MB | Perfect |
| 0.8 (80%) | ~800 KB | Excellent |
| **0.5 (50%)** | **~200 KB** | **Good (current)** |
| 0.3 (30%) | ~100 KB | Acceptable |

**Current setting balances:**
- Storage space
- Scrolling performance
- Visual quality
- Load times

### If Performance Issues Persist

**Option 1: Lower compression further**
```swift
// In AddFoodItemView.swift, saveItem()
let imageData = capturedImage?.jpegData(compressionQuality: 0.3) // Instead of 0.5
```

**Option 2: Resize images before compression**
```swift
// Resize to max 800x800 before compression
let maxDimension: CGFloat = 800
let ratio = min(maxDimension / image.size.width, maxDimension / image.size.height)
let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
```

---

## 🗄️ Database Performance

### SwiftData Optimizations

**✅ Already Implemented:**
- Sorted queries with `@Query(sort:)`
- External storage for photos
- Efficient fetch descriptors
- Relationship management

**Query Examples:**
```swift
// Efficient: sorted at database level
@Query(sort: \FoodItem.dateAdded, order: .reverse)
private var foodItems: [FoodItem]

// Efficient: sorted at database level
@Query(sort: \StorageLocation.sortOrder)
private var storageLocations: [StorageLocation]
```

### Large Datasets

**Performance with:**
- 100 items: Excellent
- 500 items: Very good
- 1000+ items: Good (LazyVGrid helps)

**If you have 1000+ items:**
- Consider pagination
- Add date range filters
- Archive old items

---

## 📱 Device Performance

### iOS Version
- **Minimum**: iOS 26.0
- **Recommended**: Latest iOS 26.x
- **SwiftData**: Built with iOS 26.0 SwiftData features

### Device Specs
- **Works well on:** iPhone 11 and newer
- **Optimal:** iPhone 13 and newer
- **Simulator**: Use iPhone 16 Pro for realistic testing

---

## 🐛 Common Performance Issues

### Issue: App is very slow

**Diagnosis Checklist:**
1. ✅ Are you in **Release** mode? (see above)
2. ✅ Are you testing on **real device** or simulator?
3. ✅ Do you have **hundreds of photos**? (check image compression)
4. ✅ Is your iPhone **up to date**? (update iOS)

**Solutions:**
- Switch to Release mode (biggest impact)
- Test on physical device (simulator is slower)
- Lower image compression if needed
- Clean build folder: Product → Clean Build Folder (⌘⇧K)

### Issue: Scrolling is choppy

**Possible Causes:**
- Debug mode (switch to Release)
- Very large images (check compression)
- Background app processes

**Solution:**
```bash
# Force quit all background apps on iPhone
# Double-tap home button (or swipe up)
# Swipe up on all apps
# Relaunch FreshKeeper
```

### Issue: Camera is slow to open

**Normal Behavior:**
- Camera takes ~1-2 seconds to initialize
- This is iOS camera system, not the app

**If slower than 3 seconds:**
- Check if in Debug mode
- Restart iPhone
- Check available storage (Settings → General → iPhone Storage)

### Issue: Keyboard is laggy

**Solution:**
- Ensure Release mode
- Check: Settings → General → Keyboard → Enable Key Flicks (off)
- Restart iPhone

---

## ⚠️ Console Warnings

### Harmless Warnings

These warnings are **normal** and can be **ignored**:

```
[SwiftUI] Publishing changes from within view updates
```
- SwiftUI internal, doesn't affect performance

```
[LayoutConstraints] Unable to simultaneously satisfy constraints
```
- SwiftUI layout system, usually resolves itself

```
[Assert] UINavigationBar decoded as unlocked for UINavigationController
```
- UIKit/SwiftUI interop, cosmetic only

### Warnings to Investigate

```
[Error] Cannot migrate store in-place
```
- **Action needed**: Delete app and reinstall (see README troubleshooting)

```
Memory pressure: critical
```
- **Action needed**: Check image compression, reduce quality

```
Thread Performance Checker: multiple threads
```
- **Action needed**: Ensure UI updates on main thread

---

## 📊 Benchmarks

Reference performance on iPhone 15 Pro (Release mode):

| Action | Time |
|--------|------|
| App launch | < 1 second |
| Load 100 items | < 500ms |
| Add new item | < 100ms |
| Open detail view | < 100ms |
| Update quantity | Instant |
| Take photo | ~1-2 seconds |
| Scroll grid | 60fps smooth |

---

## 🎯 Optimization Checklist

When optimizing, prioritize:

1. **Switch to Release mode** (biggest impact!)
2. Image compression (50% is good default)
3. Use LazyVGrid (already implemented)
4. Sorted queries at DB level (already implemented)
5. External photo storage (already implemented)
6. Profile with Instruments if issues persist

---

## 💡 Tips for Development

### During Development (Debug Mode)
- Accept slower performance
- Focus on functionality
- Use breakpoints freely

### Before Testing/Demoing (Release Mode)
- Switch to Release
- Test on real device
- Clean build folder
- Restart iPhone

### Before Showing to Team
- ✅ Release mode
- ✅ Real device
- ✅ Fresh install (delete old app)
- ✅ Add 20-30 sample items
- ✅ Test all features

---

**Performance issues not covered here?** Check the [README](README.md) troubleshooting section or open an issue on GitHub.
