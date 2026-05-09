import 'package:flutter/material.dart';
import 'package:match_tracker/core/constants/app_colors.dart';

class LiveBadge extends StatefulWidget {
  final bool large;
  const LiveBadge({super.key, this.large = false});

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.large ? 13.0 : 10.0;
    final dotSize = widget.large ? 7.0 : 5.0;
    final hPad = widget.large ? 10.0 : 7.0;
    final vPad = widget.large ? 5.0 : 3.0;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: AppColors.live.withOpacity(0.15),
          border: Border.all(
            color: AppColors.live.withOpacity(_pulse.value),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: AppColors.live.withOpacity(_pulse.value),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.live.withOpacity(_pulse.value * 0.6),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'LIVE',
              style: TextStyle(
                color: AppColors.live,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
