import 'package:flutter/material.dart';
import '../constants.dart';
import 'error_view.dart';

// Loading and connection-error overlay for the WebView.
class SplashView extends StatelessWidget {
  final double logoOpacity;
  final double titleOpacity;
  final double subtitleOpacity;
  final double loadingOpacity;
  final String loadingLabel;
  final bool showError;
  final VoidCallback onRetry;

  const SplashView({
    super.key,
    required this.logoOpacity,
    required this.titleOpacity,
    required this.subtitleOpacity,
    required this.loadingOpacity,
    required this.loadingLabel,
    required this.showError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDarkNavy.withValues(alpha: 0.94),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSlide(
              offset: logoOpacity == 1 ? Offset.zero : const Offset(0, -0.6),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: logoOpacity,
                duration: const Duration(milliseconds: 600),
                child: Image.asset(
                  'assets/images/sensorshub_logo.png',
                  width: 120,
                  height: 120,
                ),
              ),
            ),
            const SizedBox(height: 20),

            AnimatedOpacity(
              opacity: titleOpacity,
              duration: const Duration(milliseconds: 600),
              child: const Text(
                'SENSORSHUB',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.8,
                  color: kAccentCyan,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(height: 28),

            if (!showError)
              AnimatedOpacity(
                opacity: loadingOpacity,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(kAccentCyan),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'LOADING SENSORS HUB',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                        color: kTextTertiary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            if (showError) ErrorView(onRetry: onRetry),
          ],
        ),
      ),
    );
  }
}
