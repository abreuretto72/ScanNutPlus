import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';

class TutorialSpeechBubble extends StatelessWidget {
  final String title;
  final String description;
  final ContentAlign align;
  final VoidCallback? onFinish;
  final String? finishText;

  const TutorialSpeechBubble({
    Key? key,
    required this.title,
    required this.description,
    this.align = ContentAlign.bottom,
    this.onFinish,
    this.finishText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Bubble Container properties
    final bubbleDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.petPrimary.withValues(alpha: 0.3),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );

    final isTop = align == ContentAlign.top; // Tail at bottom of pop-up

    final bubbleMain = Container(
      decoration: bubbleDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets, color: AppColors.petPrimary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.petText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          if (onFinish != null && finishText != null) ...[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.petPrimary,
                  foregroundColor: AppColors.petText,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.petText, width: 1.5),
                  ),
                  elevation: 0,
                ),
                onPressed: onFinish,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  finishText!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ]
        ],
      ),
    );

    // The little tail logic
    Widget tail = CustomPaint(
      size: const Size(24, 16),
      painter: _BubbleTailPainter(isTop: isTop, color: Colors.white),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: isTop ? [bubbleMain, tail] : [tail, bubbleMain],
    );
  }
}

// Emulates ContentAlign enum from tutorial_coach_mark so we don't strictly couple it too deeply
enum ContentAlign { top, bottom, left, right, custom }

class _BubbleTailPainter extends CustomPainter {
  final bool isTop;
  final Color color;

  _BubbleTailPainter({required this.isTop, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isTop) {
      // Pointing downwards
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    } else {
      // Pointing upwards
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
