import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_theme.dart';

// ── BACK HEADER ──────────────────────────────────────────────────────────────
class SubHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  const SubHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final surface2 = isDark ? PamodziColors.surface2Dark : PamodziColors.surface2;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;

    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Icon(Icons.chevron_left, color: textColor, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ── GREEN ACTION BUTTON ───────────────────────────────────────────────────────
class PamodziButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool outlined;

  const PamodziButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.isLoading = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? PamodziColors.greenDark2 : PamodziColors.green;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: outlined ? Colors.transparent : primary,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isLoading ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: outlined
                ? BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(10),
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: outlined
                        ? null
                        : [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: outlined ? textColor : Colors.white, size: 16),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: outlined ? textColor : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── STATUS BADGE ──────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    IconData icon;

    switch (status) {
      case 'paid':
        bg = PamodziColors.greenGl;
        fg = PamodziColors.green;
        label = 'Paid';
        icon = Icons.check_circle;
        break;
      case 'pending':
        bg = PamodziColors.amberGl;
        fg = PamodziColors.amber;
        label = 'Pending';
        icon = Icons.schedule;
        break;
      case 'overdue':
        bg = PamodziColors.redGl;
        fg = PamodziColors.red;
        label = 'Overdue';
        icon = Icons.warning_amber;
        break;
      default:
        bg = PamodziColors.greenGl;
        fg = PamodziColors.green;
        label = status;
        icon = Icons.circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 10),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── TOAST ─────────────────────────────────────────────────────────────────────
void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: const Color(0xFF1E2A2A),
    textColor: Colors.white,
    fontSize: 13,
  );
}

// ── SECTION HEADER ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;
    final greenColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: mutedColor,
              letterSpacing: 0.9,
            ),
          ),
          if (action != null) ...[
            const Spacer(),
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: greenColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── ISSUE STATUS CHIP ─────────────────────────────────────────────────────────
class IssueStatusChip extends StatelessWidget {
  final String status;

  const IssueStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'progress':
        color = PamodziColors.amber;
        label = 'In progress';
        break;
      case 'resolved':
        color = PamodziColors.green;
        label = 'Resolved';
        break;
      default:
        color = PamodziColors.blue;
        label = 'Open';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── PRIORITY LABEL ────────────────────────────────────────────────────────────
Color priorityColor(String priority) {
  switch (priority) {
    case 'urgent':
      return PamodziColors.red;
    case 'high':
      return PamodziColors.amber;
    case 'medium':
      return PamodziColors.blue;
    default:
      return PamodziColors.green;
  }
}

IconData issueIcon(String iconType) {
  switch (iconType) {
    case 'plumbing':
      return Icons.water_drop_outlined;
    case 'electrical':
      return Icons.electric_bolt_outlined;
    case 'security':
      return Icons.lock_outline;
    case 'appliances':
      return Icons.kitchen_outlined;
    default:
      return Icons.build_outlined;
  }
}
