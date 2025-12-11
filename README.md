
---
<h1 align="center"> <img width="30%" height="auto" alt="logo" src="img/logo.png"/> </h1>
<h1 align="center"> <a href="https://git.io/typing-svg"><img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=700&pause=1000&color=F7F518&background=FF421600&width=435&lines=ChikiBite+-+Food+Ordering+Mobile+Application" alt="Typing SVG" /></a> </h1>

## a) Group Members
<!-- <img alt="gif" src="img/group members.gif"/> -->
* Member 1: Ammar Haziq Bin Zainal | 2217763
* Member 2: Iryan Syauqi Bin Azhar | 2213601
* Member 3: Arina Batrisyia Sobhan Binti Mohd Razali | 2217572

---

## b) Project Title

ChikiBite – Food Ordering Mobile Application

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
<p align="justify"> The ChikiBite app provides a seamless and convenient food ordering experience through several core modules. Each module is designed with specific interactions and UI components to ensure usability, efficiency, and a responsive interface. </p>

<h3>Core Features: </h3>

<h4> User Registration & Login </h4>

* Description: This module allows users to securely create an account using email and password. It ensures that personal information and order history are protected while enabling a personalized experience. The authentication system is designed to be simple and reliable.
* Interactions: Sign up, log in, log out and reset password.
* UI Components: Text fields, buttons, authentication forms, profile icons.

<h4> Home Page </h4>

* Description: The home page acts as the central hub for accessing the restaurant’s offerings. It displays food categories, popular items, and recommended dishes in a visually appealing layout. This design allows users to navigate the menu efficiently and discover options quickly.
* Interactions: Browse categories, tap items to view details.
* UI Components: Category cards, horizontal scroll lists, banners, navigation menu.

*** Menu & Food Details ***
* Description: This module enables users to explore the restaurant’s full menu with detailed information including images, descriptions, and prices. Users can also customize their orders according to preferences, such as selecting spice level or add-ons. The interface ensures clarity and ease of selection for a personalized experience.
* Interactions: Select items, customize options, view details.
* UI Components: Menu cards, images, description text, price labels, dropdowns, checkboxes, add-to-cart buttons.

*** Cart & Checkout ***
* Description: The cart and checkout module allows users to manage their selected items and review order details before finalizing the purchase. It provides a clear overview of quantities, total price, and delivery or pickup options. This feature is designed to make the checkout process smooth and error-free.
* Interactions: Add/remove items, adjust quantity, select delivery or pickup, proceed to checkout.
* UI Components: Cart list, increment/decrement buttons, summary panel, checkout button, radio buttons for delivery options.

*** Order Placement ***
* Description: Users can review the order summary and complete payment securely through this module. All confirmed orders are saved in the user’s order history for future reference. This ensures reliability and transparency in the transaction process.
* Interactions: Confirm orders, make payment, view order history.
* UI Components: Order summary cards, payment forms, confirmation dialogs, receipt screens.

*** Order Tracking ***
* Description: This module provides real-time updates on the status of orders, from Pending to Completed. It allows users to monitor progress, reducing uncertainty and enhancing satisfaction. Notifications keep users informed at every stage of the order.
* Interactions: Monitor order status, receive notifications.
* UI Components: Status timeline, progress indicators, notification banners.

*** Rating & Reviews ***
* Description: After receiving their orders, users can rate dishes and provide feedback to the restaurant. This feature helps improve service quality and guides future customers in making informed choices. The process is designed to be simple, encouraging user participation.
* Interactions: Submit ratings, write reviews, view others’ feedback.
* UI Components: Star rating widgets, text input fields, review lists.

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
