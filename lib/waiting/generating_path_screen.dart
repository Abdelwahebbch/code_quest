import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GeneratingPathScreen
//
// Usage:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => GeneratingPathScreen(
//       generationFuture: LearningPathOrchestrator.generate(
//         userId: userId,
//         onboardingAnswers: answers,
//       ),
//       onComplete: (path) => Navigator.pushReplacementNamed(context, '/home'),
//       onError: (e) => Navigator.pop(context),
//     ),
//   ));
// ─────────────────────────────────────────────────────────────────────────────

class GeneratingPathScreen extends StatefulWidget {
  /// The future that generates the LearningPath.
  /// The screen listens to it and calls [onComplete] when done.
  final Future<dynamic> generationFuture;
  final void Function(dynamic result) onComplete;
  final void Function(Object error) onError;

  const GeneratingPathScreen({
    super.key,
    required this.generationFuture,
    required this.onComplete,
    required this.onError,
  });

  @override
  State<GeneratingPathScreen> createState() => _GeneratingPathScreenState();
}

class _GeneratingPathScreenState extends State<GeneratingPathScreen>
    with TickerProviderStateMixin {

  // ── Animation controllers ──────────────────────────────────────────────────
  late final AnimationController _orbitController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;
  late final AnimationController _nodeController;
  late final AnimationController _fadeController;

  // ── Stage management ───────────────────────────────────────────────────────
  int _currentStage = 0;
  bool _isDone = false;

  static const _stages = [
    _Stage(
      emoji:    '🧠',
      title:    'Reading your profile',
      subtitle: 'Analyzing your goals and commitment level…',
      color:    Color(0xFF6C63FF),
      duration: Duration(milliseconds: 1800),
    ),
    _Stage(
      emoji:    '🗺️',
      title:    'Designing your roadmap',
      subtitle: 'Choosing the right concepts for your journey…',
      color:    Color(0xFF00C2FF),
      duration: Duration(milliseconds: 2200),
    ),
    _Stage(
      emoji:    '⚡',
      title:    'Building milestones',
      subtitle: 'Ordering topics from first principles to mastery…',
      color:    Color(0xFF00E5A0),
      duration: Duration(milliseconds: 2000),
    ),
    _Stage(
      emoji:    '🔗',
      title:    'Linking concepts',
      subtitle: 'Making sure every step builds on the last…',
      color:    Color(0xFFFFB347),
      duration: Duration(milliseconds: 1600),
    ),
    _Stage(
      emoji:    '✨',
      title:    'Almost ready',
      subtitle: 'Polishing your personal learning path…',
      color:    Color(0xFFFF6B9D),
      duration: Duration(milliseconds: 99999), // holds until future completes
    ),
  ];

  // Tracks which nodes in the path visual are "lit"
  final List<bool> _litNodes = List.filled(5, false);

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _nodeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );

    _runStages();
    _listenToFuture();
  }

  /// Advances through stages automatically, lighting nodes as it goes.
  Future<void> _runStages() async {
    for (int i = 0; i < _stages.length - 1; i++) {
      await Future.delayed(_stages[i].duration);
      if (!mounted) return;
      await _transitionToStage(i + 1);
    }
  }

  Future<void> _transitionToStage(int index) async {
    // Fade out current content
    await _fadeController.animateTo(0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut);

    if (!mounted) return;
    setState(() {
      _currentStage = index;
      if (index < _litNodes.length) _litNodes[index] = true;
    });

    // Bounce the new node
    _nodeController
      ..reset()
      ..forward();

    // Fade in new content
    await _fadeController.animateTo(1.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn);
  }

  void _listenToFuture() {
    widget.generationFuture.then((result) async {
      if (!mounted) return;
      // Ensure we're at the last stage before completing
      if (_currentStage < _stages.length - 1) {
        await _transitionToStage(_stages.length - 1);
      }
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _isDone = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      widget.onComplete(result);
    }).catchError((error) {
      if (!mounted) return;
      widget.onError(error);
    });
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _nodeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = _stages[_currentStage];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          // ── Ambient background ──────────────────────────────────────────
          _AmbientBackground(
            color:      stage.color,
            controller: _orbitController,
          ),

          // ── Main content ────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Central animated orb
                _CentralOrb(
                  stage:          stage,
                  isDone:         _isDone,
                  orbitCtrl:      _orbitController,
                  pulseCtrl:      _pulseController,
                  shimmerCtrl:    _shimmerController,
                ),

                const SizedBox(height: 48),

                // Stage label
                FadeTransition(
                  opacity: _fadeController,
                  child: _StageLabel(stage: stage, isDone: _isDone),
                ),

                const SizedBox(height: 32),

                // Node progress path
                _NodePath(
                  litNodes:     _litNodes,
                  currentStage: _currentStage,
                  nodeCtrl:     _nodeController,
                  stageColors:  _stages.map((s) => s.color).toList(),
                ),

                const Spacer(flex: 3),

                // Bottom tip
                FadeTransition(
                  opacity: _fadeController,
                  child: _BottomTip(stageIndex: _currentStage),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stage data class
// ─────────────────────────────────────────────────────────────────────────────

class _Stage {
  final String   emoji;
  final String   title;
  final String   subtitle;
  final Color    color;
  final Duration duration;

  const _Stage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.duration,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Ambient Background — soft radial glow that shifts color per stage
// ─────────────────────────────────────────────────────────────────────────────

class _AmbientBackground extends StatelessWidget {
  final Color color;
  final AnimationController controller;

  const _AmbientBackground({required this.color, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      width:  double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center:  const Alignment(0, -0.3),
          radius:  1.1,
          colors: [
            color.withOpacity(0.18),
            const Color(0xFF0D0D1A),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Central Orb — orbiting rings + pulsing core + emoji
// ─────────────────────────────────────────────────────────────────────────────

class _CentralOrb extends StatelessWidget {
  final _Stage stage;
  final bool isDone;
  final AnimationController orbitCtrl;
  final AnimationController pulseCtrl;
  final AnimationController shimmerCtrl;

  const _CentralOrb({
    required this.stage,
    required this.isDone,
    required this.orbitCtrl,
    required this.pulseCtrl,
    required this.shimmerCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer slow orbit ring
          AnimatedBuilder(
            animation: orbitCtrl,
            builder: (_, __) => Transform.rotate(
              angle: orbitCtrl.value * 2 * pi,
              child: CustomPaint(
                size: const Size(190, 190),
                painter: _OrbitRingPainter(
                  color: stage.color,
                  dashCount: 12,
                  strokeWidth: 1.5,
                  opacity: 0.35,
                ),
              ),
            ),
          ),

          // Inner counter-orbit ring
          AnimatedBuilder(
            animation: orbitCtrl,
            builder: (_, __) => Transform.rotate(
              angle: -orbitCtrl.value * 2 * pi * 1.4,
              child: CustomPaint(
                size: const Size(148, 148),
                painter: _OrbitRingPainter(
                  color: stage.color,
                  dashCount: 6,
                  strokeWidth: 1.0,
                  opacity: 0.25,
                ),
              ),
            ),
          ),

          // Pulsing glow
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, __) {
              final scale = 0.92 + 0.08 * pulseCtrl.value;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:       stage.color.withOpacity(0.45),
                        blurRadius:  36 + 12 * pulseCtrl.value,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Core circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            width:  100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  stage.color.withOpacity(0.9),
                  stage.color.withOpacity(0.3),
                ],
              ),
              border: Border.all(
                color: stage.color.withOpacity(0.6),
                width: 1.5,
              ),
            ),
          ),

          // Emoji / checkmark
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim, child: child,
            ),
            child: isDone
                ? const Icon(
                    Icons.check_rounded,
                    key: ValueKey('check'),
                    color: Colors.white,
                    size: 42,
                  )
                : Text(
                    stage.emoji,
                    key: ValueKey(stage.emoji),
                    style: const TextStyle(fontSize: 40),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stage Label — title + subtitle with animated color transition
// ─────────────────────────────────────────────────────────────────────────────

class _StageLabel extends StatelessWidget {
  final _Stage stage;
  final bool isDone;

  const _StageLabel({required this.stage, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 600),
          style: TextStyle(
            fontSize:   26,
            fontWeight: FontWeight.w700,
            color:      isDone ? Colors.white : stage.color,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          child: Text(
            isDone ? 'Your path is ready! 🎉' : stage.title,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: isDone ? 0.0 : 1.0,
          child: Text(
            stage.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color:    Colors.white.withOpacity(0.5),
              height:   1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Node Path — 5 dots connected by a line, lighting up as stages complete
// ─────────────────────────────────────────────────────────────────────────────

class _NodePath extends StatelessWidget {
  final List<bool> litNodes;
  final int currentStage;
  final AnimationController nodeCtrl;
  final List<Color> stageColors;

  const _NodePath({
    required this.litNodes,
    required this.currentStage,
    required this.nodeCtrl,
    required this.stageColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: SizedBox(
        height: 36,
        child: Row(
          children: List.generate(litNodes.length * 2 - 1, (i) {
            if (i.isOdd) {
              // Connector line segment
              final nodeIndex = i ~/ 2;
              final isLit = nodeIndex < currentStage;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    color: isLit
                        ? stageColors[nodeIndex].withOpacity(0.7)
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
              );
            }

            // Node dot
            final nodeIndex = i ~/ 2;
            final isLit = litNodes[nodeIndex];
            final isCurrent = nodeIndex == currentStage;

            return AnimatedBuilder(
              animation: nodeCtrl,
              builder: (_, __) {
                double scale = 1.0;
                if (isCurrent) {
                  // Bounce: overshoot then settle
                  scale = Curves.elasticOut.transform(nodeCtrl.value);
                }
                return Transform.scale(
                  scale: scale,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width:  isLit ? 14 : 10,
                    height: isLit ? 14 : 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLit
                          ? stageColors[nodeIndex]
                          : Colors.white.withOpacity(0.15),
                      boxShadow: isLit
                          ? [
                              BoxShadow(
                                color:       stageColors[nodeIndex].withOpacity(0.6),
                                blurRadius:  10,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Tip — rotating fun facts / tips while the user waits
// ─────────────────────────────────────────────────────────────────────────────

class _BottomTip extends StatelessWidget {
  final int stageIndex;

  const _BottomTip({required this.stageIndex});

  static const _tips = [
    '💡 Your path adapts to your pace — no rush, no pressure.',
    '🏆 Consistent learners are 4× more likely to finish strong.',
    '🔁 Each concept unlocks the next — just keep moving forward.',
    '🧩 Prerequisites are auto-linked so you never feel lost.',
    '🚀 Your first milestone unlocks immediately after this.',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Text(
          _tips[stageIndex % _tips.length],
          key: ValueKey(stageIndex),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize:      13,
            color:         Colors.white.withOpacity(0.38),
            height:        1.6,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painter — dashed orbit ring
// ─────────────────────────────────────────────────────────────────────────────

class _OrbitRingPainter extends CustomPainter {
  final Color  color;
  final int    dashCount;
  final double strokeWidth;
  final double opacity;

  const _OrbitRingPainter({
    required this.color,
    required this.dashCount,
    required this.strokeWidth,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = color.withOpacity(opacity)
      ..strokeWidth = strokeWidth
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final dashAngle = (2 * pi) / dashCount;
    final gapRatio  = 0.35; // fraction of each segment that is a gap

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapRatio);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitRingPainter old) =>
      old.color != color || old.opacity != opacity;
}
