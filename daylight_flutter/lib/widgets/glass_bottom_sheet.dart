import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bouncing_button.dart';

class GlassBottomSheet extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final VoidCallback? onAdd;
  final Widget child;
  final bool expandContent;

  final bool isFullScreen;

  const GlassBottomSheet({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
    this.onAdd,
    required this.child,
    this.expandContent = false,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define semi-transparent colors for glass effect
    final glassColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.7) // Dark Glass
        : const Color(0xFFF2F2F7).withValues(alpha: 0.65); // Light Glass

    // Define solid colors for full screen mode
    final solidColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    final backgroundColor = isFullScreen ? solidColor : glassColor;

    return Padding(
      // Padding with bottom 4 as per request
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.of(context).padding.top + 12,
        12,
        MediaQuery.of(context).padding.bottom + 4,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32), // Fully rounded corners
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(
                        alpha: 0.4,
                      ) // Stronger white for Dark Mode
                    : Colors.black.withValues(
                        alpha: 0.2,
                      ), // Stronger black for Light Mode
                width: 1.0, // Thicker border
              ),
            ),
            clipBehavior: Clip.none, // Allow content to not be clipped
            child: Column(
              mainAxisSize: expandContent ? MainAxisSize.max : MainAxisSize.min,
              children: [
                // Header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Handle Bar
                    Container(
                      width: 36,
                      height: 5,
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior:
                          Clip.none, // Prevent clipping of positioned elements
                      children: [
                        // Centered Title
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // Right-aligned Actions using Positioned
                        Positioned(
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (onAdd != null) ...[
                                BouncingButton(
                                  onTap: onAdd!,
                                  child: Icon(
                                    Icons.add,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 20),
                              ],
                              if (actionText != null) ...[
                                BouncingButton(
                                  onTap: onAction!,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ), // Reduced horizontal padding
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.1,
                                              ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ), // Pill / Capsule Shape
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.2,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: 0.15,
                                                ),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        actionText!,
                                        style: GoogleFonts.outfit(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Divider Removed as requested

                // Content
                expandContent ? Expanded(child: child) : Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
