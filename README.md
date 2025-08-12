# 🩸 Blood Bank Management System

A comprehensive Flutter application for managing blood bank operations, donor management, and blood inventory tracking with advanced theme customization and cross-platform support.

## ✨ Features

### 🎨 **Advanced Theme System**
- **Multiple Theme Options**: Choose from various color schemes
- **Dynamic Theme Switching**: Change themes on-the-fly from any page
- **Consistent UI**: All pages respond to theme changes in real-time
- **Accessible Controls**: Theme toggle buttons on every page

### 👥 **User Management**
- **Multi-User Support**: Admin, Donor, and Receiver roles
- **Secure Authentication**: Password-protected login system
- **Session Management**: Persistent user sessions
- **Profile Management**: User profile customization

### 🩺 **Blood Bank Operations**
- **Blood Inventory Tracking**: Real-time blood stock monitoring
- **Donor Management**: Comprehensive donor information system
- **Blood Request System**: Efficient blood request processing
- **Availability Status**: Stock level indicators (Available, Low Stock, Out of Stock)

### 📱 **Modern UI/UX**
- **Responsive Design**: Optimized for all screen sizes
- **Material Design 3**: Latest Flutter design principles
- **Smooth Animations**: Engaging user interactions
- **Cross-Platform**: Works on Android, iOS, and Web

### 🔧 **Technical Features**
- **Cross-Platform Database**: SQLite for mobile, Web SQL for web
- **Real-time Updates**: Live data synchronization
- **Offline Support**: Works without internet connection
- **Performance Optimized**: Efficient data handling and UI rendering

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.16.0 or higher)
- Dart SDK (3.2.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/bloodbank.git
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

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**Web Build:**
```bash
flutter build web
```

## 📱 Screenshots

### Home Page
- Modern header with theme toggle
- Hero section with call-to-action
- Feature grid showcasing app capabilities

### Admin Dashboard
- User management interface
- Blood inventory overview
- Notification system
- Analytics dashboard

### Donor Portal
- Eligibility assessment
- Donation tracking
- Personal dashboard

### Receiver Dashboard
- Blood request system
- Availability checking
- Request tracking

### Blood Inventory
- Real-time stock levels
- Color-coded availability status
- Comprehensive blood group coverage

## 🎨 Theme Customization

The app features a sophisticated theme system with:

- **Primary Themes**: Multiple color schemes available
- **Dynamic Switching**: Change themes from any page
- **Consistent UI**: All components respond to theme changes
- **Accessibility**: High contrast and readable color combinations

### Available Themes
- **Classic Blue**: Professional medical theme
- **Nature Green**: Calming and natural
- **Sunset Orange**: Warm and inviting
- **Royal Purple**: Elegant and sophisticated
- **Crimson Red**: Bold and energetic

## 🏗️ Architecture

### Project Structure
```
lib/
├── core/           # Core functionality
├── features/       # Feature-specific modules
├── shared/         # Shared utilities and components
├── theme/          # Theme management system
├── services/       # Data and business logic
└── utils/          # Utility functions
```

### Key Components
- **ThemeProvider**: Manages app-wide theme state
- **DataService**: Handles data operations
- **SessionManager**: User session management
- **NavigationUtils**: App navigation utilities

## 🔧 Configuration

### Android Configuration
- **Minimum SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **NDK Version**: 25.1.8937393
- **Java Version**: 17

### Dependencies
- **Provider**: State management
- **SQLite**: Local database
- **Shared Preferences**: User settings
- **HTTP**: Web API communication

## 🚀 Recent Updates

### v2.1.0 - Theme System Overhaul
- ✨ Added theme toggle buttons to ALL pages
- 🎨 Complete theme system integration
- 📱 Fixed UI overflow issues
- 🚀 Improved responsive design
- 🔧 Fixed Gradle build issues
- 📦 Updated dependencies and configurations

### v2.0.0 - Major UI Overhaul
- 🎨 Advanced theme customization system
- 📊 Analytics dashboard
- 📱 QR code scanner
- 🌐 Cross-platform database support
- 📱 Modern Material Design 3 UI

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Open source community for various packages

## 📞 Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team
- Check the documentation

---

**Made with ❤️ using Flutter**

*Blood Bank Management System - Saving lives through technology*
