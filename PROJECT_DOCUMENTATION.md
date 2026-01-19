# Chikibite - Food Ordering Application Documentation

## Project Overview

**Chikibite** is a comprehensive Flutter-based mobile food ordering application that enables users to browse restaurants, view menus, place orders, track deliveries, and manage their accounts. The app integrates Firebase services for authentication and real-time data management, along with various features like payment methods, reward points, and delivery tracking.

---

## Table of Contents

1. [Project Dependencies](#project-dependencies)
2. [Project Structure](#project-structure)
3. [Core Models](#core-models)
4. [Authentication & Registration Flow](#authentication--registration-flow)
5. [Services Overview](#services-overview)
6. [Screens & UI Components](#screens--ui-components)
7. [Data Management](#data-management)
8. [Key Features](#key-features)

---

## Project Dependencies

### pubspec.yaml Configuration

The project uses modern Flutter packages with Firebase integration:

```yaml
name: chikibite
description: "A Food Ordering Application"
version: 0.1.0
```

### Key Dependencies:

#### **Firebase Services**
- `firebase_core: ^4.3.0` - Core Firebase functionality initialization
- `firebase_auth: ^6.1.3` - User authentication and email verification
- `cloud_firestore: ^6.1.1` - Cloud database for real-time data storage with offline persistence

#### **UI & UX**
- `flutter_rating_bar: ^4.0.1` - Rating system for food items and restaurants
- `flutter_easyloading: ^3.0.5` - Loading indicators for async operations
- `material_design_icons_flutter: ^7.0.7296` - Material Design icons
- `cupertino_icons: ^1.0.2` - iOS-style icons
- `otp_pin_field: ^1.2.0+2` - OTP input field for verification

#### **Location & Maps**
- `google_maps_flutter: ^2.3.1` - Interactive maps for delivery tracking
- `custom_map_markers: ^0.0.2+1` - Custom markers on maps

#### **Media & File Handling**
- `image_picker: ^1.0.8` - Camera/gallery image selection for profile pictures
- `path: ^1.8.0` - Path manipulation utilities (included with Flutter SDK)

#### **State Management & Data**
- `provider: ^6.1.2` - State management and dependency injection
- `get_it: ^9.2.0` - Service locator for dependency injection
- `shared_preferences: ^2.1.2` - Local storage for persistent data

#### **Utilities**
- `http: ^1.1.0` - HTTP requests to backend APIs
- `intl: ^0.20.2` - Internationalization and date formatting
- `flutter_timezone: ^5.0.1` - Timezone handling
- `flutter_dotenv: ^6.0.0` - Environment variables management

---

## Project Structure

```
lib/
├── main.dart                 # App entry point & Firebase initialization
├── data/
│   └── menu_data.dart       # Static menu data
├── models/                  # Data models
│   ├── user.dart            # User profile model
│   ├── order.dart           # Order and OrderItem models
│   ├── menu.dart            # Menu/Food item model
│   ├── cart_item.dart       # Shopping cart item model
│   ├── promo_code.dart      # Promotional codes model
│   └── voucher.dart         # Voucher/discount model
├── screens/                 # UI Screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── menu_screen.dart
│   ├── food_detail.dart
│   ├── checkout_screen.dart
│   ├── payment_methods_screen.dart
│   ├── delivery_address_screen.dart
│   ├── order_screen.dart
│   ├── order_history_screen.dart
│   ├── favorites_screen.dart
│   ├── profile_screen.dart
│   ├── personal_information_screen.dart
│   ├── reward_screen.dart
│   └── notifications_settings_screen.dart
├── services/                # Business logic & API layer
│   ├── auth_service.dart
│   ├── profile_service.dart
│   ├── firestore_service.dart
│   ├── cart_service.dart
│   ├── order_service.dart
│   ├── promo_code_service.dart
│   └── voucher_service.dart
├── widgets/                 # Reusable UI components
│   └── food_item_card.dart
└── utils/
    └── sample_data.dart     # Sample/placeholder data
```

---

## Core Models

### 1. **User Model** (`models/user.dart`)

Represents a user in the application with complete profile information:

```dart
class User {
  final String uid;                          // Unique Firebase ID
  final String name;                         // Display name
  final String email;                        // Email address
  final String? phone;                       // Phone number (optional)
  final int points;                          // Loyalty/reward points
  final Map<String, dynamic>? address;       // Current address
  final List<Map<String, dynamic>>? addresses; // Multiple saved addresses
  final String? photoUrl;                    // Profile picture URL
  final DateTime? createdAt;                 // Account creation timestamp
  final List<String>? favoriteItems;         // IDs of favorite food items
  final List<Map<String, dynamic>>? paymentMethods; // Saved payment methods
  final Map<String, bool>? notificationSettings;   // Notification preferences
  final String? language;                   // Preferred language
}
```

### 2. **Order Model** (`models/order.dart`)

Represents a food order with items and status:

```dart
class OrderItem {
  final String itemId;                       // Reference to menu item
  final String name;                         // Item name
  final int quantity;                        // Quantity ordered
  final double price;                        // Price per unit
  final Map<String, String>? options;        // Custom options (e.g., extra toppings)
}

class Order {
  final String id;                           // Unique order ID
  final String userId;                       // Order owner UID
  final List<OrderItem> items;               // Items in order
  final double total;                        // Total amount
  final String status;                       // pending | preparing | delivering | completed | cancelled
  final String deliveryAddress;              // Delivery location
  final String paymentMethod;                // Payment type used
  final int pointsUsed;                      // Loyalty points applied to order
  final DateTime? createdAt;                 // Order creation time
}
```

### 3. **Menu Model** (`models/menu.dart`)

Represents a food item available for ordering.

### 4. **Cart Item Model** (`models/cart_item.dart`)

Represents items in the user's shopping cart.

### 5. **Voucher & Promo Code Models**

Represent discounts and promotional offers.

---

## Authentication & Registration Flow

### Registration Process

When a user creates a new account, the following process occurs:

#### **Step 1: User Input**
The user enters their information on `register_screen.dart`:
- Email
- Password
- Full Name
- Phone Number (optional)

#### **Step 2: Firebase Authentication**
```dart
final cred = await AuthService.register(
  _emailCtrl.text.trim(),
  _passwordCtrl.text,
);
```
- `AuthService.register()` calls Firebase to create a new user with email/password
- Error handling for common cases:
  - Email already in use
  - Weak password (< 6 characters)
  - Invalid email format

#### **Step 3: Update Display Name**
```dart
if (_nameCtrl.text.trim().isNotEmpty) {
  await cred.user?.updateDisplayName(_nameCtrl.text.trim());
  await cred.user?.reload();
}
```
- Firebase Auth display name is updated with the user's full name

#### **Step 4: Email Verification**
```dart
if (cred.user != null && !cred.user!.emailVerified) {
  try {
    await cred.user?.sendEmailVerification();
  } catch (emailError) {
    // Handle error if verification email fails to send
  }
}
```
- Firebase sends a verification email to the user's inbox

#### **Step 5: Create User Profile in Firestore**
```dart
if (cred.user != null) {
  await profileService.createUserProfile(
    uid: cred.user!.uid,
    name: _nameCtrl.text.trim(),
    email: _emailCtrl.text.trim(),
    phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
  );
}
```

**This is where user data is stored in the database:**

In `ProfileService.createUserProfile()`:
```dart
await _db.collection('users').doc(uid).set({
  'uid': uid,                                    // Unique user ID
  'name': name,                                  // Full name
  'email': email,                                // Email address
  'phone': phone,                                // Phone (can be null)
  'points': 0,                                   // Initial points (0)
  'addresses': [],                               // Empty delivery addresses
  'favoriteItems': [],                           // Empty favorites
  'createdAt': FieldValue.serverTimestamp(),    // Account creation time
}, SetOptions(merge: true));
```

**Firestore Database Structure:**
```
firestore
└── users (collection)
    └── [uid] (document)
        ├── uid: string
        ├── name: string
        ├── email: string
        ├── phone: string (nullable)
        ├── points: number
        ├── addresses: array
        ├── favoriteItems: array
        ├── createdAt: timestamp
        ├── photoUrl: string (optional)
        ├── paymentMethods: array (optional)
        ├── notificationSettings: map (optional)
        └── language: string (optional)
```

#### **Step 6: Sign Out & Show Message**
```dart
await AuthService.signOut();

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text(
      'Account created! Please verify your email before signing in.',
    ),
    backgroundColor: Colors.green,
  ),
);
```
- User is signed out temporarily
- User sees confirmation message
- User is directed back to login screen to verify email first

#### **Step 7: Email Verification (User Action)**
- User checks their email inbox
- User clicks the verification link sent by Firebase
- User can now log in successfully

### Login Process

In `login_screen.dart`:
```dart
final credential = await AuthService.signIn(email, password);
```

In `AuthService.signIn()`:
```dart
static Future<UserCredential> signIn(String email, String password) async {
  final credential = await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  
  // Check if email is verified
  final user = credential.user;
  if (user != null && !user.emailVerified) {
    await user.reload();
    if (!user.emailVerified) {
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Please verify your email before signing in...',
      );
    }
  }
  
  return credential;
}
```

**Login flow:**
1. User enters email & password
2. Firebase authenticates credentials
3. System checks if email is verified
4. If verified → User logged in successfully → Navigate to main app
5. If not verified → Show error message → Prompt user to verify email

---

## Services Overview

### 1. **AuthService** (`services/auth_service.dart`)

Handles all authentication operations:

| Method | Purpose |
|--------|---------|
| `authStateChanges()` | Returns stream of authentication state changes |
| `currentUser` | Gets the currently logged-in user |
| `signIn(email, password)` | Login with email & password (checks email verification) |
| `register(email, password)` | Create new user account |
| `signOut()` | Logout current user |
| `updateDisplayName(name)` | Update Firebase Auth display name |

**Error Handling:**
- `email-already-in-use`
- `invalid-email`
- `weak-password`
- `email-not-verified`
- `invalid-credential`

### 2. **ProfileService** (`services/profile_service.dart`)

Manages user profile data in Firestore:

| Method | Purpose |
|--------|---------|
| `createUserProfile()` | Create new user document in Firestore (called during registration) |
| `getUserProfile(uid)` | Stream of user profile (real-time updates) |
| `getUserProfileOnce(uid)` | Fetch user profile once |
| `updateUserProfile(uid, data)` | Update any user fields |
| `updatePersonalInfo()` | Update name, phone, or profile picture |
| `addAddress()` | Add a new delivery address |
| `updateAddress()` | Edit existing address |
| `deleteAddress()` | Remove an address |
| `setDefaultAddress()` | Set primary delivery address |
| `addPaymentMethod()` | Save payment card/method |
| `updatePaymentMethod()` | Update payment details |

### 3. **FirestoreService** (`services/firestore_service.dart`)

Low-level Firestore operations:

| Collection | Purpose |
|------------|---------|
| `users` | User profiles & data |
| `Menu` | Available food items |
| `orders` | Placed orders |

**Key Operations:**
```dart
// Place an order
Future<DocumentReference> placeOrder(Map<String, dynamic> order)

// Get user's orders (real-time stream)
Stream<QuerySnapshot> ordersForUser(String uid)

// Update order status
Future<void> updateOrderStatus(String orderId, String status)

// Get menu items
Stream<QuerySnapshot> menuStream()
```

### 4. **CartService** (`services/cart_service.dart`)

Manages shopping cart using Provider:
- Add items to cart
- Remove items from cart
- Update quantities
- Calculate totals
- Uses `ChangeNotifier` for state management

### 5. **OrderService** (`services/order_service.dart`)

Handles order creation and management:
- Create orders from cart items
- Apply promo codes
- Use loyalty points
- Track order status

### 6. **PromoCodeService** (`services/promo_code_service.dart`)

Manage promotional codes and discounts:
- Validate promo codes
- Calculate discounts
- Track usage

### 7. **VoucherService** (`services/voucher_service.dart`)

Handle vouchers and special offers:
- Get available vouchers
- Apply vouchers to orders
- Track voucher usage

---

## Screens & UI Components

### Authentication Screens

#### **SplashScreen** (`screens/splash_screen.dart`)
- Initial app loading screen
- Checks authentication state
- Routes to appropriate screen (Login/Main)

#### **LoginScreen** (`screens/login_screen.dart`)
- Email & password login
- Email verification check
- Navigation to register screen
- Password reset option

#### **RegisterScreen** (`screens/register_screen.dart`)
- User registration form
- Collects: Name, Email, Password, Phone
- Triggers registration flow described above
- Email verification workflow

### Main App Screens

#### **MainScreen** (`screens/main_screen.dart`)
- Bottom navigation hub
- Routes to: Home, Menu, Orders, Favorites, Profile

#### **HomeScreen** (`screens/home_screen.dart`)
- Featured restaurants/items
- Search functionality
- Category browsing
- Quick access to menu

#### **MenuScreen** (`screens/menu_screen.dart`)
- Browse available food items
- Filter by category
- Search items
- View item details

#### **FoodDetail** (`screens/food_detail.dart`)
- Item details with images
- Description & reviews
- Options/customizations
- Add to cart button
- Rating display

#### **CheckoutScreen** (`screens/checkout_screen.dart`)
- Cart review
- Delivery address selection
- Payment method selection
- Apply promo codes/vouchers
- Loyalty points redemption
- Final order confirmation

#### **PaymentMethodsScreen** (`screens/payment_methods_screen.dart`)
- View saved payment methods
- Add new card
- Edit/delete payment methods
- Set default payment

#### **DeliveryAddressScreen** (`screens/delivery_address_screen.dart`)
- List saved addresses
- Map view for address selection
- Add new address
- Edit address
- Set default delivery address

#### **OrderScreen** (`screens/order_screen.dart`)
- Current active orders
- Real-time order status tracking
- Estimated delivery time
- Driver location (maps integration)
- Contact support option

#### **OrderHistoryScreen** (`screens/order_history_screen.dart`)
- Previous orders list
- Order details/receipt
- Reorder option
- Order tracking history

#### **FavoritesScreen** (`screens/favorites_screen.dart`)
- Saved favorite food items
- Quick add to cart from favorites
- Remove from favorites

#### **ProfileScreen** (`screens/profile_screen.dart`)
- User profile overview with profile picture display
- Quick access to personal info
- Settings shortcuts
- Logout button

**Profile Picture Display:**
The profile screen now dynamically displays the user's profile picture with the same priority system as PersonalInformationScreen:
1. **Local Profile Picture** → Shows if user has uploaded a picture
2. **Firebase Photo URL** → Shows if only cloud photo is available
3. **Default Person Icon** → Displays when neither local nor cloud photo exists

**Implementation Details:**
```dart
// Asynchronously loads local profile picture on screen load
FutureBuilder<String?>(
  future: _loadLocalProfilePicture(user.uid),
  builder: (context, snapshot) {
    final localProfilePicture = snapshot.data;
    // Display logic with three-tier fallback system
  },
)
```

**Helper Method:**
```dart
Future<String?> _loadLocalProfilePicture(String uid) async {
  // Attempts to load from: {system-temp}/chikibite_profile_pictures/{uid}.jpg
  // Returns path if file exists, null otherwise
}
```

This ensures that whenever a user navigates to their profile, the most recent locally saved picture is displayed immediately, providing real-time feedback for any picture changes made in PersonalInformationScreen.

#### **PersonalInformationScreen** (`screens/personal_information_screen.dart`)
- Edit name & email
- Upload profile picture from gallery
- Update phone number
- View account creation date

**Profile Picture Upload Feature:**
The screen now includes an interactive profile picture upload system with a camera icon button overlay on the profile picture circle. When clicked, users can:
1. Select an image from their device gallery
2. The image is compressed to 85% quality for optimal storage
3. The image is saved locally to the device's temporary directory at: `{system-temp}/chikibite_profile_pictures/{uid}.jpg`
4. The profile picture updates immediately in the UI
5. On subsequent visits, the locally saved picture is automatically loaded and displayed

**Implementation Details:**
```dart
// State variables
String? _localProfilePicture;     // Path to saved local profile picture
bool _isPickingImage = false;     // Flag to prevent concurrent image picker calls

// Methods
Future<void> _loadLocalProfilePicture()  // Loads saved picture on init
Future<void> _pickProfilePicture()       // Handles image selection & save
```

**Image Display Priority:**
1. Local profile picture (if exists) → Shows user-uploaded image
2. Firebase photoUrl (if local doesn't exist) → Shows cloud storage image
3. Default person icon → Fallback placeholder

**Technical Implementation:**
```dart
child: _localProfilePicture != null
    ? ClipOval(child: Image.file(File(_localProfilePicture!), ...))
    : _currentUser?.photoUrl != null
        ? ClipOval(child: Image.network(_currentUser!.photoUrl!, ...))
        : Icon(Icons.person, ...)
```

The camera button is now fully functional and calls `_pickProfilePicture()` instead of showing a "coming soon" message.

#### **RewardScreen** (`screens/reward_screen.dart`)
- Loyalty points balance
- Points earning history
- Redeem points option
- Points breakdown by order

#### **NotificationsSettingsScreen** (`screens/notifications_settings_screen.dart`)
- Toggle notification types
- Order updates
- Promotional notifications
- Email preferences

### UI Components

#### **FoodItemCard** (`widgets/food_item_card.dart`)
- Reusable card for displaying food items
- Shows image, name, price, rating
- Add to cart button
- Favorite toggle

---

## Data Management

### Cloud Firestore Database Structure

```
firestore/
├── users (collection)
│   └── [uid]
│       ├── uid
│       ├── name
│       ├── email
│       ├── phone
│       ├── points (loyalty points)
│       ├── addresses (array of delivery addresses)
│       ├── favoriteItems (array of item IDs)
│       ├── paymentMethods (array)
│       ├── photoUrl
│       ├── createdAt (timestamp)
│       ├── notificationSettings (map)
│       └── language
│
├── Menu (collection)
│   └── [itemId]
│       ├── name
│       ├── description
│       ├── price
│       ├── image
│       ├── category
│       ├── rating
│       ├── reviews
│       ├── available
│       └── createdAt
│
├── orders (collection)
│   └── [orderId]
│       ├── userId
│       ├── items (array of OrderItem)
│       ├── total
│       ├── status (pending|preparing|delivering|completed|cancelled)
│       ├── deliveryAddress
│       ├── paymentMethod
│       ├── pointsUsed
│       ├── promoCode (optional)
│       ├── voucherId (optional)
│       ├── createdAt (timestamp)
│       └── deliveredAt (optional)
│
├── promoCodes (collection)
│   └── [codeId]
│       ├── code
│       ├── discount (% or fixed amount)
│       ├── expiryDate
│       ├── usageLimit
│       └── usageCount
│
└── vouchers (collection)
    └── [voucherId]
        ├── title
        ├── description
        ├── discount
        ├── expiryDate
        └── active
```

### Local Storage (SharedPreferences)

```dart
// Persistent local data
- user_id (current user UID)
- theme_preference (light/dark)
- language_preference (locale)
- cart_data (local cart backup)
- recent_searches (list of search history)
```

### Profile Picture Local Storage

Profile pictures are stored **locally on the device** in the system temporary directory for development/testing purposes. **NOT in the project folder.**

**Storage Location (Device Storage):**
```
{device-system-temp}/chikibite_profile_pictures/{uid}.jpg
```

**Platform-Specific Paths:**
- **Android Device:** `/data/local/tmp/chikibite_profile_pictures/{uid}.jpg`
- **iOS Device:** App's temp directory on the device
- **Windows PC (Dev):** `C:\Users\[username]\AppData\Local\Temp\chikibite_profile_pictures\{uid}.jpg`

**Important:** These are device-specific locations, NOT the Flutter project folder. Each device stores its own copy of the profile pictures.

**Implementation:**
```dart
// Save profile picture (to device storage, not project)
final tempDir = Directory.systemTemp;  // Gets device's temp directory
final profileDir = Directory('${tempDir.path}/chikibite_profile_pictures');
final savedImage = await imageFile.copy('${profileDir.path}/$uid.jpg');

// Load profile picture (from device storage)
final profileImageFile = File('${profileDir.path}/$uid.jpg');
if (profileImageFile.existsSync()) {
  return profileImageFile.path;  // Returns device file path
}
```

**Features:**
- One picture per user (identified by UID)
- Stored on the device, persists across app restarts
- Automatically overwrites previous picture when new one is uploaded
- 85% image quality compression for storage efficiency
- Prevents concurrent image picker calls with `_isPickingImage` flag
- Graceful fallback to Firebase photoUrl if local picture unavailable

**Future Migration Note:**
In production, profile pictures should be uploaded to Firebase Cloud Storage instead of storing locally.

### Real-time Persistence

Firestore is configured with offline persistence enabled in `main.dart`:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
);
```
This allows the app to work offline and sync when reconnected.

---

## Key Features

### 1. **User Authentication**
- Email/password registration with verification
- Secure login with email verification requirement
- Password reset capability
- Firebase Auth integration

### 2. **User Profiles**
- Complete user profile management
- Multiple delivery addresses with default selection
- Profile picture upload with local storage
- Personal information updates

### 3. **Food Browsing & Ordering**
- Browse menu items with images & descriptions
- Search & filter functionality
- Add items to cart with customization options
- View item ratings & reviews
- Save favorite items

### 4. **Shopping Cart**
- Add/remove items
- Quantity management
- Real-time cart total calculation
- Local state management with Provider

### 5. **Checkout & Payment**
- Multiple delivery address support
- Multiple payment method support (cards, wallets, etc.)
- Apply promotional codes
- Redeem loyalty points
- Order review before confirmation

### 6. **Order Management**
- Place orders from cart
- Real-time order status tracking
- Order history with past order details
- Reorder functionality
- Estimated delivery time

### 7. **Loyalty Program**
- Earn points on purchases
- View points balance
- Redeem points at checkout
- Points earning history

### 8. **Location Features**
- Google Maps integration
- Delivery address selection on map
- Custom map markers for restaurants
- Real-time delivery tracking

### 9. **Media Handling**
- Profile picture upload from camera/gallery with real-time preview
- Local profile picture storage in device temporary directory
- Image compression (85% quality) for optimized storage
- Three-tier image display system (local → cloud → default icon)
- Persistent image loading across app sessions
- Image display in food items
- Custom map markers

### 10. **User Preferences**
- Notification settings
- Language selection
- Email preferences
- Theme customization

---

## State Management

The app uses **Provider** for state management:

```dart
// Example: CartService with ChangeNotifier
class CartService extends ChangeNotifier {
  List<CartItem> _items = [];
  
  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners(); // Rebuilds widgets listening to CartService
  }
}

// Usage in main.dart
ChangeNotifierProvider(
  create: (_) => CartService(),
  child: MaterialApp(...),
)
```

Benefits:
- Efficient widget rebuilding
- Simple and lightweight
- Easy to test
- Works seamlessly with Firebase streams

---

## Technology Stack Summary

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.9.2+ |
| **State Management** | Provider 6.1.2 |
| **Authentication** | Firebase Auth 6.1.3 |
| **Database** | Cloud Firestore 6.1.1 with offline persistence |
| **Maps & Location** | Google Maps Flutter 2.3.1 |
| **Media** | Image Picker 1.0.8 |
| **Local Storage** | SharedPreferences 2.1.2 |
| **UI Components** | Material Design 3 |
| **Utilities** | intl, flutter_timezone, http |

---

## Development Workflow

1. **Initialize Firebase** → `main.dart`
2. **Handle Authentication** → `auth_service.dart` & registration screens
3. **Create User Profile** → `profile_service.dart`
4. **Browse Menu** → `menu_screen.dart` & Firestore Menu collection
5. **Add to Cart** → `cart_service.dart` with Provider
6. **Checkout** → `checkout_screen.dart` with address & payment selection
7. **Place Order** → `order_service.dart` creates order in Firestore
8. **Track Order** → `order_screen.dart` streams order status
9. **Manage Account** → `profile_screen.dart` & related screens

---

## Conclusion

Chikibite is a well-structured food ordering application that leverages Firebase for real-time data synchronization, Flutter for cross-platform development, and modern state management practices. The clear separation of concerns with dedicated service classes makes the codebase maintainable and scalable.
