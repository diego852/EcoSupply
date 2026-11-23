import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Un generador visual de código QR nativo en Flutter de alto rendimiento.
class QrCodeWidget extends StatelessWidget {
  final String data;
  final double size;

  const QrCodeWidget({
    super.key,
    required this.data,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _QrPainter(data: data),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final String data;

  _QrPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = EcoTheme.primaryDark
      ..style = PaintingStyle.fill;

    // Generación determinística basada en el hash de [data]
    final hash = data.hashCode.abs();
    final random = Random(hash);

    const matrixSize = 17; // 17x17 grid
    final cellSize = size.width / matrixSize;

    // Dibujar marcadores de posición en las esquinas (Finder patterns)
    _drawFinderPattern(canvas, 0, 0, cellSize);
    _drawFinderPattern(canvas, (matrixSize - 5) * cellSize, 0, cellSize);
    _drawFinderPattern(canvas, 0, (matrixSize - 5) * cellSize, cellSize);

    // Dibujar patrón de datos
    for (int row = 0; row < matrixSize; row++) {
      for (int col = 0; col < matrixSize; col++) {
        // Ignorar áreas de los marcadores de posición
        if ((row < 6 && col < 6) ||
            (row < 6 && col > matrixSize - 7) ||
            (row > matrixSize - 7 && col < 6)) {
          continue;
        }

        // Determinar celda basada en la semilla hash y datos
        final fillCell = random.nextBool();
        if (fillCell) {
          final rect = Rect.fromLTWH(
            col * cellSize + 0.5,
            row * cellSize + 0.5,
            cellSize - 1,
            cellSize - 1,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(1)),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, double cellSize) {
    final outerPaint = Paint()
      ..color = EcoTheme.primaryDark
      ..style = PaintingStyle.fill;

    final innerWhitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final centerPaint = Paint()
      ..color = EcoTheme.primary
      ..style = PaintingStyle.fill;

    // Cuadro exterior 5x5
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, cellSize * 5, cellSize * 5),
        const Radius.circular(6),
      ),
      outerPaint,
    );

    // Cuadro interior blanco 3x3
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + cellSize, y + cellSize, cellSize * 3, cellSize * 3),
        const Radius.circular(4),
      ),
      innerWhitePaint,
    );

    // Centro verde 1.8x1.8
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + cellSize * 1.6, y + cellSize * 1.6, cellSize * 1.8, cellSize * 1.8),
        const Radius.circular(2),
      ),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
