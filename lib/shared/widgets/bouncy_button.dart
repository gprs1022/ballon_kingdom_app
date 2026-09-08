import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color? shadowColor;
  final double minWidth;
  final double minHeight;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  const BouncyButton({
    super.key,
    required this.child,
    required this.onTap,
    this.backgroundColor = AppColors.sunnyGold,
    this.shadowColor,
    this.minWidth = 64.0,
    this.minHeight = 64.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.borderRadius,
  });

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(32);
    final shadow = widget.shadowColor ??
        Color.lerp(widget.backgroundColor, Colors.black, 0.35)!;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: BoxConstraints(
            minWidth: widget.minWidth,
            minHeight: widget.minHeight,
          ),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: shadow.withAlpha(180),
                offset: const Offset(0, 5),
                blurRadius: 0, // 3D cartoon button rim
              ),
              const BoxShadow(
                color: Color(0x20000000),
                offset: Offset(0, 8),
                blurRadius: 10,
              ),
            ],
          ),
          padding: widget.padding,
          child: Center(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
