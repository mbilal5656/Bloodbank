# Manual App Icon Replacement Guide

Since there are Flutter version compatibility issues with the icon generation scripts, here's how to manually replace your app icon:

## Method 1: Using Online Icon Generators (Recommended)

### Step 1: Create or Find Your Icon
1. Create a square image (1024x1024 pixels recommended)
2. Use a blood bank themed design (blood drop, medical cross, etc.)
3. Use colors like:
   - Background: #1A237E (dark blue)
   - Icon: #D32F2F (red) or white
   - Accent: #3949AB (medium blue)

### Step 2: Generate All Sizes
Use one of these online tools:
- **App Icon Generator**: https://appicon.co/
- **Make App Icon**: https://makeappicon.com/
- **Icon Kitchen**: https://icon.kitchen/

### Step 3: Download and Replace
1. Download the generated icon pack
2. Replace these files in your project:
   ```
   android/app/src/main/res/mipmap-mdpi/ic_launcher.png (48x48)
   android/app/src/main/res/mipmap-hdpi/ic_launcher.png (72x72)
   android/app/src/main/res/mipmap-xhdpi/ic_launcher.png (96x96)
   android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png (144x144)
   android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png (192x192)
   ```

## Method 2: Using flutter_launcher_icons Package

### Step 1: Prepare Your Icon
1. Create a square image (1024x1024 pixels)
2. Save it as `assets/icon/app_icon.png`

### Step 2: Generate Icons
Run these commands:
```bash
flutter pub run flutter_launcher_icons
```

### Step 3: Rebuild the App
```bash
flutter clean
flutter run
```

## Method 3: Quick Blood Bank Icon Design

If you want to create a simple blood bank icon:

### Design Elements:
- **Background**: Dark blue (#1A237E)
- **Blood Drop**: Red (#D32F2F)
- **Medical Cross**: White
- **Heart Symbol**: Red or white

### Icon Ideas:
1. **Blood Drop + Cross**: Red blood drop with white medical cross
2. **Heart + Cross**: Red heart with white medical cross
3. **Simple Blood Drop**: Red blood drop on blue background
4. **Medical Cross**: White cross on blue background

## Current Icon Location

Your current app icon files are located at:
```
android/app/src/main/res/mipmap-mdpi/ic_launcher.png
android/app/src/main/res/mipmap-hdpi/ic_launcher.png
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

## Quick Test

After replacing the icons:
1. Run `flutter clean`
2. Run `flutter run`
3. Check the app icon on your device/emulator

## Troubleshooting

### If icons don't update:
1. Run `flutter clean`
2. Delete the build folder: `rm -rf build/`
3. Run `flutter pub get`
4. Run `flutter run`

### If you get errors:
1. Make sure your image is square
2. Ensure it's a PNG file
3. Check that the image is at least 1024x1024 pixels
4. Verify the file path is correct

## Icon Design Tips

For a blood bank app, consider:
- **Colors**: Blue (#1A237E) and Red (#D32F2F)
- **Symbols**: Blood drops, medical crosses, hearts
- **Style**: Clean, simple, recognizable at small sizes
- **Background**: Solid color or simple gradient
- **Foreground**: Clear, bold icon

## Example Icon Specifications

**Recommended Design:**
- Background: Dark blue gradient (#1A237E to #3949AB)
- Main icon: Red blood drop (#D32F2F)
- Accent: White medical cross
- Size: 1024x1024 pixels
- Format: PNG with transparency support

This will create a professional, recognizable blood bank app icon that works well at all sizes. 