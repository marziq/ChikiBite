
---
<h1 align="center"> <img width="30%" height="auto" alt="logo" src="assets/img/logo.png"/> </h1>
<h1 align="center"> <a href="https://git.io/typing-svg"><img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=700&pause=1000&color=F7F518&background=FF421600&width=435&lines=ChikiBite+-+Food+Ordering+Mobile+Application" alt="Typing SVG" /></a> </h1>

## a) Group Members
* Member 1: Ammar Haziq Bin Zainal | 2217763
* Member 2: Iryan Syauqi Bin Azhar | 2213601
* Member 3: Arina Batrisyia Sobhan Binti Mohd Razali | 2217572

---

## b) Project Title

ChikiBite – Food Ordering Mobile Application

---

## c) Introduction

<p align="justify"> ChikiBite is a mobile application developed to provide users with a convenient and efficient way to order food and beverages directly from the ChikiBite restaurant. The application simplifies the entire food ordering process, allowing users to browse menus, customize their orders, and make secure payments directly through the app. Users can choose between delivery and pickup options, ensuring flexibility based on their preferences. In addition, ChikiBite includes real-time order tracking, allowing users to monitor the status of their orders from preparation to delivery. The app also rewards users with points for each purchase, which can be redeemed for free items, encouraging frequent usage and engagement. Overall, ChikiBite aims to deliver a smooth, user-friendly, and rewarding experience for its customers.</p>

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

<h4> Menu & Food Details </h4>

* Description: This module enables users to explore the restaurant’s full menu with detailed information including images, descriptions, and prices. Users can also customize their orders according to preferences, such as selecting spice level or add-ons. The interface ensures clarity and ease of selection for a personalized experience.
* Interactions: Select items, customize options, view details.
* UI Components: Menu cards, images, description text, price labels, dropdowns, checkboxes, add-to-cart buttons.

<h4> Cart & Checkout </h4>

* Description: The cart and checkout module allows users to manage their selected items and review order details before finalizing the purchase. It provides a clear overview of quantities, total price, and delivery or pickup options. This feature is designed to make the checkout process smooth and error-free.
* Interactions: Add/remove items, adjust quantity, select delivery or pickup, proceed to checkout.
* UI Components: Cart list, increment/decrement buttons, summary panel, checkout button, radio buttons for delivery options.

<h4> Order Placement </h4>

* Description: Users can review the order summary and complete payment securely through this module. All confirmed orders are saved in the user’s order history for future reference. This ensures reliability and transparency in the transaction process.
* Interactions: Confirm orders, make payment, view order history.
* UI Components: Order summary cards, payment forms, confirmation dialogs, receipt screens.

<h4> Order Tracking </h4>

* Description: This module provides real-time updates on the status of orders, from Pending to Completed. It allows users to monitor progress, reducing uncertainty and enhancing satisfaction. Notifications keep users informed at every stage of the order.
* Interactions: Monitor order status, receive notifications.
* UI Components: Status timeline, progress indicators, notification banners.

<h4> Reward Points</h4>

* Description: After paying for their orders, users will receive points based on the amount spent, which can be redeemed for free items. For example, if a user spends RM10, they receive 10 points. This feature encourages frequent usage and engagement by providing tangible rewards. The process is designed to be simple and motivating.
* Interactions: View current reward points balance, Redeem points, Track points earned, Receive notifications
* UI Components: Points balance display (badge or panel), Redeem button or link, List of redeemable items with required points, Progress bar for points toward next reward, Notifications/alerts for points earned or redemption success

**UI Components & Interactions:**

* Buttons: Add to cart, Checkout, Login/Register
* Lists/Grids: Menu items, categories
* Forms: Login, Address input, Payment
* Feedback: Toast messages, Loading indicators

---

## g) Proposed UI Mock-up

*Note: Replace the placeholders with your sketches or wireframes.*

* Splash Screen: 
<h1 align="center"> <img width="30%" height="auto" alt="logo" src="assets\img\Splash Screen.jpg"/> </h1>

* Home Screen: 
<h1 align="center"> <img width="30%" height="auto" alt="logo" src="assets\img\Home Page.jpg"/> </h1>

* Menu Screen: 
<h1 align="center"> <img width="30%" height="auto" alt="logo" src="assets\img\Menu Page.jpg"/> </h1>

* Cart & Checkout Screen: 
<h1 align="center"> <img width="30%" height="auto" alt="logo" src="assets\img\Order Page.jpg"/> </h1>

* Reward Points Screen: 
<h1 align="center"> <img width="30%" height="auto" alt="logo" src="assets\img\Rewards Page.jpg"/> </h1>

* Profile Screen:
<h1 align="center"> <img width="30%" height="auto" alt="logo" src="assets\img\Profile Page.jpg"/> </h1>


---

## h) Architecture / Technical Design

<h1 align="center"> <img width="30%" height="auto" alt="logo" src="assets\img\Chikibite - Architecture Design.png"/> </h1>
---

## i) Data Model

**Firestore Collections:**

<h1 align="center"> <img width="30%" height="auto" alt="logo" src="assets\img\ChikiBite Data Model.png"/> </h1>

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