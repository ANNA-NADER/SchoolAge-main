import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/form_draft_service.dart';
import '../screens/application_screen.dart';
import '../screens/parent_info_screen.dart';
import '../main.dart'; // To access the global navigatorKey

class FloatingFormBubble extends StatefulWidget {
  final Widget child;
  const FloatingFormBubble({super.key, required this.child});

  @override
  State<FloatingFormBubble> createState() => _FloatingFormBubbleState();
}

class _FloatingFormBubbleState extends State<FloatingFormBubble> {
  final _draftService = FormDraftService();

  @override
  void initState() {
    super.initState();
    _draftService.addListener(_handleDraftChange);
  }

  @override
  void dispose() {
    _draftService.removeListener(_handleDraftChange);
    super.dispose();
  }

  void _handleDraftChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_draftService.hasDraft && !_draftService.isFormActive)
          Positioned(
            right: 16,
            bottom: 110, // Adjusted to be clearly above bottom navigation
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: _buildBubble(),
            ),
          ),
      ],
    );
  }

  Widget _buildBubble() {
    return Material(
      color: Colors.transparent,
      elevation: 8,
      shape: const CircleBorder(),
      child: GestureDetector(
        onTap: _resumeForm,
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: const Color(0xFF2B3346),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                CupertinoIcons.doc_text_fill,
                color: Colors.white,
                size: 30,
              ),
              Positioned(
                right: 12,
                top: 12,
                child: PulseDot(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resumeForm() {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    if (_draftService.currentStep == 'application') {
      nav.push(
        MaterialPageRoute(
          builder: (_) => ApplicationScreen(
            schoolId: _draftService.schoolId ?? '',
            schoolName: _draftService.schoolName ?? '',
          ),
        ),
      );
    } else if (_draftService.currentStep == 'parent_info') {
      nav.push(
        MaterialPageRoute(builder: (_) => const ParentInfoScreen()),
      );
    }
  }
}

class PulseDot extends StatefulWidget {
  const PulseDot({super.key});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.3).animate(_controller),
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Color(0xFFFF3B30), // iOS Red
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
