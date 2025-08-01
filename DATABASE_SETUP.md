# Blood Bank Database Setup

## Database Configuration

The Blood Bank application is configured with SQLite database version 4, which includes the following features:

### Database Version: 4
- **Location**: `lib/db_helper.dart`
- **Version Constant**: `_databaseVersion = 4`
- **Platform Support**: Android, iOS, Windows, Linux, macOS
- **Web Support**: Not supported (SQLite limitation)

### Database Tables

1. **users** - User management
   - id, name, email, password, userType, bloodGroup, age, contactNumber, address, isActive, lastLogin, createdAt, updatedAt

2. **blood_inventory** - Blood stock management
   - id, bloodGroup, quantity, reservedQuantity, status, lastUpdated, createdBy, notes

3. **donations** - Blood donation records
   - id, donorId, bloodGroup, quantity, donationDate, status, notes, createdBy

4. **blood_requests** - Blood request management
   - id, requesterId, bloodGroup, quantity, urgency, requestDate, status, notes, createdBy

5. **notifications** - User notifications
   - id, userId, title, message, type, isRead, createdAt

6. **user_sessions** - User session management
   - id, userId, sessionToken, expiresAt, createdAt

7. **audit_log** - System audit trail
   - id, userId, action, tableName, recordId, oldValues, newValues, timestamp, ipAddress, userAgent

### Database Initialization

The database is automatically initialized when the app starts:

1. **Splash Screen**: Database verification occurs during app startup
2. **Factory Initialization**: Platform-specific database factory setup
3. **Schema Creation**: Tables are created with proper relationships
4. **Default Data**: Admin user and sample blood inventory are inserted

### Database Verification

A verification utility is available at `lib/utils/database_verification.dart` that:
- Checks database connection
- Verifies table structure
- Tests basic operations
- Provides detailed status reports

### Cleanup Performed

The following unnecessary files were removed:
- `unused.xml`
- `AndroidDomInspection.xml`
- `HtmlRequiredLangAttribute.xml`
- `AndroidUnknownAttribute.xml`
- `AndroidLintPropertyEscape.xml`
- `SpellCheckingInspection.xml`
- `IgnoreFileDuplicateEntry.xml`
- `HtmlUnknownTarget.xml`
- `h origin main`
- `coverage/` directory
- `build/` directory (cleaned with `flutter clean`)

### Default Admin User

The system creates a default admin user:
- **Email**: admin@bloodbank.com
- **Password**: admin123
- **User Type**: Admin
- **Status**: Active

### Database Operations

The database helper provides comprehensive CRUD operations for:
- User management
- Blood inventory management
- Donation tracking
- Blood request processing
- Notification system
- Session management
- Audit logging

### Security Features

- Password hashing using SHA-256
- Session management with expiry
- Audit logging for all operations
- Soft delete for user accounts

### Migration Support

The database supports version upgrades:
- Automatic schema migration
- Data preservation during upgrades
- Backward compatibility

## Testing the Database

To test the database connection:

1. Run the app: `flutter run`
2. Check console logs for database initialization messages
3. Verify admin user login: admin@bloodbank.com / admin123
4. Test blood inventory operations
5. Verify audit logging functionality

## Troubleshooting

If database issues occur:

1. **Reset Database**: Use `DatabaseVerification.resetDatabase()`
2. **Check Logs**: Look for database initialization messages
3. **Verify Permissions**: Ensure app has storage permissions
4. **Platform Support**: Verify platform compatibility

## File Structure

```
lib/
├── db_helper.dart              # Main database helper
├── utils/
│   └── database_verification.dart  # Database verification utility
└── splash_screen.dart          # Database initialization on startup
```

The database is now properly configured and linked with version 4, providing a robust foundation for the Blood Bank management system. 