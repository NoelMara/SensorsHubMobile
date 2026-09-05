import 'dart:async';
import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../constants.dart';
import '../widgets/splash_view.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  Timer? _timeoutTimer;

  bool _pageLoaded = false;
  bool _hasLoadError = false;
  bool _showSplash = true;
  bool _showError = false;

  double _logoOpacity = 0;
  double _titleOpacity = 0;
  double _subtitleOpacity = 0;
  double _loadingOpacity = 0;

  String _loadingLabel = 'CONNECTING TO SERVER...';

  @override
  void initState() {
    super.initState();

    _setupWebView();
    _startSplashAnimation();
  }

  // ============================================================
  // WEBVIEW SETUP
  // ============================================================

  void _setupWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _onPageFinished();
          },
          onWebResourceError: (error) {
            _onWebResourceError(error);
          },
          onNavigationRequest: (request) {
            return _onNavigationRequest(request);
          },
        ),
      )
      ..loadRequest(Uri.parse(kUrl));

    // Android file upload support
    if (Platform.isAndroid) {
      final androidController =
          _controller.platform as AndroidWebViewController;

      androidController.setOnShowFileSelector(
        _androidFileSelector,
      );
    }
  }

  // ============================================================
  // ANDROID FILE UPLOAD
  // ============================================================

  Future<List<String>> _androidFileSelector(
  FileSelectorParams request,
) async {
  try {
    // Check what the website is requesting.
    final acceptTypes = request.acceptTypes
        .map((type) => type.toLowerCase().trim())
        .where((type) => type.isNotEmpty)
        .toList();

    debugPrint('WebView requested file types: $acceptTypes');

    FileType fileType = FileType.any;
    List<String> allowedExtensions = [];

    // IMAGE UPLOAD
    if (acceptTypes.any(
      (type) => type == 'image/*' || type.startsWith('image/'),
    )) {
      fileType = FileType.image;
    }

    // DOCUMENT UPLOAD
    else if (acceptTypes.any(
      (type) =>
          type == 'application/pdf' ||
          type == 'application/msword' ||
          type ==
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
          type == 'application/vnd.ms-powerpoint' ||
          type ==
              'application/vnd.openxmlformats-officedocument.presentationml.presentation' ||
          type == 'text/plain' ||
          type.endsWith('.pdf') ||
          type.endsWith('.doc') ||
          type.endsWith('.docx') ||
          type.endsWith('.ppt') ||
          type.endsWith('.pptx') ||
          type.endsWith('.txt'),
    )) {
      fileType = FileType.custom;

      allowedExtensions = [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'txt',
      ];
    }

    final files = await FilePicker.pickFiles(
      allowMultiple: request.mode == FileSelectorMode.openMultiple,
      type: fileType,
      allowedExtensions:
          fileType == FileType.custom ? allowedExtensions : null,
    );

    // User cancelled the file picker.
    if (files.isEmpty) {
      return [];
    }

    final paths = <String>[];

    for (final file in files) {
      if (file.path == null || file.path!.isEmpty) {
        continue;
      }

      final filePath = file.path!;

      // Android WebView needs a URI, not a raw filesystem path.
      final fileUri = Uri.file(filePath).toString();

      debugPrint('Selected file path: $filePath');
      debugPrint('WebView file URI: $fileUri');

      paths.add(fileUri);
    }

    return paths;
  } catch (e) {
    debugPrint('File picker error: $e');
    return [];
  }
}

  // ============================================================
  // PAGE LOADING
  // ============================================================

  void _onPageFinished() {
    if (_hasLoadError) return;

    _pageLoaded = true;

    _timeoutTimer?.cancel();

    _hideSplashAndShowWebView();
  }

  // ============================================================
  // WEB RESOURCE ERROR
  // ============================================================

  void _onWebResourceError(WebResourceError error) {
    if ((error.isForMainFrame ?? true) && !_pageLoaded) {
      _hasLoadError = true;

      _showConnectionError();
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  NavigationDecision _onNavigationRequest(
    NavigationRequest request,
  ) {
    final url = request.url.toLowerCase();

    final isDownloadable =
        url.endsWith('.pdf') ||
        url.endsWith('.doc') ||
        url.endsWith('.docx') ||
        url.contains('.pdf?') ||
        url.contains('.doc?') ||
        url.contains('.docx?');

    if (isDownloadable) {
      _openExternally(request.url);

      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  // ============================================================
  // OPEN EXTERNAL URL
  // ============================================================

  Future<void> _openExternally(String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Could not open URL: $e');
    }
  }

  // ============================================================
  // SPLASH ANIMATION
  // ============================================================

  void _startSplashAnimation() {
    setState(() {
      _logoOpacity = 1;
    });

    Future.delayed(
      const Duration(milliseconds: 400),
      () {
        if (mounted) {
          setState(() {
            _titleOpacity = 1;
          });
        }
      },
    );

    Future.delayed(
      const Duration(milliseconds: 800),
      () {
        if (mounted) {
          setState(() {
            _subtitleOpacity = 1;
          });
        }
      },
    );

    Future.delayed(
      const Duration(milliseconds: 1200),
      () {
        if (mounted) {
          setState(() {
            _loadingOpacity = 1;
          });
        }

        _startTimeoutTimer();
      },
    );
  }

  // ============================================================
  // TIMEOUT
  // ============================================================

  void _startTimeoutTimer() {
    _timeoutTimer = Timer(
      const Duration(milliseconds: kLoadTimeoutMs),
      () {
        if (!_pageLoaded) {
          _showConnectionError();
        }
      },
    );
  }

  // ============================================================
  // CONNECTION ERROR
  // ============================================================

  void _showConnectionError() {
    if (_pageLoaded || _showError) return;

    setState(() {
      _loadingOpacity = 0;
      _showError = true;
    });
  }

  // ============================================================
  // RETRY
  // ============================================================

  void _retryConnection() {
    _timeoutTimer?.cancel();

    _hasLoadError = false;
    _pageLoaded = false;

    setState(() {
      _showError = false;
      _loadingOpacity = 1;
      _loadingLabel = 'RECONNECTING...';
    });

    _controller.reload();

    _startTimeoutTimer();
  }

  // ============================================================
  // HIDE SPLASH
  // ============================================================

  void _hideSplashAndShowWebView() {
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (mounted) {
          setState(() {
            _showSplash = false;
          });
        }
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timeoutTimer?.cancel();

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Go back inside the website first
        if (await _controller.canGoBack()) {
          _controller.goBack();
        } else if (mounted) {
          // Exit the WebView screen
          Navigator.of(context).maybePop();
        }
      },

      child: Scaffold(
        backgroundColor: kDarkNavy,

        body: SafeArea(
          child: Stack(
            children: [
              // ==================================================
              // WEBVIEW
              // ==================================================

              AnimatedOpacity(
                opacity: _showSplash ? 0 : 1,
                duration: const Duration(milliseconds: 500),

                child: WebViewWidget(
                  controller: _controller,
                ),
              ),

              // ==================================================
              // SPLASH SCREEN
              // ==================================================

              if (_showSplash)
                SplashView(
                  logoOpacity: _logoOpacity,
                  titleOpacity: _titleOpacity,
                  subtitleOpacity: _subtitleOpacity,
                  loadingOpacity: _loadingOpacity,
                  loadingLabel: _loadingLabel,
                  showError: _showError,
                  onRetry: _retryConnection,
                ),
            ],
          ),
        ),
      ),
    );
  }
}