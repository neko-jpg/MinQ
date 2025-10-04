import 'package:flutter/material.dart';

/// リトライUI
class RetryUI extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final bool isLoading;

  const RetryUI({
    super.key,
    this.message,
    required this.onRetry,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'サーバ�Eへの接続に失敗しました',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('再試衁E),
            ),
        ],
      ),
    );
  }
}

/// 自動リトライウィジェチE��
class AutoRetryWidget extends StatefulWidget {
  final Future<void> Function() onRetry;
  final Widget Function(BuildContext, AsyncSnapshot) builder;
  final int maxRetries;
  final Duration retryDelay;

  const AutoRetryWidget({
    super.key,
    required this.onRetry,
    required this.builder,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  @override
  State<AutoRetryWidget> createState() => _AutoRetryWidgetState();
}

class _AutoRetryWidgetState extends State<AutoRetryWidget> {
  int _retryCount = 0;
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.onRetry(),
      builder: (context, snapshot) {
        if (snapshot.hasError && _retryCount < widget.maxRetries) {
          _scheduleRetry();
        }
        return widget.builder(context, snapshot);
      },
    );
  }

  void _scheduleRetry() {
    if (_isRetrying) return;

    _isRetrying = true;
    Future.delayed(widget.retryDelay, () {
      if (mounted) {
        setState(() {
          _retryCount++;
          _isRetrying = false;
        });
      }
    });
  }
}
