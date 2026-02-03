import 'package:flutter/material.dart';

class PraxisButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double width;
  final double height;
  final bool isLoading;

  const PraxisButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width = double.infinity,
    this.height = 56,
    this.isLoading = false,
  });

  @override
  State<PraxisButton> createState() => _PraxisButtonState();
}

class _PraxisButtonState extends State<PraxisButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.onPressed == null 
                  ? Colors.grey 
                  : widget.backgroundColor ?? Theme.of(context).primaryColor,
                borderRadius: BorderRadius.zero, // Sharp corners
              ),
              alignment: Alignment.center,
              child: widget.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.foregroundColor ?? Colors.white,
                      ),
                    )
                  : DefaultTextStyle(
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: widget.foregroundColor ?? Colors.white,
                        letterSpacing: 2.0,
                      ),
                      child: widget.child,
                    ),
            ),
          );
        },
      ),
    );
  }
}
