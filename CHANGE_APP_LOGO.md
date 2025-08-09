# How to Change App Logo

## Option 1: Using flutter_launcher_icons (Recommended)

### Step 1: Install the package
The package is already added to your `pubspec.yaml`. Run:
```bash
flutter pub get
```

### Step 2: Prepare your icon
1. Create a square image (1024x1024 pixels recommended)
2. Save it as `assets/icon/app_icon.png`
3. Make sure it's a PNG file

### Step 3: Generate icons
Run this command to generate all required icon sizes:
```bash
flutter pub run flutter_launcher_icons
```

### Step 4: Rebuild the app
```bash
flutter clean
flutter run
```

## Option 2: Manual Replacement

### Step 1: Create your icon
Create a square image and resize it to these sizes:
- 48x48 px (mdpi)
- 72x72 px (hdpi)
- 96x96 px (xhdpi)
- 144x144 px (xxhdpi)
- 192x192 px (xxxhdpi)

### Step 2: Replace existing icons
Replace the files in these directories:
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

### Step 3: Rebuild the app
```bash
flutter clean
flutter run
```

## Option 3: Online Icon Generators

Use these online tools to generate all required sizes:

1. **App Icon Generator**: https://appicon.co/
2. **Make App Icon**: https://makeappicon.com/
3. **Icon Kitchen**: https://icon.kitchen/

### Steps:
1. Upload your high-resolution image
2. Download the generated icon pack
3. Replace the files in the mipmap directories
4. Rebuild the app

## Option 4: Create a Simple Blood Bank Icon

If you want a quick blood bank themed icon, you can:

1. Use any blood drop or medical cross icon
2. Make it red (#D32F2F) on a blue background (#1A237E)
3. Ensure it's square and high resolution
4. Follow the steps above

## Current Icon Location

Your current app icon is located at:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`

## Configuration Files

The following files are already set up for you:
- `pubspec.yaml` - Contains flutter_launcher_icons dependency
- `flutter_launcher_icons.yaml` - Configuration for icon generation

## Troubleshooting

### If icons don't update:
1. Run `flutter clean`
2. Delete the build folder: `rm -rf build/`
3. Run `flutter pub get`
4. Run `flutter pub run flutter_launcher_icons`
5. Run `flutter run`

### If you get errors:
1. Make sure your image is square
2. Ensure it's a PNG file
3. Check that the image is at least 1024x1024 pixels
4. Verify the file path is correct

## Icon Design Tips

For a blood bank app, consider using:
- Blood drop symbols
- Medical crosses
- Heart symbols
- Blue and red color schemes
- Clean, simple designs that work at small sizes

## Quick Test

After changing the icon, you can verify it worked by:
1. Running the app
2. Looking at the app icon on your device/emulator
3. Checking the app launcher icon

The new icon should appear immediately after a clean rebuild. 