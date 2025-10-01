import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

typedef AsyncCallback = Future<void> Function();

mixin AsyncActionState<T extends StatefulWidget> on State<T> {
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  @protected
  Future<void> runGuarded(AsyncCallback action) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

class MinqPrimaryButton extends StatefulWidget {
  const MinqPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final AsyncCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  State<MinqPrimaryButton> createState() => _MinqPrimaryButtonState();
}

class _MinqPrimaryButtonState extends State<MinqPrimaryButton>
    with AsyncActionState<MinqPrimaryButton> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bool disabled = widget.onPressed == null || isProcessing;

    Widget buildContent() {
      if (isProcessing) {
        return SizedBox(
          key: const ValueKey<String>('progress'),
          height: tokens.spacing(6),
          width: tokens.spacing(6),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(tokens.surface),
          ),
        );
      }

      final bool hasIcon = widget.icon != null;
      return Row(
        key: const ValueKey<String>('label'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (hasIcon) ...<Widget>[
            Icon(widget.icon, size: tokens.spacing(6)),
            SizedBox(width: tokens.spacing(2)),
          ],
          Flexible(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: tokens.titleSmall.copyWith(color: tokens.surface),
            ),
          ),
        ],
      );
    }

    final button = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.brandPrimary,
        foregroundColor: tokens.surface,
        minimumSize: Size.fromHeight(tokens.spacing(14)),
        padding: EdgeInsets.symmetric(horizontal: tokens.spacing(6)),
        shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
        textStyle: tokens.titleSmall,
      ),
      onPressed: disabled
          ? null
          : () => runGuarded(() async {
                await widget.onPressed!();
              }),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: buildContent(),
      ),
    );

    if (widget.expand) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

class MinqSecondaryButton extends StatefulWidget {
  const MinqSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final AsyncCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  State<MinqSecondaryButton> createState() => _MinqSecondaryButtonState();
}

class _MinqSecondaryButtonState extends State<MinqSecondaryButton>
    with AsyncActionState<MinqSecondaryButton> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bool disabled = widget.onPressed == null || isProcessing;

    Widget buildContent() {
      if (isProcessing) {
        return SizedBox(
          key: const ValueKey<String>('progress'),
          height: tokens.spacing(6),
          width: tokens.spacing(6),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(tokens.textPrimary),
          ),
        );
      }

      final bool hasIcon = widget.icon != null;
      return Row(
        key: const ValueKey<String>('label'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (hasIcon) ...<Widget>[
            Icon(widget.icon, size: tokens.spacing(6)),
            SizedBox(width: tokens.spacing(2)),
          ],
          Flexible(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
            ),
          ),
        ],
      );
    }

    final button = OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: tokens.border),
        backgroundColor: tokens.surface,
        foregroundColor: tokens.textPrimary,
        minimumSize: Size.fromHeight(tokens.spacing(14)),
        padding: EdgeInsets.symmetric(horizontal: tokens.spacing(6)),
        shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
        textStyle: tokens.titleSmall,
      ),
      onPressed: disabled
          ? null
          : () => runGuarded(() async {
                await widget.onPressed!();
              }),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: buildContent(),
      ),
    );

    if (widget.expand) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

class MinqTextButton extends StatelessWidget {
  const MinqTextButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: tokens.textMuted,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing(4),
          vertical: tokens.spacing(3),
        ),
        shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
        textStyle: tokens.titleSmall,
      ),
      child: Text(label),
    );
  }
}

class MinqIconButton extends StatelessWidget {
  const MinqIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 24.0,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return IconButton(
      icon: Icon(icon, size: size, color: color ?? tokens.textPrimary),
      onPressed: onTap,
      splashRadius: size * 0.8,
      padding: const EdgeInsets.all(12.0),
    );
  }
}
