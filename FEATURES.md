# ✨ FreshKeeper Features

Complete feature showcase with usage examples.

---

## 📸 Visual Inventory Management

### Photo Capture
- **Camera**: Take photos directly from the app
- **Photo Library**: Choose existing photos
- **No Photo**: Falls back to category emoji icon
- **Image Quality**: Optimized JPEG compression (50%) for performance

### Grid View
- **LazyVGrid**: Efficient scrolling for hundreds of items
- **Card Layout**: 2-column grid on iPhone, responsive
- **Live Updates**: Changes reflect immediately

---

## 🏷️ Smart Organization System

### Dynamic Storage Locations

**Default Locations:**
- 🧊 **Fridge** (blue)
- ❄️ **Freezer** (cyan)

**Custom Locations:**
- Add unlimited custom storage
- Examples: "Garage Freezer", "Pantry Box", "Wine Cooler"
- Choose from 12 icons (fridge, snowflake, box, cabinet, etc.)
- Pick from 8 colors (green, blue, cyan, purple, orange, red, brown, grey)
- Edit icon/color of default locations
- Delete only custom locations

**How to Add:**
1. Tap grid icon (📊) in top-left
2. Tap + button
3. Enter name, pick icon & color
4. Tap Save

### Dynamic Food Categories

**8 Default Categories:**
- 🥩 Meat
- 🥬 Vegetables
- 🍎 Fruits
- 🥛 Dairy
- 🍞 Bread
- 🧃 Beverages
- 🍱 Prepared Meals
- 📦 Other

**Custom Categories:**
- Create unlimited custom categories
- Examples: "Snacks", "Frozen Pizza", "Condiments", "Baby Food"
- Choose from 24 emoji icons
- Your categories persist across app launches

**How to Add:**
1. When adding food, scroll categories
2. Tap "+ Add Custom"
3. Enter category name
4. Pick emoji icon
5. Tap Save

### Filtering & Search

**Filter by Location:**
- Tap "All" to see everything
- Tap location chip to filter (e.g., "Fridge")
- Tap again to clear filter

**Search:**
- Pull down on main screen to reveal search bar
- Type food name (e.g., "chicken")
- Results update live as you type

---

## ⏰ Expiry Date Tracking

### Setting Expiry Dates

**Quick Shortcuts:**
- **3d**: Expires in 3 days
- **7d**: Expires in 7 days (default)
- **14d**: Expires in 2 weeks
- **30d**: Expires in 1 month

**Custom Date Picker:**
- Pick any future date
- Shows days remaining countdown
- Example: "Expires in 12 days"

**Optional:**
- Toggle on/off when adding food
- Add later by editing item

### Expiry Warnings on Cards

**Color-Coded Badges:**

🔴 **Red - Expired**
- Background: #F44336
- Icon: ⚠️ exclamationmark.triangle.fill
- Text: "Expired 2d ago", "Expired today"

🟠 **Orange - Expiring Soon** (within 3 days)
- Background: #FF9800
- Icon: ⏰ clock.fill
- Text: "Expires today", "Expires tomorrow", "Expires in 2d"

🔵 **Light Blue - Good**
- Background: #E8F4F8
- Icon: 📅 calendar
- Text: "Expires in 7d"

### In Detail View

**Expiry Display:**
- Shows date: "Nov 12, 2025"
- Shows countdown: "(5d left)"
- Warning color if expired/expiring soon
- Tap pencil icon to edit

**Edit Expiry:**
- Change date
- Remove expiry date (toggle off)
- Quick shortcut buttons available

---

## 📦 Stock Management

### Adding Items

**Step-by-Step:**
1. Tap + button (top-right)
2. Photo (optional):
   - Tap camera icon
   - Choose "Take Photo" or "Choose from Library"
3. Food Name (required):
   - Visible placeholder: "e.g., Chicken Breast"
   - Auto-focus on field
4. Quantity (default: 1):
   - Use +/- buttons
   - Min: 1, Max: 999
5. Storage Location:
   - Scroll horizontally
   - Tap to select (Fridge is default)
6. Category:
   - Scroll horizontally
   - Tap to select or create custom
7. Notes (optional):
   - Multi-line text area
   - Example: "From Costco, freeze half"
8. Expiry Date (optional):
   - Toggle on
   - Pick date or use shortcuts
9. Tap "Add to Inventory"

**Validation:**
- Name field must not be empty
- Save button disabled if name is empty

