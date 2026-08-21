import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GradientHeader extends StatelessWidget {
  final double height;
  final Widget? child;

  const GradientHeader({
    super.key,
    this.height = 120,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
      ),
      child: child,
    );
  }
}