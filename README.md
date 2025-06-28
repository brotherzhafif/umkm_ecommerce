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

- Product browsing with quantity controls (stepper UI)
- Advanced cart management with add/remove quantity
- Multiple delivery options:
  - Dine-in with table selection
  - Table delivery service
  - Address delivery
- Flexible payment methods:
  - Bank transfer with proof upload
  - Pay on-site (cash payment)
- Order tracking with real-time status updates
- Order history and detailed order management
- Enhanced order form with delivery preferences

### Enhanced Order Management

- **Quantity Controls**: Add/remove items with intuitive stepper controls
- **Delivery Options**: Choose between dine-in, table delivery, or address delivery
- **Table Selection**: Pick from tables 1-10 for dine-in or table delivery
- **Address Input**: Enter delivery address for home delivery orders
- **Payment Flexibility**: Support for both transfer payments and cash-on-delivery
- **Smart Validation**: Form validation based on selected delivery and payment options

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

### Enhanced Customer Workflow

1. **Login/Register**: Customer logs in or creates a new account
2. **Browse Products**: View available products with quantity controls
3. **Manage Cart**: Use stepper controls to add/remove items, see real-time totals
4. **Select Delivery**: Choose between dine-in, table delivery, or address delivery
5. **Choose Payment**: Select bank transfer or cash payment method
6. **Checkout**: Complete order with delivery and payment preferences
7. **Track Order**: Monitor order status through the fulfillment process

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

3. **pesanan** (Orders) - Enhanced Structure

   - `pelanggan`: String
   - `meja`: String (for table numbers)
   - `alamat_pengiriman`: String (for address delivery)
   - `tipe_pengiriman`: String (dine_in, table_delivery, address_delivery)
   - `info_pengiriman`: String (formatted delivery information)
   - `catatan`: String
   - `metode_pembayaran`: String (transfer, cash)
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

4. **pembayaran** (Payments) - Enhanced Structure
   - `id_pesanan`: String
   - `bukti_pembayaran_url`: String
   - `waktu_pembayaran`: Timestamp
   - `metode_pembayaran`: String (transfer, cash)
   - `status`: String

## User Roles

### Admin

- Full access to all features
- Can manage products, orders, and reports
- Can validate payments and update order status
- Monitor delivery and payment methods

### Customer

- Enhanced product browsing with quantity controls
- Flexible delivery options (dine-in, table delivery, address delivery)
- Multiple payment methods (transfer, cash)
- Advanced order management and tracking
- Real-time cart updates with stepper controls

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
- Enhanced Product Catalog with quantity steppers
- Advanced Cart Management
- Comprehensive Checkout with delivery/payment options
- Order History
- Enhanced Order Details

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
│   ├── customer/          # Enhanced customer interface screens
│   └── widgets/           # Shared widgets
└── services/              # Business logic and services
```
