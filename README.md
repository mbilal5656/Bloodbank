# 🩸 Blood Bank Management System

A modern, comprehensive Flutter application for managing blood bank operations, donor registration, blood inventory tracking, and analytics with beautiful theme customization.

## 🚀 Latest Updates (v2.0.0)

### ✨ New Features Added
- **🎨 Theme Customization System** - 6 beautiful themes with real-time switching
- **📊 Advanced Analytics Dashboard** - Comprehensive data visualization and insights
- **📱 QR Code Scanner System** - Blood bag and donor tracking simulation
- **🔍 Advanced Search & Filter** - Powerful data querying across all modules
- **🌐 Cross-Platform Database** - Hybrid SQLite/In-memory for web and mobile
- **🎨 Modern UI/UX** - Contemporary design with animations and responsive layout
- **📱 Enhanced Home Page** - Dual-mode design for guests and logged-in users
- **🎯 Theme-Aware Components** - All pages adapt to selected color themes

### 🎨 Available Themes
- **🩸 Blood Red** - Professional medical aesthetic
- **🌊 Ocean Blue** - Calming and trustworthy
- **🌲 Forest Green** - Natural and eco-friendly
- **👑 Royal Purple** - Elegant and sophisticated
- **🌅 Sunset Orange** - Warm and energetic
- **🌙 Midnight Black** - Modern and minimalist

### 📊 Analytics Features
- **User Statistics** - Total users, active donors, receivers
- **Blood Inventory Analytics** - Stock levels, availability trends
- **Donation Analytics** - Growth rates, completion statistics
- **Request Analytics** - Demand patterns, fulfillment rates
- **System Health** - Database status, performance metrics

### 🔍 Search & Filter System
- **Multi-Category Search** - Blood inventory, donors, receivers, donations, requests
- **Advanced Filtering** - Blood group, status, user type filters
- **Real-time Results** - Instant search with detailed views
- **Export Capabilities** - Data export and reporting

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
├── main.dart                      # Application entry point with theme integration
├── splash_screen.dart             # Splash screen with 2025 branding
├── home_page.dart                 # Modern home page with theme selector
├── login_page.dart                # Classic login interface
├── signup_page.dart               # User registration
├── admin_page.dart                # Admin dashboard with new features
├── donor_page.dart                # Donor management
├── receiver_page.dart             # Receiver management
├── profile_page.dart              # User profile
├── contact_page.dart              # Contact information
├── settings_page.dart             # App settings with theme options
├── forgot_password_page.dart      # Password recovery
├── blood_inventory_page.dart      # Theme-aware blood inventory
├── notification_management_page.dart # Notification system
├── analytics_dashboard.dart       # NEW: Advanced analytics
├── qr_code_scanner.dart           # NEW: QR scanner system
├── search_filter_page.dart        # NEW: Search & filter system
├── theme_selection_page.dart      # NEW: Theme selection UI
├── theme_preview_widget.dart      # NEW: Theme preview component
├── db_helper.dart                 # SQLite database operations
├── session_manager.dart           # Session management
├── notification_helper.dart       # Notification handling
├── theme_manager.dart             # NEW: Theme management system
├── services/
│   ├── data_service.dart          # NEW: Platform-aware data service
│   └── web_database_service.dart  # NEW: Web database implementation
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

### 🎨 Theme Customization
- **6 Beautiful Themes** - Choose from professional color schemes
- **Real-time Switching** - Instant theme changes with persistence
- **Theme-Aware Components** - All UI elements adapt to selected theme
- **Cross-Session Persistence** - Theme choice saved across app restarts

### 📊 Advanced Analytics Dashboard
- **User Statistics** - Total users, user distribution, growth trends
- **Blood Inventory Analytics** - Stock levels, critical alerts, availability
- **Donation Analytics** - Donation rates, completion statistics, trends
- **Request Analytics** - Demand patterns, fulfillment rates, blood type analysis
- **System Health** - Database status, performance metrics, system overview

### 📱 QR Code Scanner System
- **Dual-Mode Scanner** - Blood bag tracking and donor identification
- **Simulated Scanning** - Realistic scanning experience for testing
- **Detailed Information** - Comprehensive data display for scanned items
- **Integration Ready** - Prepared for real camera integration

