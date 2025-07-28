# Blood Bank Management System

A comprehensive Flutter application for managing blood bank operations, donor registration, and blood inventory tracking.

## 🚀 Latest Updates (v1.8.0)

### ✅ Fixed Issues
- **Fixed launch.json syntax error** - Removed duplicate closing brace
- **Improved debugging configurations** - Added comprehensive debugging setups for all platforms
- **Enhanced error handling** - Better exception handling throughout the application
- **Updated session management** - Improved user session handling and persistence

### 🔧 New Features
- **Comprehensive Debugging Support** - Added debugging configurations for all platforms:
  - Web platforms (Chrome, Edge, Firefox, Web Server)
  - Mobile platforms (Android Device/Emulator, iOS Device/Simulator)
  - Desktop platforms (Windows, macOS, Linux)
  - Performance modes (Profile, Release)
  - Hot reload configurations
  - Testing configurations
  - Custom debugging options

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

## 🔍 Debugging Configurations

The project includes comprehensive debugging configurations in `.vscode/launch.json`:

### Web Development
- **Flutter Web (Chrome)** - Debug in Chrome browser
- **Flutter Web (Edge)** - Debug in Edge browser
- **Flutter Web (Firefox)** - Debug in Firefox browser
- **Flutter Web Server** - Debug with web server

### Mobile Development
- **Flutter Android (Device)** - Debug on physical Android device
- **Flutter Android (Emulator)** - Debug on Android emulator
- **Flutter iOS (Device)** - Debug on physical iOS device
- **Flutter iOS (Simulator)** - Debug on iOS simulator

### Desktop Development
- **Flutter Windows** - Debug on Windows
- **Flutter macOS** - Debug on macOS
- **Flutter Linux** - Debug on Linux

### Performance Testing
- **Flutter Profile Mode** - Performance profiling
- **Flutter Release Mode** - Production-like testing

### Hot Reload Development
- **Flutter Hot Reload (Android)** - Fast development on Android
- **Flutter Hot Reload (iOS)** - Fast development on iOS
- **Flutter Hot Reload (Web)** - Fast development on Web

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

## 🔐 Default Admin Credentials

- **Email**: mbilalpk56@gmail.com
- **Password**: 1Q2w3e5R

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

Run tests using the provided debugging configurations:
- **Flutter Test** - Run widget tests
- **Flutter Test All** - Run all tests

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
