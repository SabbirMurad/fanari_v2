import 'package:fanari_v2/widgets/bouncing_three_dot.dart';
import 'package:flutter/material.dart';

class ButtonVOne extends StatefulWidget {
  final bool enabled;
  final String text;
  final Function()? onTap;
  final bool loading;

  const ButtonVOne({
    super.key,
    required this.enabled,
    required this.text,
    this.loading = false,
    this.onTap,
  });

  @override
  State<ButtonVOne> createState() => _ButtonVOneState();
}

class _ButtonVOneState extends State<ButtonVOne> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.enabled && !widget.loading) {
          widget.onTap?.call();
        }
      },
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.5,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 36),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(36),
          ),
          child: widget.loading
              ? BouncingDots(color: Colors.white, dotSize: 6, dotCount: 3)
              : Text(
                  widget.text,
                  style: TextStyle(color: Colors.white, fontSize: 21),
                ),
        ),
      ),
    );
  }
}
