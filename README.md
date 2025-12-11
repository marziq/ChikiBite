
---
<h1 align="center"> <img alt="logo" src="img/logo.png"/> </h1>
<h1 align="center"> ChikiBite – Food Ordering Mobile App </h1>

## a) Group Members

* Member 1: Ammar Haziq Bin Zainal | 2217763
* Member 2: Iryan Syauqi Bin Azhar | 2213601
* Member 3: Arina Batrisyia Sobhan Binti Mohd Razali | 2217572

---

## b) Project Title

ChikiBite – Fast Food Ordering Mobile Application

---

## c) Introduction

<p align="justify"> ChikiBite is a mobile application developed to provide users with a convenient and efficient way to order food and beverages directly from the ChikiBite restaurant. The application is designed to simplify the entire food ordering process, allowing users to browse menus, customize their orders and make secure payments directly through the app. Users can also choose between delivery and pickup options, ensuring flexibility based on their preferences. In addition to these core functionalities, ChikiBite includes real-time order tracking, allowing users to monitor the status of their orders from preparation to delivery and a rating and review system to provide feedback and improve the dining experience. The ChikiBite app aims to facilitate the ordering process and deliver a smooth experience for the restaurant’s customers by integrating these features into a user-friendly and responsive interface. </p>

---

## d) Objectives of the ChikiBite Mobile App 
* To provide customers with a convenient and efficient way to browse the restaurant’s menu, customize their orders and select either delivery or pickup options according to their preferences.
* To enable secure online payment and real-time order tracking, ensuring that customers can complete transactions smoothly and monitor the status of their orders from preparation to delivery or pickup.
* To design a user-friendly, intuitive and responsive mobile interface that enhances the overall dining experience while demonstrating effective use of Flutter for mobile app development.



---

## e) Target Users

* Customers – Individuals who want a convenient and efficient way to order food from ChikiBite, whether for pickup or delivery. They want an easy experience that allows them to browse the menu, customize their orders, make secure payments and track their orders all through a user-friendly mobile application.

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

---

## k) References

* Flutter Documentation: [https://flutter.dev/docs](https://flutter.dev/docs)
* Firebase Firestore Documentation: [https://firebase.google.com/docs/firestore](https://firebase.google.com/docs/firestore)
* Flutter UI Design Inspirations: [https://dribbble.com/tags/flutter](https://dribbble.com/tags/flutter)
* Provider State Management: [https://pub.dev/packages/provider](https://pub.dev/packages/provider)

---
