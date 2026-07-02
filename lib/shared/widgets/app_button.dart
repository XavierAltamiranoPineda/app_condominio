import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum AppButtonVariant { filled, outlined, text }

/// Botón reutilizable con estados de carga, variantes y soporte de ID único
class AppButton extends StatelessWidget {
  final String id;
  final String label;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;
  final Color? color;
  final double? height;

  const AppButton({
    super.key,
    required this.id,
    required this.label,
    this.onPressed,
    this.isFullWidth = false,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.color,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final child = _buildChild(context);

    if (isFullWidth) {
      return SizedBox(
        key: Key(id),
        width: double.infinity,
        height: height ?? 52,
        child: _buildButton(child),
      );
    }

    return SizedBox(
      key: Key(id),
      height: height ?? 52,
      child: _buildButton(child),
    );
  }

  Widget _buildButton(Widget child) {
    switch (variant) {
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: color != null
              ? OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color!),
                )
              : null,
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: color != null
              ? TextButton.styleFrom(foregroundColor: color)
              : null,
          child: child,
        );
      case AppButtonVariant.filled:
      default:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: color != null
              ? ElevatedButton.styleFrom(backgroundColor: color)
              : null,
          child: child,
        );
    }
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
