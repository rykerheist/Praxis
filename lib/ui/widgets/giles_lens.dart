import 'package:flutter/material.dart';
import '../../theme.dart';

enum GilesState {
  idle,
  thinking,
  speaking,
}

class GilesLens extends StatefulWidget {
  final GilesState state;
  final double size;

  const GilesLens({
    super.key,
    this.state = GilesState.idle,
    this.size = 48.0,
  });

  @override
  State<GilesLens> createState() => _GilesLensState();
}

class _GilesLensState extends State<GilesLens> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Thinking Animation: Slow rotation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Speaking Animation: Pulse/Breathing
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _updateAnimationState();
  }

  @override
  void didUpdateWidget(GilesLens oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateAnimationState();
    }
  }

  void _updateAnimationState() {
    // Reset all
    _rotationController.stop();
    _pulseController.stop();

    switch (widget.state) {
      case GilesState.idle:
        _rotationController.reset();
        _pulseController.reset();
        break;
      case GilesState.thinking:
        _rotationController.repeat();
        break;
      case GilesState.speaking:
        _pulseController.repeat(reverse: true);
        break;
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _pulseController]),
      builder: (context, child) {
        // Opacity depends on state
        double opacity = 1.0;
        if (widget.state == GilesState.speaking) {
          opacity = _pulseAnimation.value;
        }

        return RotationTransition(
          turns: _rotationController,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: PraxisTheme.burnishedGold,
                  width: 2.0, // Thin gold wire
                ),
                color: Colors.transparent, // Lens is clear for now
              ),
              child: Center(
                // Optional: Inner reflection/glint could go here
                child: Container(), 
              ),
            ),
          ),
        );
      },
    );
  }
}
