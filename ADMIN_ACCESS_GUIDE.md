# Admin Access Guide

## Problem
The admin page cannot be accessed due to authentication or user setup issues.

## Solution

### Method 1: Use the Admin Access Helper (Recommended)

1. **Open the app** and go to the home page
2. **Click the "Admin Access Helper" button** (orange button) or the admin icon in the app bar
3. **Run the diagnostic** to check your current setup
4. **Click "Fix Access"** to automatically:
   - Create the default admin user if it doesn't exist
   - Log you in as admin
   - Navigate to the admin panel

### Method 2: Manual Login

If the helper doesn't work, you can manually login with these credentials:

**Default Admin Credentials:**
- **Email:** `admin@bloodbank.com`
- **Password:** `admin123`

### Method 3: Create Admin User Programmatically

If you need to create an admin user manually, you can use the diagnostic tool which will:

1. Check if the database is properly initialized
2. Verify if an admin user exists
3. Create the default admin user if needed
4. Log you in automatically

## Troubleshooting

### Common Issues:

1. **Database not initialized**
   - The helper will automatically initialize the database
   - Check console logs for database errors

2. **Admin user doesn't exist**
   - The helper will create the default admin user
   - Default user: `admin@bloodbank.com` / `admin123`

3. **Session issues**
   - The helper will clear and recreate the session
   - This ensures proper authentication

4. **Permission issues**
   - Make sure you're running the app with proper permissions
   - Check if the database file is accessible

### Debug Information:

The diagnostic tool will show you:
- ✅ Database initialization status
- ✅ Admin user existence
- ✅ Current login status
- ✅ User type information

## Default Admin User Details

When created, the default admin user has these properties:
- **Name:** System Administrator
- **Email:** admin@bloodbank.com
- **Password:** admin123
- **User Type:** Admin
- **Status:** Active

## Admin Panel Features

Once you have access to the admin panel, you can:
- Manage all users (Donors, Receivers, Admins)
- View and manage blood inventory
- Send notifications to users
- Monitor system activity
- Add new users
- Edit user information
- Toggle user status (active/inactive)

## Security Notes

- Change the default admin password after first login
- The default password is stored in plain text for development purposes
- In production, use proper password hashing
- Consider implementing role-based access control

## Support

If you continue to have issues:
1. Check the console logs for error messages
2. Verify the database file exists and is accessible
3. Try clearing the app data and restarting
4. Use the diagnostic tool to identify specific issues 