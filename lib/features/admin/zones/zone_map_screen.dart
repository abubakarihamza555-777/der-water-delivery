import 'package:flutter/material.dart';
import 'package:water_delivery_app/core/constants/app_colors.dart';
import 'package:water_delivery_app/core/widgets/custom_button.dart';

class ZoneMapScreen extends StatefulWidget {
  const ZoneMapScreen({super.key});

  @override
  State<ZoneMapScreen> createState() => _ZoneMapScreenState();
}

class _ZoneMapScreenState extends State<ZoneMapScreen> {
  bool _isDrawing = false;
  final List<Point> _points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Zone Map'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
              setState(() {
                if (_points.isNotEmpty) {
                  _points.removeLast();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _points.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Map area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greyLight),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 80,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Interactive Map',
                          style: TextStyle(color: AppColors.grey),
                        ),
                        const Text(
                          'Tap to add zone boundaries',
                          style: TextStyle(fontSize: 12, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                  // Draw points
                  CustomPaint(
                    painter: ZonePainter(_points),
                    size: Size.infinite,
                  ),
                  // Touch detection
                  GestureDetector(
                    onTapDown: (details) {
                      if (_isDrawing) {
                        setState(() {
                          _points.add(Point(details.localPosition.dx, details.localPosition.dy));
                        });
                      }
                    },
                    behavior: HitTestBehavior.translucent,
                  ),
                ],
              ),
            ),
          ),
          
          // Controls
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isDrawing = !_isDrawing;
                          });
                        },
                        icon: Icon(_isDrawing ? Icons.touch_app : Icons.edit),
                        label: Text(_isDrawing ? 'Drawing Mode Active' : 'Start Drawing'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDrawing ? Colors.green : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_points.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _points.clear();
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear All'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Save Zone',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Zone boundaries saved!')),
                            );
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                if (_points.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '${_points.length} points placed',
                      style: const TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Point {
  final double x;
  final double y;
  Point(this.x, this.y);
}

class ZonePainter extends CustomPainter {
  final List<Point> points;
  
  ZonePainter(this.points);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final fillPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(points[0].x, points[0].y);
    
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].x, points[i].y);
    }
    
    if (points.length > 2) {
      path.close();
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, paint);
    }
    
    // Draw points
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    
    for (var point in points) {
      canvas.drawCircle(Offset(point.x, point.y), 5, pointPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
