# 🔍 Blood Bank Management System - Debugging Guide

## 🚀 **Quick Debug Commands**

### **Start Debug Mode:**
```bash
flutter run -d chrome --debug
```

### **Hot Reload (while app is running):**
```bash
# Press 'R' in the terminal where Flutter is running
```

### **Hot Restart (while app is running):**
```bash
# Press 'r' in the terminal where Flutter is running
```

### **Check for Issues:**
```bash
flutter analyze
flutter doctor
```

## 📊 **What to Look For During Debug**

### **✅ Successful Startup Indicators:**

#### **1. Database Initialization:**
```
DataService: Web platform - initializing in-memory database
✅ Web database tables created
✅ Admin user created
✅ Donor user created
✅ Receiver user created
✅ Sample blood inventory created
✅ Web database initialized successfully
```

#### **2. Splash Screen:**
```
Splash screen: Initializing...
Splash screen: Starting animation...
🔄 Splash screen: Starting session check with timeout...
Splash screen: Checking user session...
Splash screen: Session data received: true
Splash screen: No session found, navigating to home
```

#### **3. Login Page:**
```
🔧 Initializing database for login page...
✅ Database initialized successfully for login
```

### **❌ Error Indicators to Watch For:**

#### **Database Errors:**
```
❌ Error initializing database: Unsupported operation: SQLite is not supported on web platforms
❌ Database initialization failed
❌ Authentication failed for email
```

#### **Navigation Errors:**
```
❌ Navigation failed
❌ Route not found
❌ Page loading error
```

#### **Session Errors:**
```
❌ Session data error
❌ User session not found
❌ Session validation failed
```

## 🔧 **Debugging Steps**

### **Step 1: Check Database Connectivity**
1. Open browser console (F12)
2. Look for database initialization messages
3. Verify web database is working

### **Step 2: Test Authentication**
1. Try logging in with test credentials:
   - **Admin**: admin@bloodbank.com / admin123
   - **Donor**: donor@bloodbank.com / donor123
   - **Receiver**: receiver@bloodbank.com / receiver123

### **Step 3: Check Page Navigation**
1. Verify splash screen loads correctly
2. Check login page appears
3. Test navigation after successful login

### **Step 4: Monitor Performance**
1. Check for any lag or delays
2. Monitor memory usage
3. Look for console errors

## 🎯 **Expected Debug Output**

### **Complete Successful Startup:**
```
Launching lib\main.dart on Chrome in debug mode...
Waiting for connection from debug service on Chrome...
This app is linked to the debug service: ws://127.0.0.1:XXXXX/XXXXX=/ws

DataService: Web platform - initializing in-memory database
✅ Web database tables created
✅ Admin user created
✅ Donor user created
✅ Receiver user created
✅ Sample blood inventory created
✅ Web database initialized successfully
DataService: Web database initialized successfully

Splash screen: Initializing...
Splash screen: Starting animation...
🔄 Splash screen: Starting session check with timeout...
Splash screen: Checking user session...
Splash screen: Session data received: true
Splash screen: No session found, navigating to home

🔧 Initializing database for login page...
✅ Database initialized successfully for login
```

### **Successful Login:**
```
🔧 Login button pressed
📝 Form validation starting...
✅ Form validation passed
📝 Login attempt for email: admin@bloodbank.com
✅ User authenticated: System Administrator (Admin)
User session saved: admin@bloodbank.com (ID: 1)
✅ Session saved successfully
🔄 Navigating to Admin page
```

## 🛠️ **Troubleshooting Common Issues**

### **Issue 1: Database Not Initializing**
**Symptoms:**
- "SQLite is not supported on web platforms" error
- Authentication fails

**Solution:**
- Check if `DataService.initializeDatabase()` is being called
- Verify web database service is working
- Clear browser cache and restart

### **Issue 2: Authentication Fails**
**Symptoms:**
- Login button doesn't work
- "Authentication failed" messages

**Solution:**
- Check if test users exist in database
- Verify password hashing is working
- Check console for authentication errors

### **Issue 3: Navigation Issues**
**Symptoms:**
- App stuck on splash screen
- Can't navigate to pages after login

**Solution:**
- Check route definitions in main.dart
- Verify page files exist
- Check for navigation errors in console

### **Issue 4: Performance Issues**
**Symptoms:**
- Slow loading
- Laggy interface
- High memory usage

**Solution:**
- Check for memory leaks
- Optimize database queries
- Reduce unnecessary re-renders

## 📱 **Testing Checklist**

### **✅ Database Tests:**
- [ ] Database initializes on startup
- [ ] Test users are created
- [ ] Authentication works for all user types
- [ ] Data persists across sessions

### **✅ UI Tests:**
- [ ] Splash screen displays correctly
- [ ] Login page loads properly
- [ ] Navigation works after login
- [ ] All pages are accessible

### **✅ Functionality Tests:**
- [ ] User login/logout works
- [ ] Session management works
- [ ] Data is saved correctly
- [ ] No console errors

### **✅ Performance Tests:**
- [ ] App loads quickly
- [ ] No memory leaks
- [ ] Smooth navigation
- [ ] Responsive interface

## 🔍 **Browser Console Commands**

### **Check Database Status:**
```javascript
// In browser console
console.log('Database status check');
```

### **Test Authentication:**
```javascript
// Test user data
console.log('Testing authentication...');
```

### **Monitor Network:**
```javascript
// Check for failed requests
console.log('Network status...');
```

## 📋 **Debug Log Levels**

### **Info Level (Default):**
- Database initialization
- User authentication
- Navigation events
- Session management

### **Warning Level:**
- Non-critical errors
- Performance warnings
- Deprecated features

### **Error Level:**
- Database failures
- Authentication errors
- Navigation failures
- Critical system errors

## 🎉 **Success Criteria**

The app is working correctly when:

1. **✅ Database initializes without errors**
2. **✅ All test users can log in**
3. **✅ Navigation works smoothly**
4. **✅ No console errors appear**
5. **✅ Data persists correctly**
6. **✅ Performance is acceptable**

## 🚨 **Emergency Debug Commands**

### **Reset Everything:**
```bash
flutter clean
flutter pub get
flutter run -d chrome --debug
```

### **Check Dependencies:**
```bash
flutter doctor -v
flutter pub deps
```

### **Analyze Code:**
```bash
flutter analyze
dart analyze
```

---

**Remember:** Always check the browser console (F12) for detailed error messages and debug information! 🔍
