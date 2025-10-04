import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Bridges platform deep links into a broadcast stream that the UI can observe.
class DeepLinkService {
  DeepLinkService() {
    _init();
  }

  final _appLinks = AppLinks();
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();
  StreamSubscription<Uri>? _subscription;

  /// A stream of incoming deep links.
  Stream<Uri> get linkStream => _controller.stream;

  Future<void> _init() async {
    // Get the initial link
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _controller.add(initialLink);
    }

    // Listen for further links
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      _controller.add(uri);
    }, onError: (Object err, StackTrace stack) {
      debugPrint('Failed to handle deep link: $err');
    },);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}