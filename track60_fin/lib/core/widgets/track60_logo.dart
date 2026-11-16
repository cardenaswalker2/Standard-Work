import 'package:flutter/material.dart';

class Track60Logo extends StatelessWidget {
  final double size;
  final bool isDark;

  const Track60Logo({
    super.key,
    this.size = 36.0,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF002F6C), Color(0xFF0284C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF002F6C).withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.precision_manufacturing_rounded,
              color: Colors.white,
              size: size * 0.58,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'TRACK',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: size * 0.52,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white : const Color(0xFF002F6C),
                  ),
                ),
                Text(
                  '60',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: size * 0.52,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
            Text(
              'GRUPO DARNEL · STANDARD WORK',
              style: TextStyle(
                fontSize: size * 0.22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

