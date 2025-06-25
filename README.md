# UMKM E-Commerce & POS System

An integrated Point-of-Sale (POS) and E-Commerce application built for small to medium businesses (UMKM) using Flutter and Firebase. The application provides two interfaces - an admin panel for restaurant/business management and a customer-facing app for ordering and payment.

![UMKM Application Preview](assets/icon.png)

## Table of Contents

- [Features](#features)
- [Technology Stack](#technology-stack)
- [Setup and Installation](#setup-and-installation)
- [Application Workflow](#application-workflow)
- [Data Structure](#data-structure)
- [User Roles](#user-roles)
- [Screens and Navigation](#screens-and-navigation)
- [Project Structure](#project-structure)
- [Firebase Configuration](#firebase-configuration)
- [Contributing](#contributing)

## Features

### Admin Panel Features

- Dashboard with real-time analytics
- Product management (add, edit, delete)
- Order tracking and management
- Payment verification
- Sales reports and analytics
- User management

### Customer Features

- Product browsing and ordering
- Cart management
- Order tracking
- Payment processing and proof of payment upload
- Order history

## Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
- **State Management**: Provider
- **Data Visualization**: fl_chart
- **Image Handling**: image_picker
- **Date Formatting**: intl
- **Notifications**: flutter_local_notifications

## Setup and Installation

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Firebase account
- Android Studio / VS Code with Flutter extensions

### Steps to Install

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd umkm_ecommerce
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS/Web apps to your Firebase project
   - Download and add the Google Services configuration files to your project:
     - For Android: `google-services.json` to `android/app/`
     - For iOS: `GoogleService-Info.plist` to `ios/Runner/`
   - Enable Authentication, Firestore, and Storage in Firebase Console

4. **Run the application**
   ```bash
   flutter run
   ```

### Admin Panel Access

- The admin panel is designed for landscape orientation and works best on tablets or desktop
- Login with admin credentials:
  - Email: [admin email]
  - Password: [admin password]

### Customer App Access

- The customer app is designed for portrait orientation and works on phones
- Users can register their own accounts or use test credentials:
  - Email: [customer email]
  - Password: [customer password]

## Application Workflow

### Admin Workflow

1. **Login**: Admin logs in with admin credentials
2. **Dashboard**: View key metrics and product analytics
3. **Product Management**: Add, edit, or delete products
4. **Order Management**: Process orders and update order status
5. **Payment Verification**: Verify payment proofs uploaded by customers
6. **Reports**: Generate and view sales reports

### Customer Workflow

1. **Login/Register**: Customer logs in or creates a new account
2. **Browse Products**: View available products
3. **Add to Cart**: Select products and add to cart
4. **Checkout**: Submit order with details (name, table number, notes)
5. **Payment**: Upload payment proof or mark for in-person payment
6. **Order Status**: Track order status through the process

## Data Structure

### Firebase Collections

1. **users**

   - `email`: String
   - `role`: String (admin, customer)

2. **produk** (Products)

   - `nama`: String
   - `jenis`: String (Makanan, Minuman)
   - `harga`: Number
   - `stok`: String (Ada, Habis)
   - `gambar_url`: String
   - `createdAt`: Timestamp

3. **pesanan** (Orders)

   - `pelanggan`: String
   - `meja`: String
   - `catatan`: String
   - `status`: String (Belum Dibayar, Menunggu Konfirmasi, Diproses, Dikirim, Selesai)
   - `total`: Number
   - `tanggal`: Timestamp
   - `bukti_pembayaran_url`: String
   - `id_pembayaran`: String
   - `pembayaran_divalidasi`: Boolean
   - `waktu_validasi`: Timestamp
   - **Subcollection** - `items`:
     - `nama`: String
     - `jumlah`: Number
     - `total`: Number

4. **pembayaran** (Payments)
   - `id_pesanan`: String
   - `bukti_pembayaran_url`: String
   - `waktu_pembayaran`: Timestamp
   - `status`: String

## User Roles

### Admin

- Full access to all features
- Can manage products, orders, and reports
- Can validate payments and update order status

### Customer

- Can browse products and place orders
- Can upload payment proof
- Can track order status
- Can view order history

## Screens and Navigation

### Admin Screens

- Login Page
- Dashboard
- Product Management
- Order Management
- Order Details
- Sales Reports

### Customer Screens

- Login/Register
- Product Catalog
- Cart
- Checkout
- Order History
- Order Details

## Project Structure

```
lib/
├── main.dart              # Application entry point
├── routes.dart            # Route definitions
├── firebase_options.dart  # Firebase configuration
├── models/                # Data models
├── screens/
│   ├── admin/             # Admin interface screens
│   ├── auth/              # Authentication screens
│   ├── customer/          # Customer interface screens
│   └── widgets/           # Shared widgets
└── services/              # Business logic and services
```
