import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButton extends StatelessWidget {
  final String icon;
  final IconData iconData; // Fallback
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.icon,
    required this.iconData,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              )
            else
              _buildIcon(),
            if (!isLoading) ...[
              const SizedBox(width: 8),
              Text(text),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    // Try to use SVG first, fallback to IconData
    try {
      return SvgPicture.asset(
        icon,
        width: 20,
        height: 20,
      );
    } catch (e) {
      return Icon(
        iconData,
        size: 20,
      );
    }
  }
}