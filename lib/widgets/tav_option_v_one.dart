import 'package:flutter/material.dart';

class TabOptions extends StatefulWidget {
  final double width;
  final double height;
  final List<Widget> children;
  final Color? primaryColor;
  final Color? backgroundColor;
  final int selectedChild;
  final void Function(int)? onTap;
  final bool selectorOnTop;
  final bool border;

  const TabOptions({
    super.key,
    required this.width,
    required this.children,
    this.height = 48,
    this.primaryColor,
    this.backgroundColor,
    this.selectedChild = 0,
    this.onTap,
    this.selectorOnTop = false,
    this.border = false,
  });

  @override
  State<TabOptions> createState() => _TabOptionsState();
}

class _TabOptionsState extends State<TabOptions>
    with SingleTickerProviderStateMixin {
  late Color primaryColor;
  late Color backgroundColor;
  late int childrenLength;
  late double childrenWidth;

  late AnimationController _controller;
  late Animation<double> _animation;

  late int selectedChild;
  @override
  void initState() {
    super.initState();

    childrenLength = widget.children.length;
    childrenWidth = widget.width / childrenLength;
    selectedChild = widget.selectedChild;

    if (widget.primaryColor == null) {
      primaryColor = Colors.blue[200]!;
    } else {
      primaryColor = widget.primaryColor!;
    }

    if (widget.backgroundColor == null) {
      backgroundColor = Colors.white;
    } else {
      backgroundColor = widget.backgroundColor!;
    }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );

    _animation = Tween(
      begin: 0.0,
      end: childrenWidth * selectedChild,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeTab(int targetChild) {
    if (targetChild == selectedChild) {
      return;
    }

    _controller.reset();
    _animation = Tween(
      begin: childrenWidth * selectedChild,
      end: childrenWidth * targetChild,
    ).animate(_controller);

    _controller.forward();

    setState(() {
      selectedChild = targetChild;
    });

    widget.onTap?.call(selectedChild);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border:
            widget.border
                ? Border(
                  top:
                      widget.selectorOnTop
                          ? BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiary.withValues(alpha: .3),
                          )
                          : BorderSide.none,
                  bottom:
                      !widget.selectorOnTop
                          ? BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiary.withValues(alpha: .3),
                          )
                          : BorderSide.none,
                )
                : null,
        boxShadow:
            widget.border
                ? null
                : [
                  BoxShadow(
                    blurRadius: 2,
                    color: Theme.of(context).shadowColor,
                    spreadRadius: 1,
                  ),
                ],
      ),
      child: Stack(
        alignment:
            widget.selectorOnTop ? Alignment.topLeft : Alignment.bottomLeft,
        children: [
          Row(
            children:
                widget.children.asMap().entries.map((entry) {
                  final item = entry.value;
                  final index = entry.key;

                  return GestureDetector(
                    onTap: () {
                      _changeTab(index);
                    },
                    child: Container(
                      height: widget.height,
                      width: childrenWidth,
                      color: Colors.transparent,
                      child: Center(child: item),
                    ),
                  );
                }).toList(),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()..translate(_animation.value),
                child: Container(
                  width: childrenWidth,
                  height: 1,
                  color: primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
