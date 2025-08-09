
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  // Create a simple blood bank icon
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(1024, 1024);
  
  // Background
  final paint = Paint()..color = Colors.red[700]!;
  canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  
  // Blood drop
  final dropPaint = Paint()..color = Colors.red[900]!;
  final dropPath = Path();
  dropPath.moveTo(size.width / 2, size.height * 0.3);
  dropPath.quadraticBezierTo(
    size.width * 0.3, size.height * 0.4,
    size.width * 0.4, size.height * 0.6
  );
  dropPath.quadraticBezierTo(
    size.width * 0.45, size.height * 0.8,
    size.width * 0.5, size.height * 0.9
  );
  dropPath.quadraticBezierTo(
    size.width * 0.55, size.height * 0.8,
    size.width * 0.6, size.height * 0.6
  );
  dropPath.quadraticBezierTo(
    size.width * 0.7, size.height * 0.4,
    size.width * 0.5, size.height * 0.3
  );
  dropPath.close();
  canvas.drawPath(dropPath, dropPaint);
  
  // Cross symbol
  final crossPaint = Paint()
    ..color = Colors.white
    ..strokeWidth = size.width * 0.08
    ..strokeCap = StrokeCap.round;
  
  // Vertical line
  canvas.drawLine(
    Offset(size.width / 2, size.height * 0.35),
    Offset(size.width / 2, size.height * 0.65),
    crossPaint
  );
  
  // Horizontal line
  canvas.drawLine(
    Offset(size.width * 0.4, size.height / 2),
    Offset(size.width * 0.6, size.height / 2),
    crossPaint
  );
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();
  
  // Save the icon
  final file = File('assets/icons/bloodbank_icon.png');
  await file.writeAsBytes(bytes);
  
  print('✅ Blood bank icon generated successfully!');
  print('📁 Location: assets/icons/bloodbank_icon.png');
  print('📏 Size: 1024x1024 pixels');
} 