### 🔍 Advanced Search & Filter
- **Multi-Category Search** - Search across all data types
- **Advanced Filters** - Blood group, status, user type filtering
- **Real-time Results** - Instant search with detailed views
- **Export Capabilities** - Data export and reporting features

### 🌐 Cross-Platform Database
- **Hybrid Architecture** - SQLite for mobile/desktop, in-memory for web
- **Platform Detection** - Automatic database selection based on platform
- **Data Persistence** - Session-based storage with initialization flags
- **Seamless Migration** - Easy switching between platforms

### 👥 User Management
- **Role-based Access** - Admin, Donor, Receiver with specific permissions
- **Profile Management** - Comprehensive user profiles and settings
- **Session Management** - Secure session handling with persistence
- **Authentication** - Secure login with password hashing

### 🩸 Blood Inventory
- **Real-time Tracking** - Live blood stock monitoring
- **Blood Type Management** - All blood types with availability status
- **Critical Alerts** - Low stock and out-of-stock notifications
- **Theme Integration** - Beautiful, theme-aware inventory display

### 🔔 Notification System
- **Real-time Notifications** - Instant alerts and updates
- **Priority Management** - High, medium, low priority notifications
- **User-specific Alerts** - Personalized notification delivery
- **System Integration** - Seamless integration with all modules

## 🎨 Theme System

### Available Themes
1. **🩸 Blood Red** - Professional medical look with red accents
2. **🌊 Ocean Blue** - Calming blue tones for trust and reliability
3. **🌲 Forest Green** - Natural green for eco-friendly feel
4. **👑 Royal Purple** - Elegant purple for sophistication
5. **🌅 Sunset Orange** - Warm orange for energy and positivity
6. **🌙 Midnight Black** - Modern black for minimalist design

### How to Change Themes
1. **From Home Page**: Click the palette icon 🎨 in the header
2. **From Settings**: Navigate to Settings → App Theme
3. **From Admin Menu**: Use the three-dots menu → Change Theme

## 📱 Platform Support

### ✅ Fully Supported
- **Android**: Full support with device and emulator configurations
- **iOS**: Device and simulator support
- **Web**: Chrome, Edge, Firefox, and Web Server support
- **Desktop**: Windows, macOS, and Linux support

### 🌐 Web-Specific Features
- **In-Memory Database** - Fast, session-based data storage
- **Responsive Design** - Optimized for all screen sizes
- **Theme Persistence** - Theme choices saved in browser storage
- **Real-time Updates** - Instant UI updates without page refresh

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Test Theme System
1. Launch the app
2. Click the palette icon on home page
3. Try different themes
4. Verify theme persistence across app restarts

### Test Analytics Dashboard
1. Login as admin
2. Navigate to Analytics Dashboard
3. Verify all statistics are displayed correctly
4. Test data visualization components

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
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter best practices
- Maintain theme compatibility
- Test on multiple platforms
- Update documentation for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue on GitHub
- Contact: mbilalpk56@gmail.com
- Check the documentation in the `/docs` folder

## 🔄 Version History

- **v2.0.0** - Major update with theme system, analytics dashboard, QR scanner, search functionality
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

## 🎯 Roadmap

### Upcoming Features
- **🔐 Biometric Authentication** - Fingerprint and face recognition
- **📊 Advanced Reporting** - PDF reports and data export
- **🌍 Multi-language Support** - Internationalization
- **📱 Push Notifications** - Real-time push notifications
- **🔗 API Integration** - RESTful API for external systems
- **📈 Machine Learning** - Predictive analytics for blood demand

### Planned Improvements
- **Performance Optimization** - Faster loading and better responsiveness
- **Enhanced Security** - Additional security measures
- **Accessibility** - Better support for users with disabilities
- **Testing Coverage** - Comprehensive unit and integration tests

---

## ⚠️ Important Notes

- **Educational Purpose**: This application is designed for educational and demonstration purposes
- **Production Use**: For production use, implement additional security measures and comply with healthcare regulations
- **Data Privacy**: Ensure compliance with local data protection laws
- **Healthcare Regulations**: Follow applicable healthcare and medical device regulations

## 🌟 Star the Repository

If you find this project helpful, please give it a ⭐ star on GitHub!

---

**Built with ❤️ using Flutter**
