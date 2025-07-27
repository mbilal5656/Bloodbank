# 🩸 Blood Bank Management System

[![Flutter](https://img.shields.io/badge/Flutter-3.32.7-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://flutter.dev/)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen.svg)](https://github.com/)

A comprehensive Flutter application for managing blood bank operations with secure user authentication, inventory management, and donor/receiver services. Built with modern Flutter architecture, enhanced security features, and a beautiful Ocean Blue theme.

## 📋 Table of Contents

- [✨ Features](#-features)
- [🛠️ Technical Stack](#️-technical-stack)
- [🎨 Design System](#-design-system)
- [📱 Screenshots](#-screenshots)
- [🚀 Getting Started](#-getting-started)
- [📁 Project Structure](#-project-structure)
- [🔧 Configuration](#-configuration)
- [🎯 Usage Guide](#-usage-guide)
- [🔒 Security Features](#-security-features)
- [📊 Data Management](#-data-management)
- [🤝 Contributing](#-contributing)
- [📝 License](#-license)
- [📞 Support & Contact](#-support--contact)
- [🔄 Version History](#-version-history)
- [🐛 Known Issues & Solutions](#-known-issues--solutions)
- [🚀 Deployment](#-deployment)

## ✨ Features

### 🔐 Security & Authentication
- **Secure Login System** with SharedPreferences database
- **Password Hashing** using Base64 encoding (production-ready hashing recommended)
- **Session Management** with SharedPreferences
- **Role-based Access Control** (Admin, Donor, Receiver)
- **Forgot Password** functionality with email verification and 6-digit reset codes
- **Strong Password Validation** (8+ chars, uppercase, lowercase, digits, special chars)
- **Profile Management** with secure password reset
- **Email-based Password Reset** with secure code verification

### 👥 User Management
- **User Registration** for Donors and Receivers (Admin signup disabled)
- **Profile Editing** - users can update their information
- **Password Reset** with email verification workflow
- **Secure Logout** functionality
- **Admin User Management** - comprehensive user management with add, edit, delete, and password reset
- **Real-time User Session** management
- **Admin-only User Creation** - only admins can create new admin accounts

### 🩺 Blood Inventory Management
- **Real-time Blood Stock** tracking
- **Blood Type Management** (A+, A-, B+, B-, AB+, AB-, O+, O-)
- **Inventory CRUD Operations** (Create, Read, Update, Delete)
- **Availability Checking** for blood types
- **Stock Level Monitoring** with visual indicators
- **Emergency Blood Requests** with priority processing
- **Color-coded Blood Types** for easy identification

### 🏥 Admin Dashboard
- **Full CRUD Operations** on users and blood inventory
- **User Analytics** and management with total user count
- **Blood Inventory Control** with real-time updates
- **Comprehensive Admin Tools**
- **User Management**: Add, edit, delete, and reset passwords
- **Admin User Creation**: Only admins can create new admin accounts
- **Stock Level Management**
- **System Overview** with key metrics
- **Modern UI** with color-coded user types and action buttons

### 🩸 Donor Services
- **Donation Eligibility Checker**
- **Age and Health Verification** (18-65 years)
- **Recent Donation Tracking** (3-month restriction)
- **Blood Type Compatibility** checking
- **Secure Code Generation** for donation tracking
- **Donation Scheduling** system
- **Health Assessment** questionnaire

### 🏥 Receiver Services
- **Blood Availability Checker** with real-time data
- **Blood Request Form** with patient details
- **Urgency Level Selection** (Normal, Urgent, Emergency)
- **Verification Code System** for secure requests
- **Hospital/Clinic Information** tracking
- **Priority Processing** for urgent requests
- **Request Status Tracking**

### 📞 Contact & Support
- **Contact Us Page** with inquiry form
- **Emergency Contact Information**
- **Direct Email/Phone Integration** with url_launcher
- **Location Services** with Google Maps integration
- **Operating Hours** display
- **Real-time Support** system

### 🎨 Modern UI/UX
- **Beautiful Ocean Blue Theme** with gradient design
- **Glass Effect Components** for modern appearance
- **Responsive Layout** for all screen sizes
- **Material Design 3** components
- **Smooth Animations** and transitions
- **Accessibility Features** for better user experience
- **Dark/Light Mode** ready (theme system in place)

## 🛠️ Technical Stack

- **Framework**: Flutter 3.32.7+
- **Language**: Dart 3.8.1+
- **Database**: SharedPreferences (Local Storage)
- **Session Management**: SharedPreferences
- **Security**: Base64 Password Encoding + Strong Validation
- **UI Framework**: Material Design 3
- **Theme System**: Custom Ocean Blue theme with gradients
- **Platforms**: Web, Android, iOS, Windows, macOS, Linux
- **Dependencies**: 
  - shared_preferences: ^2.5.3
  - url_launcher: ^6.3.2
  - crypto: ^3.0.6
  - sqflite: ^2.4.2

## 🎨 Design System

### Color Palette
- **Primary Blue**: #2196F3
- **Secondary Blue**: #03A9F4
- **Accent Cyan**: #00BCD4
- **Success Green**: #4CAF50
- **Error Red**: #F44336
- **Warning Orange**: #FF9800
- **Surface White**: #FFFFFF
- **Background Gray**: #F5F5F5

### UI Components
- **Glass Effect Cards** with transparency
- **Gradient Backgrounds** for visual appeal
- **Modern Form Fields** with validation
- **Animated Loading States**
- **Responsive Grid Layouts**
- **Consistent Typography** hierarchy

## 📱 Screenshots

### Authentication & User Management
- **Splash Screen**: Beautiful animated welcome screen with Ocean Blue theme
- **Login Page**: Secure authentication with modern form design
- **Signup Page**: User registration with comprehensive validation
- **Forgot Password**: Email-based password reset with secure codes
- **Profile Management**: User profile editing with modern UI

### Core Features
- **Home Page**: Main dashboard with quick access features and glass effects
- **Admin Dashboard**: Complete inventory and user management
- **Donor Page**: Eligibility checking and donation scheduling
- **Receiver Page**: Blood availability and request system
- **Contact Page**: Support and emergency contact information

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.32.7 or higher)
- Dart SDK (3.8.1 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/bloodbank.git
   cd bloodbank
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For web (recommended)
   flutter run -d web-server --web-port=8080
   
   # For Chrome
   flutter run -d chrome
   
   # For Edge
   flutter run -d edge
   
   # For Windows
   flutter run -d windows
   
   # For Android
   flutter run -d android
   ```

### Default Admin Credentials
- **Email**: mbilalpk56@gmail.com
- **Password**: 1Q2w3e5R
- **User Type**: Admin

## 📁 Project Structure

```
lib/
├── main.dart                    # Main application entry point
├── db_helper.dart              # SharedPreferences database operations
├── session_manager.dart        # Session management utilities
├── splash_screen.dart          # App splash screen with animations
├── home_page.dart              # Main dashboard with glass effects
├── login_page.dart             # User authentication
├── signup_page.dart            # User registration
├── forgot_password_page.dart   # Password reset functionality
├── profile_page.dart           # User profile management
├── settings_page.dart          # App settings
├── contact_page.dart           # Contact and support
├── admin_page.dart             # Admin dashboard
├── donor_page.dart             # Donor services
├── receiver_page.dart          # Receiver services
├── theme/
│   └── app_theme.dart          # Modern Ocean Blue theme system
└── utils/
    └── secure_code_generator.dart  # Secure code generation utilities
```

## 🔧 Configuration

### Database Setup
The app automatically initializes with:
- Default admin user (mbilalpk56@gmail.com / 1Q2w3e5R)
- SharedPreferences for data persistence
- Secure password hashing
- User session management

### Security Features
- **Password Validation**: Minimum 8 characters with mixed case, digits, and special characters
- **Session Management**: Secure token-based sessions
- **Access Control**: Role-based permissions (Admin/Donor/Receiver)
- **Input Validation**: Comprehensive form validation
- **Secure Code Generation**: For donation and request tracking
- **Email Verification**: For password reset functionality

### Theme Configuration
- **Centralized Theme System**: All colors and styles in `lib/theme/app_theme.dart`
- **Gradient Decorations**: Beautiful background gradients
- **Glass Effect Components**: Modern transparent UI elements
- **Responsive Design**: Works on all screen sizes
- **Accessibility**: High contrast and readable typography

## 🎯 Usage Guide

### For Admins
1. **Login** with admin credentials
2. **Manage Blood Inventory**: Add, edit, delete blood stock levels
3. **User Management**: View and delete registered users
4. **Monitor System**: Track blood availability and user activity
5. **System Overview**: View key metrics and statistics

### For Donors
1. **Register** as a donor with personal information
2. **Check Eligibility**: Verify age, health status, and donation history
3. **Schedule Donation**: Get secure codes for donation tracking
4. **Update Profile**: Modify personal information and preferences
5. **Health Assessment**: Complete eligibility questionnaire

### For Receivers
1. **Register** as a receiver
2. **Check Availability**: Search for specific blood types
3. **Submit Requests**: Fill blood request forms with patient details
4. **Track Requests**: Use verification codes to monitor request status
5. **Emergency Requests**: Priority processing for urgent needs

## 🔒 Security Features

- **Strong Password Policy**: 8+ characters with mixed requirements
- **Session Management**: Secure token-based authentication
- **Access Control**: Role-based permissions and restrictions
- **Data Validation**: Comprehensive input sanitization
- **Secure Code Generation**: For tracking donations and requests
- **Password Reset**: Email-based secure password recovery with 6-digit codes
- **Input Sanitization**: Protection against malicious input

## 📊 Data Management

### User Data
- **Personal Information**: Name, email, age, blood group, contact
- **Authentication**: Hashed passwords and session tokens
- **Role Management**: Admin, Donor, or Receiver permissions
- **Profile Updates**: Secure profile modification
- **Session Tracking**: Real-time user activity monitoring

### Blood Inventory
- **Blood Types**: A+, A-, B+, B-, AB+, AB-, O+, O- with color coding
- **Stock Levels**: Real-time availability tracking
- **Status Indicators**: Visual alerts for low/critical stock
- **Request Tracking**: Secure codes for blood requests
- **Priority Management**: Emergency request processing

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Development Guidelines
- Follow Flutter best practices
- Maintain consistent code formatting
- Add proper error handling
- Include comprehensive validation
- Test on multiple platforms
- Use the centralized theme system
- Follow Material Design 3 guidelines

### Code Style
- Use meaningful variable and function names
- Add comments for complex logic
- Follow Dart/Flutter conventions
- Ensure all tests pass before submitting

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support & Contact

For support and questions:
- **Email**: mbilalpk56@gmail.com
- **Phone**: +92 321 6412855
- **Emergency**: +92 321 6412855

## 🚨 Emergency Contact

For urgent blood requests or emergencies:
- **24/7 Emergency Hotline**: +92 321 6412855
- **Address**: 123 Main Street, City, State 12345
- **Operating Hours**: Mon-Fri: 9am - 6pm, Sat: 10am - 4pm

## 🔄 Version History

- **v1.0.0** - Initial release with core authentication and user management
- **v1.1.0** - Added forgot password and contact features
- **v1.2.0** - Enhanced security with strong password validation
- **v1.3.0** - Added donor and receiver services with secure code generation
- **v1.4.0** - Modern UI redesign with pink/purple gradient theme
- **v1.5.0** - Enhanced admin dashboard and blood inventory management
- **v1.6.0** - **NEW**: Modern Ocean Blue theme with glass effects and improved UX
- **v1.7.0** - **NEW**: Enhanced admin functionality with user management, password reset, and admin-only user creation

## 🐛 Known Issues & Solutions

### Common Issues
1. **Web Browser Compatibility**: Use Chrome or Edge for best experience
2. **Windows Desktop**: Requires Visual Studio with C++ workload
3. **Password Reset**: Ensure email exists in database before reset
4. **Port Conflicts**: Use different ports if 8080 is occupied

### Troubleshooting
- Run `flutter doctor` to check environment setup
- Use `flutter clean` and `flutter pub get` for dependency issues
- Check browser console for web-specific errors
- For port conflicts: `flutter run -d web-server --web-port=8081`

### Performance Tips
- Use Chrome or Edge for optimal web performance
- Enable hardware acceleration in browser settings
- Clear browser cache if experiencing issues
- Use the web-server mode for development

## 🚀 Deployment

### Web Deployment
```bash
# Build for production
flutter build web --release

# Deploy to any web server
# Copy build/web/ contents to your web server
```

### Mobile Deployment
```bash
# Android APK
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release
```

### Docker Deployment (Optional)
```dockerfile
# Dockerfile example
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y curl
RUN curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.7-stable.tar.xz
RUN tar xf flutter_linux_3.32.7-stable.tar.xz
ENV PATH="$PATH:/flutter/bin"
WORKDIR /app
COPY . .
RUN flutter build web --release
EXPOSE 8080
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080"]
```

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/bloodbank&type=Date)](https://star-history.com/#yourusername/bloodbank&Date)

## 📊 Project Statistics

![GitHub stars](https://img.shields.io/github/stars/yourusername/bloodbank)
![GitHub forks](https://img.shields.io/github/forks/yourusername/bloodbank)
![GitHub issues](https://img.shields.io/github/issues/yourusername/bloodbank)
![GitHub pull requests](https://img.shields.io/github/issues-pr/yourusername/bloodbank)
![GitHub license](https://img.shields.io/github/license/yourusername/bloodbank)

---

**Made with ❤️ for the Blood Bank Community**

*This application helps save lives by connecting blood donors with those in need, providing a secure and efficient platform for blood bank management with a modern, beautiful interface.*

---

<div align="center">

**If this project helps you, please give it a ⭐️**

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/yourusername)

</div>
