# 📱 ServeEase – Local Service Provider Directory

ServeEase is a cross-platform mobile application that connects users with **verified local service providers** such as electricians, plumbers, cleaners, and more.  
The app allows customers to book services, service providers to manage bookings, and admins to approve/monitor activities.

---

## 🚀 Features

- **User Authentication** – Sign up, login, and forgot password using Firebase Authentication.
- **Role-Based Access** –  
  - **Customer**: Browse, book, and review services.  
  - **Service Provider**: Manage bookings, update service details.  
  - **Admin**: Approve service providers, manage platform data.
- **Service Booking** – Real-time booking and availability tracking.
- **Payments** – Secure payments via Razorpay (test mode for development).
- **Reviews & Ratings** – Customers can leave feedback for service providers.
- **Push Notifications** – Booking updates using Firebase Cloud Messaging (FCM).
- **Image Uploads** – Upload service images via Firebase Storage.
- **Location Services** – Detect user location using Flutter's [geolocator](https://pub.dev/packages/geolocator) package.
- **Responsive UI** – Works seamlessly on Android and iOS.

---

## 🛠 Tech Stack

**Frontend (Mobile App)**  
- [Flutter](https://flutter.dev/) – Cross-platform UI toolkit  
- [Dart](https://dart.dev/) – Programming language for Flutter  
- [Provider](https://pub.dev/packages/provider) – State management  
- [HTTP](https://pub.dev/packages/http) – API calls  
- [Geolocator](https://pub.dev/packages/geolocator) – Location fetching  

**Backend**  
- [Java Spring Boot](https://spring.io/projects/spring-boot) – REST API backend  
- [Firebase Authentication](https://firebase.google.com/docs/auth) – Authentication  
- [Firebase Firestore](https://firebase.google.com/docs/firestore) – NoSQL database  
- [Firebase Storage](https://firebase.google.com/docs/storage) – File uploads  
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging) – Notifications  

**Integrations**  
- [Razorpay](https://razorpay.com/) – Payment gateway  

---

## 📂 Project Structure

```plaintext
lib/
 ├── main.dart                  # Entry point of the application
 ├── screens/                   # All screen UI files
 ├── widgets/                   # Reusable UI components
 ├── models/                    # Data models
 ├── services/                  # Firebase & API services
 ├── providers/                 # State management providers
 ├── utils/                     # Helper functions and constants
assets/
 ├── images/                    # App images
 ├── icons/                     # App icons
 ├── fonts/                     # Custom fonts
.
.
.
⚙️ **Installation & Setup**
 - git clone https://github.com/sathish0416/serve_ease.git
 - cd serve_ease
 - flutter pub get
 - flutter run

**License**
Licensed under the MIT License — refer to the LICENSE file for details.

Author : **Sathish Madanu**
GitHub: @sathish0416
Email: sathishmadanu0416@gmail.com
