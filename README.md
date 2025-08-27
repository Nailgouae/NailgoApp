# Nailgo - AI Nail Measurement & Shopping App

## Project Overview
Nailgo is a Flutter-based mobile application that allows users to **measure their nails using AI**, browse and purchase nail products, and manage their shopping experience seamlessly. The app includes features for product browsing, product details, cart management, checkout, and payment.  

---

## Features

### User Flow
1. **Login / Signup:** Users can create an account or log in.  
2. **AI Nail Measurement:**
   - After successful signup, users are directed to the **Measurement Screen**.  
   - Users take pictures of **four fingers first, then the thumb**.  
   - Nail measurements are captured and stored for future orders.  
3. **Continue Shopping:** Users can browse products after taking measurements.  
4. **Ordering:**
   - When placing an order, the stored nail measurements are **sent along with the order**.  
5. **Cart & Checkout:** Add products to the cart, select delivery address, and complete payment.  
6. **User Profile & Wishlist:** Manage account information and save favorite products.  

### Other Features
- **Home Page:** Shows featured products, AI nail measurement suggestions, and trending items.  
- **Product Page:** Browse all products with search and filter options.  
- **Product Detail Page:** Detailed view of each product with images, pricing, and "Add to Cart".  
- **Address Management:** Add or edit delivery addresses.  
- **Payment Options:** Multiple payment methods supported.  
- **Continue Shopping:** Return to browsing products after checkout.  

---

## Setup Instructions

### 1. Prerequisites
- Flutter SDK >= 3.0
- Android Studio or VS Code
- Git
- Emulator or physical device

### 2. Clone the Repository
```bash
- git clone https://github.com/Nailgouae/Nailgo.git
- cd Nailgo

 3. Install Dependencies
 flutter clean
 flutter pub get

 4. Run the App
  # Run on Android Emulator / Device:
  flutter run
  # Run on iOS Simulator / Device (Mac required):
  flutter run

 5 . Build Release APK (Android)
   flutter build apk --release
# APK path: build/app/outputs/flutter-apk/app-release.apk


 6 . Build Release iOS App
    flutter build ios --release
# iOS build path: ios/Runner.xcarchive

 7 . Optional: Clean & Rebuild
    flutter clean
    flutter pub get
    flutter run

Note: Updating the App
The app is live on Google Play Store and Apple App Store.
Future updates should be published via the respective store consoles:
Google Play: Use the Google Play Console to upload a new release APK/AAB.
Apple App Store: Use Xcode or App Store Connect to upload a new version.
Flutter commands can be used to build new release versions before submission:


Assets & Configurations
All assets (images, icons) are located in the assets/ folder.
API endpoints are currently implemented directly in the screens (no separate ApiService).

Architecture & Notes

The app is fully functional, and all features work as intended.
major of the API calls and UI are implemented directly in the screens 




