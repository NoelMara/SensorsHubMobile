import 'package:flutter/material.dart';
import '../constants.dart';
import 'error_view.dart';

// The full splash screen: logo, title, subtitle, progress bar / error state.
// All the fade-in animations are controlled from outside via the opacity values.
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
      color: kDarkNavy,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo: fades in and slides down slightly
            AnimatedSlide(
              offset: logoOpacity == 1 ? Offset.zero : const Offset(0, -0.6),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: logoOpacity,
                duration: const Duration(milliseconds: 600),
                child: Image.asset(
                  'assets/images/sensorshub_logo.png',
                  width: 175,
                  height: 175,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Title: "SENSORSHUB"
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
            const SizedBox(height: 12),

            // Subtitle tagline
            AnimatedOpacity(
              opacity: subtitleOpacity,
              duration: const Duration(milliseconds: 600),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: Text(
                  'Learn Sensors. Build Projects. Share Ideas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextSecondary, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Either the loading bar, or the error view — never both
            if (!showError)
              AnimatedOpacity(
                opacity: loadingOpacity,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        width: 130,
                        height: 5,
                        child: LinearProgressIndicator(
                          backgroundColor: const Color(0xFF0C1621),
                          valueColor: const AlwaysStoppedAnimation(kAccentCyan),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loadingLabel,
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