### Editing Items

**Edit Name:**
- Tap pencil icon in navigation bar
- Type new name
- Tap Save

**Edit Other Fields:**
- Tap field row with pencil icon
- Select new value
- Dismisses automatically on selection

**Update Quantity:**
- Use large +/- buttons in detail view
- Shows animation on change
- Can't go below 0

**Delete Item:**
- Scroll to bottom in detail view
- Tap red "Delete Item" button
- Confirmation dialog appears

### Auto-Delete on Zero

When quantity reaches 0:
- Confirmation dialog appears
- "Item finished! Delete it?"
- Tap "Delete" or "Keep" (keep at 0)

---

## 🎨 Design & UX

### Typography
- **Font Family**: SF Rounded (Apple's friendly system font)
- **Food Name**: Bold, 17pt, #1A1A1A
- **Labels**: Semibold, 15pt, #666666
- **Values**: Medium, 17pt, #1A1A1A
- **Timestamps**: Medium, 13pt, #999999
- **Placeholders**: Medium, 17pt, #999999

### Colors
```
Primary Green:    #4CAF50 (actions, quantities)
Cool Blue:        #2196F3 (info, edit buttons)
Urgent Orange:    #FF9800 (expiring soon)
Alert Red:        #F44336 (expired, delete)
Dark Text:        #1A1A1A (readable on white)
Mid Grey:         #666666 (labels)
Light Grey:       #999999 (placeholders, timestamps)
Background Grey:  #F8F9FA (app background)
Card White:       #FFFFFF (cards, inputs)
```

### Animations
- **Spring**: 0.3s response, 0.7 damping (smooth, natural)
- **Quantity Changes**: Scale animation
- **Card Taps**: No animation (removed press effect for clarity)
- **Transitions**: Slide in/out for sheets

### Interactions
- **Keyboard Dismiss**: Scroll to hide, tap outside to hide
- **Tap Cards**: Navigate to detail view
- **Swipe**: No swipe gestures (use button for delete)
- **Pull to Refresh**: Reveals search bar

---

## 🔒 Privacy & Data

### Local Storage
- **SwiftData**: All data stored on device
- **Location**: App's sandbox (inaccessible to other apps)
- **Photos**: Stored as JPEG data in database
- **No Cloud**: Never synced or uploaded

### Permissions
- **Camera**: Only requested when taking photo
- **Photo Library**: Only requested when choosing photo
- **No Network**: App works completely offline

### Data Migration
- Schema changes handled by SwiftData
- Major changes may require fresh install (delete & reinstall)
- Data is backed up with iPhone backups (iTunes/iCloud)

---

## ⚡ Performance

### Optimizations
- **Image Compression**: 50% JPEG quality (balance of size & clarity)
- **External Storage**: Photos stored efficiently outside main database
- **Lazy Loading**: Grid uses LazyVGrid for efficient scrolling
- **Query Optimization**: Sorted queries with fetch descriptors
- **Minimal Re-renders**: @Bindable for precise updates

### Build Modes
- **Debug**: Slow (10-50x), for development
- **Release**: Fast, for testing and production
- See [PERFORMANCE.md](PERFORMANCE.md) for details

---

## 🌟 Unique Features

### What Makes FreshKeeper Special

**✅ Fully Customizable**
- Not limited to pre-defined storage or categories
- Create your own organization system
- Adapts to your kitchen setup

**✅ Visual Expiry Tracking**
- See expiry status at a glance
- Color-coded badges on every card
- No need to open items to check

**✅ Clean, Modern UI**
- No clutter, no confusion
- Visible text (no white-on-white!)
- Smooth, intuitive interactions

**✅ Efficient**
- Optimized image storage
- Fast scrolling with hundreds of items
- Keyboard auto-dismisses

**✅ Privacy-Focused**
- Zero tracking
- No accounts, no login
- Your data stays yours

---

## 🚀 Coming Soon (Ideas)

Future enhancements to consider:

- **Notifications**: Remind when food is expiring
- **Recipes**: Link items to recipes
- **Shopping List**: Generate list from low stock
- **Barcode Scanner**: Quick add packaged items
- **Export**: Share inventory via CSV
- **Dark Mode**: Full dark theme support
- **iPad Support**: Multi-column layout
- **Widgets**: Home screen quick view

---

**Want to contribute a feature?** Fork the repo and create a pull request! 🎉
