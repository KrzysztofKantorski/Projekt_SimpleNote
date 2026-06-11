import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class CastomTermsFooter extends StatelessWidget{
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  const CastomTermsFooter({
    super.key,
    this.onTermsTap,
    this.onPrivacyTap,
  });
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF888888),
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'By clicking continue, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTermsTap,
          ),
          const TextSpan(text: '\nand '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
          ),
        ],
      ),
    );
  }


}