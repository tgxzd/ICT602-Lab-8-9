import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math' as math;

class AccelerometerScreen extends StatefulWidget {
  const AccelerometerScreen({super.key});

  @override
  State<AccelerometerScreen> createState() => _AccelerometerScreenState();
}

class _AccelerometerScreenState extends State<AccelerometerScreen> {
  final List<StreamSubscription<dynamic>> _streamSubscriptions = [];
  AccelerometerEvent _accelerometerEvent = AccelerometerEvent(0, 0, 0);
  UserAccelerometerEvent _userAccelerometerEvent = UserAccelerometerEvent(0, 0, 0);
  GyroscopeEvent _gyroscopeEvent = GyroscopeEvent(0, 0, 0);

  // For tracking max values
  double _maxAcceleration = 0;
  double _currentAcceleration = 0;

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      accelerometerEvents.listen((AccelerometerEvent event) {
        setState(() {
          _accelerometerEvent = event;
          _currentAcceleration = math.sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );
          if (_currentAcceleration > _maxAcceleration) {
            _maxAcceleration = _currentAcceleration;
          }
        });
      }),
    );

    _streamSubscriptions.add(
      userAccelerometerEvents.listen((UserAccelerometerEvent event) {
        setState(() {
          _userAccelerometerEvent = event;
        });
      }),
    );

    _streamSubscriptions.add(
      gyroscopeEvents.listen((GyroscopeEvent event) {
        setState(() {
          _gyroscopeEvent = event;
        });
      }),
    );
  }

  @override
  void dispose() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  String _formatDouble(double value) {
    return value.toStringAsFixed(2);
  }

  Widget _buildAccelerationCard(String title, double x, double y, double z) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('X: ${_formatDouble(x)} m/s²'),
                    Text('Y: ${_formatDouble(y)} m/s²'),
                    Text('Z: ${_formatDouble(z)} m/s²'),
                  ],
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: CustomPaint(
                    painter: AccelerometerPainter(x, y),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accelerometer'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Total acceleration card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Total Acceleration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatDouble(_currentAcceleration)} m/s²',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Max: ${_formatDouble(_maxAcceleration)} m/s²',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Accelerometer data
            _buildAccelerationCard(
              'Accelerometer (with gravity)',
              _accelerometerEvent.x,
              _accelerometerEvent.y,
              _accelerometerEvent.z,
            ),

            // User accelerometer data
            _buildAccelerationCard(
              'User Accelerometer (without gravity)',
              _userAccelerometerEvent.x,
              _userAccelerometerEvent.y,
              _userAccelerometerEvent.z,
            ),

            // Gyroscope data
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gyroscope',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('X: ${_formatDouble(_gyroscopeEvent.x)} rad/s'),
                    Text('Y: ${_formatDouble(_gyroscopeEvent.y)} rad/s'),
                    Text('Z: ${_formatDouble(_gyroscopeEvent.z)} rad/s'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccelerometerPainter extends CustomPainter {
  final double x;
  final double y;

  AccelerometerPainter(this.x, this.y);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 2, backgroundPaint);

    // Draw crosshair
    final crosshairPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      crosshairPaint,
    );

    // Draw dot representing acceleration
    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Scale and clamp the acceleration values
    final scale = 5.0;
    final clampedX = x.clamp(-scale, scale) / scale;
    final clampedY = y.clamp(-scale, scale) / scale;

    final dotPosition = Offset(
      center.dx + clampedX * (radius - 8),
      center.dy - clampedY * (radius - 8),
    );
    canvas.drawCircle(dotPosition, 8, dotPaint);
  }

  @override
  bool shouldRepaint(AccelerometerPainter oldDelegate) {
    return x != oldDelegate.x || y != oldDelegate.y;
  }
} 