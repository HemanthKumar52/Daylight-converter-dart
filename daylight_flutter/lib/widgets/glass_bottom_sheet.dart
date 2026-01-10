  import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBottomSheet extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget child;

  const GlassBottomSheet({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10), // Safe area + margin
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65), // Dark semi-transparent matching TimeSlider
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grabber Handle
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 10),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Empty space to balance action text if needed, or centered title logic
                    // If actionText is present, we might want a leading widget of same size to perfectly center title
                    // For now, Expanded is fine.
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter', // Assuming Inter is available/desired
                        ),
                      ),
                    ),
                    if (actionText != null) ...[
                      // If we want perfect centering, we might need a Stack, but Row is usually fine for simple sheets
                       GestureDetector(
                        onTap: onAction,
                        child: Text(
                          actionText!,
                          style: const TextStyle(
                            color: Color(0xFFFFCC00), // Matching TimeSlider accent
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.white.withOpacity(0.1)),
              
              // Content
              Flexible(child: child),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
