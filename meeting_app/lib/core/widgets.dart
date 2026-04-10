import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme.dart';

// ─────────────────────────────────────────────────────────────
// GLASS CARD — Frosted glassmorphism container
// ─────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final Color? borderColor;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppRadius.xl,
    this.blur = 24,
    this.borderColor,
    this.onTap,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.glass,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder,
                width: 1,
              ),
              boxShadow: boxShadow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BENTO TILE — Grid-friendly glass tile
// ─────────────────────────────────────────────────────────────
class BentoTile extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? accentColor;

  const BentoTile({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppRadius.xl,
    this.onTap,
    this.gradient,
    this.accentColor,
  });

  @override
  State<BentoTile> createState() => _BentoTileState();
}

class _BentoTileState extends State<BentoTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: widget.gradient ??
                    LinearGradient(
                      colors: [
                        AppColors.glass,
                        AppColors.glass.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.accentColor?.withOpacity(0.15) ??
                      AppColors.glassBorder,
                  width: 1,
                ),
                boxShadow: AppShadows.soft,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// GRADIENT BUTTON — Primary floating action button
// ─────────────────────────────────────────────────────────────
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Gradient? gradient;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.gradient,
    this.icon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _controller.forward(),
      onTapUp: isDisabled
          ? null
          : (_) {
              _controller.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: isDisabled ? null : () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: widget.gradient ?? AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: isDisabled ? null : AppShadows.glow(AppColors.primaryPeach),
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NEUMORPHIC BUTTON — Soft embossed button
// ─────────────────────────────────────────────────────────────
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderRadius = AppRadius.md,
    this.padding,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.surface : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isPressed ? null : AppShadows.neumorphicLight,
          border: Border.all(
            color: _isPressed
                ? AppColors.glassBorder
                : AppColors.border,
            width: 1,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// GLOW ICON — Icon with soft radiant glow
// ─────────────────────────────────────────────────────────────
class GlowIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final double glowRadius;

  const GlowIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color = AppColors.primaryPeach,
    this.glowRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: glowRadius,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, size: size, color: color),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// GLASS INPUT FIELD — Frosted text input
// ─────────────────────────────────────────────────────────────
class GlassInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const GlassInputField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          controller: controller,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
          obscureText: obscureText,
          keyboardType: keyboardType,
          autocorrect: autocorrect,
          textCapitalization: textCapitalization,
          validator: validator,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            labelStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary.withOpacity(0.6),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textTertiary, size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.glass,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.primaryPeach,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ASSISTANT MESSAGE BUBBLE — Gradient AI message
// ─────────────────────────────────────────────────────────────
class AssistantMessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isError;

  const AssistantMessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return _buildUserBubble();
    }
    return _buildAssistantBubble();
  }

  Widget _buildUserBubble() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg).copyWith(
        bottomRight: const Radius.circular(4),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassHover,
            borderRadius: BorderRadius.circular(AppRadius.lg).copyWith(
              bottomRight: const Radius.circular(4),
            ),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantBubble() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isError
            ? LinearGradient(
                colors: [
                  AppColors.error.withOpacity(0.08),
                  AppColors.error.withOpacity(0.03),
                ],
              )
            : LinearGradient(
                colors: [
                  AppColors.primaryPeach.withOpacity(0.08),
                  AppColors.secondaryBlue.withOpacity(0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(AppRadius.lg).copyWith(
          bottomLeft: const Radius.circular(4),
        ),
        border: Border.all(
          color: isError
              ? AppColors.error.withOpacity(0.15)
              : AppColors.primaryPeach.withOpacity(0.1),
        ),
      ),
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(
          color: isError ? AppColors.error : AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// GLOWING SWITCH — Toggle with glow animation
// ─────────────────────────────────────────────────────────────
class GlowingSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;

  const GlowingSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor = AppColors.primaryPeach,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          color: value ? activeColor.withOpacity(0.3) : AppColors.surfaceElevated,
          border: Border.all(
            color: value ? activeColor.withOpacity(0.5) : AppColors.border,
            width: 1.5,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? activeColor : AppColors.textSecondary,
              boxShadow: value ? AppShadows.glow(activeColor) : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION HEADER — Labeled glass section
// ─────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionHeader({super.key, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          GlowIcon(icon: icon!, size: 16, color: AppColors.primaryPeach, glowRadius: 8),
          const SizedBox(width: 8),
        ],
        Text(
          title.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.primaryPeach,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// APP LOGO HEADER — Consistent branding header
// ─────────────────────────────────────────────────────────────
class AppLogoHeader extends StatelessWidget {
  const AppLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: AppShadows.glow(AppColors.primaryPeach),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Image.asset(
              'assets/images/logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'EchoMind',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
