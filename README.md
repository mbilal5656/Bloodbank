# 🩸 Blood Bank Management System

A comprehensive Flutter application for managing blood bank operations with secure user authentication, inventory management, and donor/receiver services.

## ✨ Features

### 🔐 Security & Authentication
- **Secure Login System** with SQLite database
- **Password Hashing** using SHA-256 encryption
- **Session Management** with SharedPreferences
- **Role-based Access Control** (Admin, Donor, Receiver)
- **Forgot Password** functionality
- **Profile Management** with password reset

### 👥 User Management
- **User Registration** for Donors, Receivers, and Admins
- **Profile Editing** - users can update their information
- **Password Reset** with email verification
- **Secure Logout** functionality

### 🩺 Blood Inventory Management
- **Real-time Blood Stock** tracking
- **Blood Type Management** (A+, A-, B+, B-, AB+, AB-, O+, O-)
- **Inventory CRUD Operations** (Create, Read, Update, Delete)
- **Availability Checking** for blood types
- **Stock Level Monitoring**

### 🏥 Admin Dashboard
- **Full CRUD Operations** on users and blood inventory
- **User Analytics** and management
- **Blood Inventory Control**
- **Real-time Updates**
- **Comprehensive Admin Tools**

### 🩸 Donor Services
- **Donation Eligibility Checker**
- **Age and Health Verification**
- **Recent Donation Tracking**
- **Blood Type Compatibility**

### 🏥 Receiver Services
- **Blood Availability Checker**
- **Real-time Stock Information**
- **Blood Type Search**
- **Unit Availability Display**

### 📞 Contact & Support
- **Contact Us Page** with inquiry form
- **Emergency Contact Information**
- **Direct Email/Phone Integration**
- **Location Services**

## 🛠️ Technical Stack

- **Framework**: Flutter
- **Database**: SQLite (Local Storage)
- **Session Management**: SharedPreferences
- **Security**: SHA-256 Password Hashing
- **Platforms**: Web, Android, iOS, Windows, macOS, Linux

## 📱 Screenshots

### Login & Authentication
- Secure login with role selection
- Forgot password functionality
- User registration

### Admin Dashboard
- Blood inventory management
- User management
- Real-time analytics

### User Dashboards
- Donor eligibility checker
- Blood availability checker
- Profile management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mbilal5656/bloodbank.git
   cd bloodbank
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Default Admin Credentials
- **Email**: admin@bloodbank.com
- **Password**: admin123

## 📁 Project Structure

```
lib/
├── main.dart              # Main application entry point
├── db_helper.dart         # SQLite database operations
├── session_manager.dart   # SharedPreferences session management
├── login_page.dart        # User authentication
├── signup_page.dart       # User registration
├── profile_page.dart      # User profile management
├── forgot_password_page.dart # Password reset functionality
├── contact_page.dart      # Contact and support
└── splash_screen.dart     # App splash screen
```

## 🔧 Configuration

### Database Setup
The app automatically creates the SQLite database with:
- Users table with secure password hashing
- Blood inventory table with default stock levels
- Default admin user

### Security Features
- All passwords are hashed using SHA-256
- Session tokens for secure authentication
- Role-based access control
- Input validation and sanitization

## 🎯 Usage

### For Admins
1. Login with admin credentials
2. Manage blood inventory (Add, Edit, Delete)
3. Manage users (View, Delete)
4. Monitor system analytics

### For Donors
1. Register as a donor
2. Check donation eligibility
3. Update profile information
4. Reset password if needed

### For Receivers
1. Register as a receiver
2. Check blood availability
3. View blood stock levels
4. Contact support if needed

## 🔒 Security Features

- **Password Hashing**: SHA-256 encryption
- **Session Management**: Secure token-based sessions
- **Access Control**: Role-based permissions
- **Data Validation**: Input sanitization
- **SQL Injection Prevention**: Parameterized queries

## 📊 Database Schema

### Users Table
- id (Primary Key)
- name, email, password (hashed)
- userType (Admin/Donor/Receiver)
- bloodGroup, age, contactNumber
- createdAt timestamp

### Blood Inventory Table
- id (Primary Key)
- bloodType (A+, A-, B+, B-, AB+, AB-, O+, O-)
- units (available quantity)
- lastUpdated timestamp

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- **Email**: contact@bloodbank.com
- **Phone**: +1 (234) 567-8900
- **Emergency**: +1 (234) 567-EMER (3637)

## 🚨 Emergency Contact

For urgent blood requests or emergencies:
- **24/7 Emergency Hotline**: +1 (234) 567-EMER (3637)
- **Address**: 123 Main Street, City, State 12345

## 🔄 Version History

- **v1.0.0** - Initial release with core features
- **v1.1.0** - Added forgot password and contact features
- **v1.2.0** - Enhanced security and UI improvements

---

**Made with ❤️ for the Blood Bank Community**
