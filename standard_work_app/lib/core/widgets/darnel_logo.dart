import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Logotipo oficial de Darnel Group recreado con fidelidad al HTML original:
/// Fondo blanco con bordes redondeados y texto tipográfico estilizado azul oscuro/secundario.
class DarnelLogoWidget extends StatelessWidget {
  final double height;
  final bool compact;

  const DarnelLogoWidget({
    super.key,
    this.height = 34,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 9 : 12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'DARNEL',
            style: TextStyle(
              color: AppColors.azul2,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 13 : 17,
              letterSpacing: 1.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'GROUP',
            style: TextStyle(
              color: AppColors.azul,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 8 : 10,
              letterSpacing: 3.5,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
