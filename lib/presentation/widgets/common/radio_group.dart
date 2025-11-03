import 'package:flutter/widgets.dart';

class RadioGroup<T> extends StatefulWidget {
  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  final T groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;

  @override
  State<RadioGroup<T>> createState() => _RadioGroupState<T>();
}

class _RadioGroupState<T> extends State<RadioGroup<T>> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
