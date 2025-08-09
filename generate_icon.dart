import 'package:flutter/material.dart';

void main() {
  runApp(const IconGeneratorApp());
}

class IconGeneratorApp extends StatelessWidget {
  const IconGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Bank Icon Generator',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const IconGeneratorPage(),
    );
  }
}

class IconGeneratorPage extends StatefulWidget {
  const IconGeneratorPage({super.key});

  @override
  State<IconGeneratorPage> createState() => _IconGeneratorPageState();
}

class _IconGeneratorPageState extends State<IconGeneratorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Bank Icon Generator'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: BloodBankIconPainter(),
                size: const Size(256, 256),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Blood Bank App Icon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This icon will be used for the Windows app',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BloodBankIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Background circle
    paint.color = Colors.red.shade700;
    canvas.drawCircle(center, radius, paint);

    // Inner circle
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.8, paint);

    // Blood drop shape
    final bloodDropPath = Path();
    final dropCenter = Offset(center.dx, center.dy - radius * 0.1);
    final dropWidth = radius * 0.6;
    final dropHeight = radius * 0.8;

    bloodDropPath.moveTo(dropCenter.dx, dropCenter.dy - dropHeight * 0.4);
    bloodDropPath.quadraticBezierTo(
      dropCenter.dx - dropWidth * 0.3,
      dropCenter.dy - dropHeight * 0.2,
      dropCenter.dx - dropWidth * 0.2,
      dropCenter.dy + dropHeight * 0.1,
    );
    bloodDropPath.quadraticBezierTo(
      dropCenter.dx - dropWidth * 0.1,
      dropCenter.dy + dropHeight * 0.3,
      dropCenter.dx,
      dropCenter.dy + dropHeight * 0.4,
    );
    bloodDropPath.quadraticBezierTo(
      dropCenter.dx + dropWidth * 0.1,
      dropCenter.dy + dropHeight * 0.3,
      dropCenter.dx + dropWidth * 0.2,
      dropCenter.dy + dropHeight * 0.1,
    );
    bloodDropPath.quadraticBezierTo(
      dropCenter.dx + dropWidth * 0.3,
      dropCenter.dy - dropHeight * 0.2,
      dropCenter.dx,
      dropCenter.dy - dropHeight * 0.4,
    );
    bloodDropPath.close();

    paint.color = Colors.red.shade600;
    canvas.drawPath(bloodDropPath, paint);

    // Cross symbol
    paint.color = Colors.white;
    paint.strokeWidth = radius * 0.15;
    paint.strokeCap = StrokeCap.round;

    final crossSize = radius * 0.4;
    canvas.drawLine(
      Offset(center.dx - crossSize, center.dy),
      Offset(center.dx + crossSize, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - crossSize),
      Offset(center.dx, center.dy + crossSize),
      paint,
    );

    // Text "BB" for Blood Bank
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'BB',
        style: TextStyle(
          color: Colors.red.shade700,
          fontSize: radius * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius * 0.3,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 