import 'package:flutter/material.dart';
import '../utils/AppTheme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isSecondary;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isSecondary
              ? null
              : const LinearGradient(
                  colors: [AppTheme.accentPurple, AppTheme.accentPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          border: isSecondary
              ? Border.all(color: AppTheme.borderSubtle, width: 1.5)
              : null,
          boxShadow: isSecondary
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.accentPurple.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
