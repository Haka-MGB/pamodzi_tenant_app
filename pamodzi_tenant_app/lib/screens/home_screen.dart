import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'pay_screen.dart';
import 'maintenance_screen.dart';
import 'receipts_screen.dart';
import 'lease_screen.dart';
import 'payment_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? PamodziColors.bgDark : PamodziColors.bg;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final text2Color = isDark ? PamodziColors.text2Dark : PamodziColors.text2;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;
    final greenColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                color: surfaceColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.getGreeting(),
                        style: TextStyle(fontSize: 12, color: mutedColor, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(state.tenant.name,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: textColor)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: greenColor, size: 12),
                          const SizedBox(width: 5),
                          Text(
                            '${state.tenant.unit} · ${state.tenant.estate}, ${state.tenant.city} · 2026',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: text2Color),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: Container(height: 1, color: borderColor)),

            // Rent hero
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _RentHeroCard(state: state),
              ),
            ),

            // Quick actions
            SliverToBoxAdapter(
              child: SectionHeader(title: 'Quick actions'),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    _ActionTile(icon: Icons.payments_outlined, label: 'Pay Rent',
                        onTap: () => Navigator.push(context, _slide(const PayScreen()))),
                    const SizedBox(width: 10),
                    _ActionTile(icon: Icons.build_outlined, label: 'Report Issue',
                        onTap: () => Navigator.push(context, _slide(const NewMaintenanceScreen()))),
                    const SizedBox(width: 10),
                    _ActionTile(icon: Icons.receipt_outlined, label: 'Receipts',
                        onTap: () => Navigator.push(context, _slide(const ReceiptsScreen()))),
                    const SizedBox(width: 10),
                    _ActionTile(icon: Icons.description_outlined, label: 'My Lease',
                        onTap: () => Navigator.push(context, _slide(const LeaseScreen()))),
                  ],
                ),
              ),
            ),

            // Recent payments
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Recent payments',
                action: 'View all →',
                onAction: () => Navigator.push(context, _slide(const PaymentHistoryScreen())),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final p = state.payments[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PaymentItem(
                        month: p.month,
                        method: p.method,
                        ref: p.ref,
                        amount: p.amount,
                        date: p.date,
                        status: p.status,
                        onTap: () => Navigator.push(context, _slide(ReceiptDetailScreen(payment: p))),
                      ),
                    );
                  },
                  childCount: state.payments.length > 2 ? 2 : state.payments.length,
                ),
              ),
            ),

            // Maintenance preview
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Maintenance',
                action: 'View all →',
                onAction: () => Navigator.push(context, _slide(const MaintenanceListScreen())),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverToBoxAdapter(
                child: state.issues.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Center(
                          child: Text('No active issues', style: TextStyle(color: mutedColor, fontSize: 13)),
                        ),
                      )
                    : _MaintenancePreviewCard(
                        issue: state.issues.first,
                        onTap: () => Navigator.push(context, _slide(const MaintenanceListScreen())),
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],
        ),
      ),
    );
  }

  PageRouteBuilder _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 220),
    );
  }
}

// ── RENT HERO CARD ────────────────────────────────────────────────────────────
class _RentHeroCard extends StatelessWidget {
  final AppState state;
  const _RentHeroCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PamodziColors.heroGrad1, PamodziColors.heroGrad2, PamodziColors.heroGrad3],
          stops: [0, 0.6, 1],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PamodziColors.green.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.all(22),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [PamodziColors.green.withOpacity(0.25), Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monthly rent',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.45), fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('K ', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w500)),
                  const Text('2,200', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.06, height: 1.1)),
                  Text('.00', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: PamodziColors.greenGl,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0x4D5CC99A)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF5CC99A), size: 12),
                        const SizedBox(width: 5),
                        const Text('Paid · April 2026',
                            style: TextStyle(color: Color(0xFF5CC99A), fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Next due: 1 May 2026',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.38))),
                ],
              ),
              const SizedBox(height: 16),
              Material(
                color: PamodziColors.green,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, a, __) => const PayScreen(),
                      transitionsBuilder: (_, a, __, child) => SlideTransition(
                        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                            .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                        child: child,
                      ),
                      transitionDuration: const Duration(milliseconds: 220),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Pay May Rent',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── ACTION TILE ───────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final greenColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;
    final text2Color = isDark ? PamodziColors.text2Dark : PamodziColors.text2;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Icon(icon, color: greenColor, size: 22),
              const SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: text2Color),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PAYMENT ITEM ──────────────────────────────────────────────────────────────
class _PaymentItem extends StatelessWidget {
  final String month, method, ref, date, status;
  final double amount;
  final VoidCallback? onTap;

  const _PaymentItem({
    required this.month,
    required this.method,
    required this.ref,
    required this.date,
    required this.status,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: PamodziColors.greenGl,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_outline, color: PamodziColors.green, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(month, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
                    const SizedBox(height: 2),
                    Text(method, style: TextStyle(fontSize: 10, color: mutedColor)),
                    Text(ref, style: TextStyle(fontSize: 9.5, color: mutedColor, fontFamily: 'monospace')),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('K ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: textColor)),
                  const SizedBox(height: 2),
                  Text(date, style: TextStyle(fontSize: 9.5, color: mutedColor)),
                  const SizedBox(height: 3),
                  StatusBadge(status: status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── MAINTENANCE PREVIEW ───────────────────────────────────────────────────────
class _MaintenancePreviewCard extends StatelessWidget {
  final dynamic issue;
  final VoidCallback onTap;

  const _MaintenancePreviewCard({required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: PamodziColors.amberGl,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.water_drop_outlined, color: PamodziColors.amber, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(issue.title,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('Reported ${issue.date} · Assigned to ${issue.assignee}',
                        style: TextStyle(fontSize: 10, color: mutedColor)),
                    const SizedBox(height: 4),
                    IssueStatusChip(status: issue.status),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: mutedColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}


