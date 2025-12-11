
---

<h1 style='center'> ChikiBite – Food Ordering Mobile App </h1>

## a) Group Members

* Member 1: Ammar Haziq Bin Zainal | 2217763
* Member 2: Iryan Syauqi Bin Azhar | 2213601
* Member 3: Arina Batrisyia Sobhan Binti Mohd Razali | 2217572

---

## b) Project Title

ChikiBite – Fast Food Ordering Mobile Application

---

## c) Introduction

**Problem:**
Many people experience long waiting times at fast-food restaurants, especially during peak hours. Existing apps often lack a simple, engaging, and efficient interface for ordering fast food quickly.

**Motivation:**
We want to create a mobile app that allows users to browse menus, customize orders, and place pickup or delivery orders conveniently.

**Relevance:**
ChikiBite aims to improve the fast-food ordering experience, reduce wait times, and make ordering fun and easy for users.

---

## d) Objectives of the Proposed Mobile App

* Provide a convenient platform for ordering fast food from a mobile device.
* Reduce waiting time by enabling pre-ordering for pickup or delivery.
* Allow users to view detailed menus, customize orders, and track order status.
* Implement a modern, user-friendly, and interactive interface.

---

## e) Target Users

* Students and office workers looking for quick meals.
* Families ordering take-away or delivery.
* Fast-food enthusiasts who want a smooth digital ordering experience.

---

## f) Features and Functionalities

**Core Features:**

* User authentication (Sign up, Login)
* Home screen with categories and recommended items
* Menu listing with item details and customization options
* Cart system to manage selected items
* Checkout process with delivery/pickup options
* Order submission and tracking
* User profile and order history

**UI Components & Interactions:**

* Buttons: Add to cart, Checkout, Login/Register
* Lists/Grids: Menu items, categories
* Forms: Login, Address input, Payment
* Feedback: Toast messages, Loading indicators

---

## g) Proposed UI Mock-up

*Note: Replace the placeholders with your sketches or wireframes.*

* Splash Screen: [Placeholder]
* Home Screen: [Placeholder]
* Menu Screen: [Placeholder]
* Food Details Screen: [Placeholder]
* Cart & Checkout Screen: [Placeholder]
* Order Tracking Screen: [Placeholder]

---

## h) Architecture / Technical Design

**Widget Structure Example:**

* lib/

  * main.dart
  * screens/

    * home_screen.dart
    * menu_screen.dart
    * food_detail_screen.dart
    * cart_screen.dart
    * checkout_screen.dart
    * order_tracking_screen.dart
  * widgets/

    * food_item_card.dart
    * category_card.dart
    * order_status_tile.dart
  * models/

    * user.dart
    * menu_item.dart
    * order.dart
  * services/

    * auth_service.dart
    * firestore_service.dart

**State Management Approach:** Provider (for global state: cart, user info, orders)

**Navigation:** Navigator 2.0 / Named routes for screen transitions

---

## i) Data Model

**Firestore Collections:**

**Users**

* userId: String
* name: String
* email: String
* address: String
* phone: String

**Menu**

* itemId: String
* name: String
* price: Double
* imageUrl: String
* category: String
* description: String

**Orders**

* orderId: String
* userId: String
* items: List
* totalPrice: Double
* orderStatus: String (Pending/Preparing/Ready)
* timestamp: DateTime

---

## j) Flowchart / Sequence Diagram

Example flow:

Splash Screen → Login / Register → Home Screen → Select Category / Browse Menu → View Food Details → Add to Cart → Cart → Checkout → Payment → Order Confirmation → Order Tracking → Order History

*Replace with a proper diagram using draw.io, Lucidchart, or any diagram tool.*

---

## k) References

* Flutter Documentation: [https://flutter.dev/docs](https://flutter.dev/docs)
* Firebase Firestore Documentation: [https://firebase.google.com/docs/firestore](https://firebase.google.com/docs/firestore)
* Flutter UI Design Inspirations: [https://dribbble.com/tags/flutter](https://dribbble.com/tags/flutter)
* Provider State Management: [https://pub.dev/packages/provider](https://pub.dev/packages/provider)

---
