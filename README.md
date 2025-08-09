# Blood Bank Management System

A comprehensive Flutter application for managing blood bank operations, donor registration, and blood inventory tracking.

## 🚀 Latest Updates (v1.9.0)

### ✅ Fixed Issues
- **Removed all debugging tools** - Cleaned up the codebase by removing all test and debugging tools
- **Fixed database structure** - Added missing columns to blood_requests and notifications tables
- **Improved database initialization** - Enhanced error handling and admin user creation
- **Cleaned up debug statements** - Removed all debug print statements for production-ready code
- **Fixed admin password** - Standardized admin password to 'admin123'

### 🔧 Database Improvements
- **Enhanced blood_requests table** - Added patientName, hospital, doctorName, contactNumber, approvedBy, approvedAt columns
- **Enhanced notifications table** - Added priority and payload columns
- **Improved database upgrade process** - Better handling of schema migrations
- **Fixed admin user creation** - Ensures admin user is created with correct credentials

### 📱 Platform Support
- **Android**: Full support with device and emulator configurations
- **iOS**: Device and simulator support
- **Web**: Chrome, Edge, Firefox, and Web Server support
- **Desktop**: Windows, macOS, and Linux support

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/mbilal5656/bloodbank.git
   cd bloodbank
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # Application entry point
├── splash_screen.dart        # Splash screen
├── home_page.dart           # Home page
├── login_page.dart          # Login functionality
├── signup_page.dart         # User registration
├── admin_page.dart          # Admin dashboard
├── donor_page.dart          # Donor management
├── receiver_page.dart       # Receiver management
├── profile_page.dart        # User profile
├── contact_page.dart        # Contact information
├── settings_page.dart       # App settings
├── forgot_password_page.dart # Password recovery
├── blood_inventory_page.dart # Blood inventory
├── notification_management_page.dart # Notification system
├── db_helper.dart           # Database operations
├── session_manager.dart      # Session management
├── notification_helper.dart  # Notification handling
├── theme/
│   └── app_theme.dart       # App theming
└── utils/
    └── secure_code_generator.dart # Security utilities
```

## 🔐 Login Credentials

### Admin Access
- **Email**: admin@bloodbank.com
- **Password**: admin123

### Donor Access
- **Email**: donor@bloodbank.com
- **Password**: donor123

### Receiver Access
- **Email**: receiver@bloodbank.com
- **Password**: receiver123

## 📊 Features

### User Management
- User registration and authentication
- Role-based access control (Admin, Donor, Receiver)
- Profile management
- Session persistence

### Blood Inventory
- Real-time blood stock tracking
- Blood type availability checking
- Inventory updates and management

### Admin Features
- User management dashboard
- Blood inventory overview
- Notification system
- System statistics

### Security
- Password hashing
- Session management
- Secure data storage

## 🧪 Testing

Run tests using Flutter's built-in testing framework:
```bash
flutter test
```

## 📱 Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Create an issue on GitHub
- Contact: mbilalpk56@gmail.com

## 🔄 Version History

- **v1.9.0** - Removed debugging tools, fixed database structure, cleaned up code
- **v1.8.0** - Fixed launch.json, improved debugging configurations
- **v1.7.0** - Enhanced admin functionality and documentation
- **v1.6.0** - Added notification system and improved UI
- **v1.5.0** - Added blood inventory management
- **v1.4.0** - Implemented user session management
- **v1.3.0** - Added donor and receiver pages
- **v1.2.0** - Enhanced authentication system
- **v1.1.0** - Basic CRUD operations
- **v1.0.0** - Initial release

---

**Note**: This application is designed for educational and demonstration purposes. For production use, additional security measures and compliance with healthcare regulations should be implemented.
