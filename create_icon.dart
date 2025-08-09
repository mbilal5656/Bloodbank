import 'dart:io';
import 'dart:math' as math;

void main() {
  print('🎨 Creating Blood Bank App Icon...');
  
  // Create a simple SVG icon that we can convert to PNG
  final svgContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <!-- Background circle -->
  <circle cx="512" cy="512" r="512" fill="#D32F2F"/>
  
  <!-- Blood drop -->
  <path d="M512 307.2 Q307.2 409.6 409.6 614.4 Q460.8 819.2 512 921.6 Q563.2 819.2 614.4 614.4 Q716.8 409.6 512 307.2 Z" fill="#B71C1C"/>
  
  <!-- Medical cross -->
  <rect x="460.8" y="358.4" width="102.4" height="307.2" fill="white" rx="20"/>
  <rect x="358.4" y="460.8" width="307.2" height="102.4" fill="white" rx="20"/>
</svg>
''';

  // Save SVG file
  final svgFile = File('assets/icons/bloodbank_icon.svg');
  svgFile.writeAsStringSync(svgContent);
  
  print('✅ SVG icon created at: assets/icons/bloodbank_icon.svg');
  print('📏 Size: 1024x1024 pixels');
  print('🎨 Colors: Red background with white medical cross');
  print('');
  print('To convert to PNG, you can:');
  print('1. Use an online SVG to PNG converter');
  print('2. Use Inkscape: inkscape -w 1024 -h 1024 bloodbank_icon.svg -o bloodbank_icon.png');
  print('3. Use ImageMagick: magick bloodbank_icon.svg bloodbank_icon.png');
} 