# 📝 **ChikiBite – Project Planning Document**

## 1️⃣ **Project Overview**

**ChikiBite** is a fast-food ordering mobile application inspired by brands like McDonald’s, KFC, and ZUS Coffee. The app allows users to browse food menus, customize orders, add items to a cart, and place pick-up/delivery orders through a modern and user-friendly interface.

---

## 2️⃣ **Project Objectives**

* Provide a convenient platform for users to order fast food quickly.
* Reduce waiting time at the counter by allowing pre-orders.
* Offer a simple, attractive, and seamless digital ordering experience.
* Allow easy menu browsing with images, prices, and item details.
* Enable restaurants to manage menus and orders efficiently.

---

## 3️⃣ **Target Users**

* Students
* Office workers
* Families who want fast food quickly
* Customers who frequently order take-away

---

## 4️⃣ **Core Features (MVP)**

### **User Side**

1. **User Registration & Login**

   * Email/password or Google login
2. **Home Page**

   * Food categories
   * Popular/recommended items
3. **Menu & Food Details**

   * Browse menu
   * Food images, description, price
   * Customization (spicy level, add-ons)
4. **Cart & Checkout**

   * Add/remove items
   * Update quantity
   * Total price calculation
   * Delivery/pick-up option
5. **Order Placement**

   * Order summary
   * Payment (simulated or online)
   * Save order history
6. **Order Tracking**

   * Status updates: Pending → Preparing → Ready

---

## 5️⃣ **Optional but Strong Features (If you have time)**

* Promo codes
* Ratings & reviews
* Loyalty points
* Push notifications
* Dark mode
* Admin dashboard for restaurant staff

---

## 6️⃣ **App Flow (User Journey)**

```
Splash Screen → Login/Sign up → Home
  → Browse Menu → View Food → Add to Cart → Checkout 
  → Payment → Order Success → Order Tracking
  → Order History
```

---

## 7️⃣ **Technology Stack**

### **Frontend**

* **Flutter** (Dart)

### **Backend Options**

Choose one:

* **Firebase** (easier & faster)

  * Authentication
  * Firestore database
  * Storage for food images
* **Laravel API + MySQL** (if you want more control)

---

## 8️⃣ **Database Structure (If using Firebase Firestore)**

### **Users Collection**

| Field   | Type   |
| ------- | ------ |
| userId  | String |
| name    | String |
| email   | String |
| address | String |
| phone   | String |

### **Menu Collection**

| Field       | Type   |
| ----------- | ------ |
| itemId      | String |
| name        | String |
| price       | Double |
| imageUrl    | String |
| category    | String |
| description | String |

### **Orders Collection**

| Field       | Type                             |
| ----------- | -------------------------------- |
| orderId     | String                           |
| userId      | String                           |
| items       | List                             |
| totalPrice  | Double                           |
| orderStatus | String (Pending/Preparing/Ready) |
| timestamp   | DateTime                         |

---

## 9️⃣ **Project Timeline (Suggested)**

### **Week 1 – Planning & Setup**

* Project planning
* Create UI mockups
* Setup Flutter + Firebase
* Implement authentication

### **Week 2 – Core UI Screens**

* Home screen
* Menu screen
* Food detail screen
* Cart system

### **Week 3 – Backend & Features**

* Connect menu to database
* Checkout process
* Order submission + tracking

### **Week 4 – Finalisation**

* UI polish
* Bug fixing
* Documentation
* Demo video

---

## 🔟 **UI Pages to Design**

* Splash screen
* Login / Register
* Home
* Menu list
* Food details
* Cart
* Checkout
* Order success
* Order tracking
* User profile

---

## 1️⃣1️⃣ **Risks & Challenges**

* Time needed to build full features
* Integration issues with Firebase
* Managing state across multiple screens
* Performance when loading many images

---

## 1️⃣2️⃣ **Success Criteria**

* App runs smoothly on Android/iOS
* User can successfully browse menu and place orders
* Order data stored correctly
* UI is modern and easy to use