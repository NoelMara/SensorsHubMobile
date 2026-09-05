import 'package:flutter/material.dart';
import '../constants.dart';

// Shown inside the splash screen when the WebView fails to connect.
class ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('● ', style: TextStyle(color: kErrorRed, fontSize: 10)),
              const Text(
                'CONNECTION FAILED',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: kErrorRed,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 80),
            child: Text(
              "Couldn't reach the server. Check your connection.",
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextSecondary, fontSize: 11),
            ),
          ),
          const SizedBox(height: 26),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 13),
              decoration: BoxDecoration(
                color: kAccentCyan,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'RETRY',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: kRetryText,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}