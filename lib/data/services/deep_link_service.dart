import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uni_links/uni_links.dart';

/// Bridges platform deep links into a broadcast stream that the UI can observe.
class DeepLinkService {
  DeepLinkService();

  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();
  StreamSubscription<Uri?>? _subscription;
  bool _initialized = false;

  /// A stream of incoming deep links.
  ///
  /// The initial link (if available) is emitted before any subsequent updates.
  Stream<Uri> get linkStream {
    _ensureInitialized();
    return _controller.stream;
  }

  void _ensureInitialized() {
    if (_initialized) {
      return;
    }
    _initialized = true;

    unawaited(_emitInitialUri());
    _subscription = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _controller.add(uri);
        }
      },
      onError: (Object error) {
        debugPrint('Failed to parse incoming deep link: $error');
      },
    );
  }

  Future<void> _emitInitialUri() async {
    try {
      final Uri? initialUri = await getInitialUri();
      if (initialUri != null) {
        _controller.add(initialUri);
      }
    } catch (error) {
      debugPrint('Failed to obtain initial deep link: $error');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
