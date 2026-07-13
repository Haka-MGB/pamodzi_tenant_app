import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/pdf_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'receipts_screen.dart';
import 'change_password_screen.dart';
import 'contact_landlord_screen.dart';

// ── PAYMENT HISTORY ───────────────────────────────────────────────────────────
class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _filter = 'all';
  bool _isRefreshing = false;

  Future<void> _refreshPayments() async {
    setState(() => _isRefreshing = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isRefreshing = false);
      showToast('Payments refreshed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? PamodziColors.bgDark : PamodziColors.bg;

    final List<Payment> filtered = _filter == 'all'
        ? state.payments
        : state.payments.where((p) => p.status == _filter).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(title: 'Payment History'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  _HistoryFilterChip(label: 'All', value: 'all', selected: _filter,
                      onTap: () => setState(() => _filter = 'all')),
                  const SizedBox(width: 8),
                  _HistoryFilterChip(label: 'Paid', value: 'paid', selected: _filter,
                      onTap: () => setState(() => _filter = 'paid'), color: PamodziColors.green),
                  const SizedBox(width: 8),
                  _HistoryFilterChip(label: 'Pending', value: 'pending', selected: _filter,
                      onTap: () => setState(() => _filter = 'pending'), color: PamodziColors.amber),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPayments,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final Payment p = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _HistoryItem(
                        payment: p,
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, a, __) => ReceiptDetailScreen(payment: p),
                            transitionsBuilder: (_, a, __, child) => SlideTransition(
                              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                                  .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                              child: child,
                            ),
                            transitionDuration: const Duration(milliseconds: 220),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  final String label, value, selected;
  final VoidCallback onTap;
  final Color? color;

  const _HistoryFilterChip({required this.label, required this.value, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = value == selected;
    final activeColor = color ?? (isDark ? PamodziColors.greenDark2 : PamodziColors.green);
    final surface2 = isDark ? PamodziColors.surface2Dark : PamodziColors.surface2;
    final text2Color = isDark ? PamodziColors.text2Dark : PamodziColors.text2;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? activeColor.withOpacity(0.4) : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isSelected ? activeColor : text2Color)),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;

  const _HistoryItem({required this.payment, required this.onTap});

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
                decoration: BoxDecoration(color: PamodziColors.greenGl, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.check_circle_outline, color: PamodziColors.green, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.month, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
                    Text(payment.method, style: TextStyle(fontSize: 10, color: mutedColor)),
                    Text(payment.ref, style: TextStyle(fontSize: 9.5, color: mutedColor, fontFamily: 'monospace')),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('K ${payment.amount.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: textColor)),
                  Text(payment.date, style: TextStyle(fontSize: 9.5, color: mutedColor)),
                  const SizedBox(height: 3),
                  StatusBadge(status: payment.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── LEASE SCREEN ──────────────────────────────────────────────────────────────
class LeaseScreen extends StatefulWidget {
  const LeaseScreen({super.key});

  @override
  State<LeaseScreen> createState() => _LeaseScreenState();
}

class _LeaseScreenState extends State<LeaseScreen> {
  final _pdfService = PdfService();
  bool _isGeneratingPdf = false;

  Future<void> _downloadLease() async {
    setState(() => _isGeneratingPdf = true);

    try {
      final state = context.read<AppState>();
      final file = await _pdfService.generateLeasePdf(state.lease, state.tenant);
      
      setState(() => _isGeneratingPdf = false);

      if (mounted) {
        showToast('Lease saved to: ${file.path}');
        
        // Optionally share immediately
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Lease Agreement - ${state.tenant.name}',
          text: 'Tenancy agreement for ${state.tenant.unit}, ${state.tenant.estate}',
        );
      }
    } catch (e) {
      setState(() => _isGeneratingPdf = false);
      if (mounted) {
        showToast('Error generating lease PDF: $e');
      }
    }
  }

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
        child: Column(
          children: [
            SubHeader(title: 'My Lease'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: greenColor.withOpacity(0.06),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              border: Border(bottom: BorderSide(color: borderColor)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: PamodziColors.greenGl,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.description_outlined, color: greenColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tenancy Agreement',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor)),
                                    const SizedBox(height: 2),
                                    Text('Signed 1 Jan 2026 · Active',
                                        style: TextStyle(fontSize: 11, color: mutedColor)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              children: [
                                _LeaseRow(k: 'Tenant', v: state.lease.tenantName, textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                                _LeaseRow(k: 'Property', v: state.lease.property, textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                                _LeaseRow(k: 'Landlord', v: state.lease.landlord, textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                                _LeaseRow(k: 'Lease start', v: state.lease.startDate, textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                                _LeaseRow(k: 'Lease end', v: state.lease.endDate, textColor: textColor, text2Color: text2Color, borderColor: borderColor,
                                    valStyle: TextStyle(color: PamodziColors.amber, fontWeight: FontWeight.w600, fontSize: 13)),
                                _LeaseRow(k: 'Monthly rent', v: 'K ${state.lease.monthlyRent.toStringAsFixed(2)}',
                                    textColor: textColor, text2Color: text2Color, borderColor: borderColor,
                                    valStyle: TextStyle(color: greenColor, fontWeight: FontWeight.w600, fontSize: 13)),
                                _LeaseRow(k: 'Due date', v: state.lease.dueDate, textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                                _LeaseRow(k: 'Late fee', v: 'K ${state.lease.lateFee.toStringAsFixed(0)} after ${state.lease.lateDays} days',
                                    textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                                _LeaseRow(k: 'Deposit paid', v: 'K ${state.lease.deposit.toStringAsFixed(0)} (2 months)',
                                    textColor: textColor, text2Color: text2Color, borderColor: Colors.transparent),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PamodziButton(
                      label: _isGeneratingPdf ? 'Generating PDF...' : 'Download Lease Agreement',
                      icon: _isGeneratingPdf ? null : Icons.download,
                      isLoading: _isGeneratingPdf,
                      onTap: _downloadLease,
                    ),
                    const SizedBox(height: 12),
                    PamodziButton(
                      label: 'Contact Landlord',
                      icon: Icons.mail_outline,
                      outlined: true,
                      onTap: () => showToast('Landlord contacted: ${state.lease.landlordEmail}'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaseRow extends StatelessWidget {
  final String k, v;
  final Color textColor, text2Color, borderColor;
  final TextStyle? valStyle;

  const _LeaseRow({required this.k, required this.v, required this.textColor, required this.text2Color, required this.borderColor, this.valStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(color: text2Color, fontSize: 13)),
          Text(v, style: valStyle ?? TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── NOTIFICATIONS SCREEN ──────────────────────────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? PamodziColors.bgDark : PamodziColors.bg;
    final greenColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: 'Notifications',
              trailing: GestureDetector(
                onTap: () {
                  state.markAllNotifsRead();
                  showToast('All marked as read');
                },
                child: Text('Mark all read',
                    style: TextStyle(fontSize: 11.5, color: greenColor, fontWeight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.notifications.length,
                itemBuilder: (ctx, i) {
                  final AppNotification notif = state.notifications[i];
                  return _NotifItem(notif: notif);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  final AppNotification notif;
  const _NotifItem({required this.notif});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final text2Color = isDark ? PamodziColors.text2Dark : PamodziColors.text2;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;

    Color typeColor;
    IconData typeIcon;
    switch (notif.type) {
      case 'green':
        typeColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;
        typeIcon = notif.iconType == 'bell' ? Icons.notifications : Icons.check_circle;
        break;
      case 'amber':
        typeColor = isDark ? PamodziColors.amberDark : PamodziColors.amber;
        typeIcon = Icons.build;
        break;
      case 'blue':
        typeColor = isDark ? PamodziColors.blueDark : PamodziColors.blue;
        typeIcon = Icons.description_outlined;
        break;
      default:
        typeColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;
        typeIcon = Icons.notifications;
    }

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
          color: notif.unread
        ? (isDark ? PamodziColors.greenDark2.withOpacity(0.04) : PamodziColors.green.withOpacity(0.02))
        : Colors.transparent,
              border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(typeIcon, color: typeColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif.title,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
                const SizedBox(height: 3),
                Text(notif.body,
                    style: TextStyle(fontSize: 12, color: text2Color, height: 1.4), maxLines: 3),
                const SizedBox(height: 4),
                Text(notif.time, style: TextStyle(fontSize: 10.5, color: mutedColor)),
              ],
            ),
          ),
          if (notif.unread)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: isDark ? PamodziColors.greenDark2 : PamodziColors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

// ── PROFILE SCREEN ────────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                color: surfaceColor,
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [greenColor, PamodziColors.greenDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(state.tenant.initials,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(state.tenant.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
                    const SizedBox(height: 4),
                    Text('${state.tenant.unit} · ${state.tenant.estate}, ${state.tenant.city}',
                        style: TextStyle(fontSize: 12, color: mutedColor)),
                  ],
                ),
              ),

              Container(height: 1, color: borderColor),

              _ProfileSection(
                title: 'Account',
                rows: [
                  _ProfileRow(icon: Icons.mail_outline, iconBg: PamodziColors.greenGl, iconColor: greenColor,
                      label: 'Email address', value: state.tenant.email,
                      surfaceColor: surfaceColor, borderColor: borderColor, textColor: textColor, text2Color: text2Color, mutedColor: mutedColor),
                  _ProfileRow(icon: Icons.phone_outlined, iconBg: PamodziColors.blueGl, iconColor: PamodziColors.blue,
                      label: 'Phone number', value: state.tenant.phone,
                      surfaceColor: surfaceColor, borderColor: borderColor, textColor: textColor, text2Color: text2Color, mutedColor: mutedColor),
                  _ProfileRow(icon: Icons.lock_outline, iconBg: PamodziColors.amberGl, iconColor: PamodziColors.amber,
                      label: 'Change password', value: 'Last changed 3 months ago',
                      surfaceColor: surfaceColor, borderColor: borderColor, textColor: textColor, text2Color: text2Color, mutedColor: mutedColor,
                      onTap: () => Navigator.push(context, PageRouteBuilder(
                        pageBuilder: (_, a, __) => const ChangePasswordScreen(),
                        transitionsBuilder: (_, a, __, child) => SlideTransition(
                          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                        transitionDuration: const Duration(milliseconds: 220),
                      ))),
                ],
                bgColor: bgColor, textColor: textColor, mutedColor: mutedColor,
              ),

              _ProfileSection(
                title: 'Tenancy',
                rows: [
                  _ProfileRow(icon: Icons.description_outlined, iconBg: PamodziColors.greenGl, iconColor: greenColor,
                      label: 'My lease agreement', value: 'Active · expires Dec 2026',
                      surfaceColor: surfaceColor, borderColor: borderColor, textColor: textColor, text2Color: text2Color, mutedColor: mutedColor,
                      onTap: () => Navigator.push(context, PageRouteBuilder(
                        pageBuilder: (_, a, __) => const LeaseScreen(),
                        transitionsBuilder: (_, a, __, child) => SlideTransition(
                          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                        transitionDuration: const Duration(milliseconds: 220),
                      ))),
                  _ProfileRow(icon: Icons.headset_mic_outlined, iconBg: PamodziColors.blueGl, iconColor: PamodziColors.blue,
                      label: 'Contact landlord', value: '${state.lease.landlord} · ${state.lease.landlordEmail}',
                      surfaceColor: surfaceColor, borderColor: borderColor, textColor: textColor, text2Color: text2Color, mutedColor: mutedColor,
                      onTap: () => Navigator.push(context, PageRouteBuilder(
                        pageBuilder: (_, a, __) => const ContactLandlordScreen(),
                        transitionsBuilder: (_, a, __, child) => SlideTransition(
                          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                        transitionDuration: const Duration(milliseconds: 220),
                      ))),
                ],
                bgColor: bgColor, textColor: textColor, mutedColor: mutedColor,
              ),

              _ProfileSection(
                title: 'Preferences',
                rows: [
                  _ProfileRowToggle(
                    icon: Icons.dark_mode_outlined,
                    iconBg: isDark ? PamodziColors.surface2Dark : PamodziColors.surface2,
                    iconColor: mutedColor,
                    label: 'Dark mode',
                    value: 'Toggle theme',
                    isOn: isDark,
                    onToggle: () => context.read<AppState>().toggleDarkMode(),
                    surfaceColor: surfaceColor, borderColor: borderColor, textColor: textColor,
                    text2Color: text2Color, mutedColor: mutedColor, greenColor: greenColor,
                  ),
                  _ProfileRowToggle(
                    icon: Icons.notifications_outlined,
                    iconBg: PamodziColors.greenGl,
                    iconColor: greenColor,
                    label: 'Notifications',
                    value: 'Push & SMS enabled',
                    isOn: true,
                    onToggle: () => Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (_, a, __) => const NotificationSettingsScreen(),
                      transitionsBuilder: (_, a, __, child) => SlideTransition(
                        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                            .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                        child: child,
                      ),
                      transitionDuration: const Duration(milliseconds: 220),
                    )),
                    surfaceColor: surfaceColor, borderColor: borderColor, textColor: textColor,
                    text2Color: text2Color, mutedColor: mutedColor, greenColor: greenColor,
                  ),
                  _ProfileRow(icon: Icons.language, iconBg: PamodziColors.greenGl, iconColor: greenColor,
                      label: 'Language', value: state.languages[state.selectedLanguage] ?? 'English',
                      surfaceColor: surfaceColor, borderColor: borderColor, textColor: textColor, text2Color: text2Color, mutedColor: mutedColor,
                      onTap: () => Navigator.push(context, PageRouteBuilder(
                        pageBuilder: (_, a, __) => const LanguageSelectionScreen(),
                        transitionsBuilder: (_, a, __, child) => SlideTransition(
                          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                        transitionDuration: const Duration(milliseconds: 220),
                      ))),
                ],
                bgColor: bgColor, textColor: textColor, mutedColor: mutedColor,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sign out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PamodziColors.red,
                      side: const BorderSide(color: PamodziColors.redGl),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to access your account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppState>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: PamodziColors.red),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  final Color bgColor, textColor, mutedColor;

  const _ProfileSection({
    required this.title,
    required this.rows,
    required this.bgColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text(title.toUpperCase(),
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: mutedColor, letterSpacing: 0.8)),
        ),
        ...rows,
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor, surfaceColor, borderColor, textColor, text2Color, mutedColor;
  final String label, value;
  final VoidCallback? onTap;

  const _ProfileRow({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.label, required this.value,
    required this.surfaceColor, required this.borderColor,
    required this.textColor, required this.text2Color, required this.mutedColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor, width: 0.5))),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                    Text(value, style: TextStyle(fontSize: 11, color: mutedColor), maxLines: 1, overflow: TextOverflow.ellipsis),
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

class _ProfileRowToggle extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor, surfaceColor, borderColor, textColor, text2Color, mutedColor, greenColor;
  final String label, value;
  final bool isOn;
  final VoidCallback onToggle;

  const _ProfileRowToggle({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.label, required this.value, required this.isOn, required this.onToggle,
    required this.surfaceColor, required this.borderColor,
    required this.textColor, required this.text2Color, required this.mutedColor, required this.greenColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor, width: 0.5))),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                  Text(value, style: TextStyle(fontSize: 11, color: mutedColor)),
                ],
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44, height: 24,
                decoration: BoxDecoration(
                  color: isOn ? greenColor : mutedColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    width: 20, height: 20,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── NOTIFICATION SETTINGS SCREEN ──────────────────────────────────────────────
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

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
        child: Column(
          children: [
            SubHeader(title: 'Notification Settings'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CHANNELS', 
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: mutedColor, letterSpacing: 0.8)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          _NotificationToggleItem(
                            icon: Icons.notifications_active,
                            iconBg: PamodziColors.greenGl,
                            iconColor: greenColor,
                            label: 'Push Notifications',
                            description: 'Receive push notifications on this device',
                            isOn: state.notificationSettings['push'] ?? true,
                            onToggle: (val) => state.updateNotificationSettings('push', val),
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            text2Color: text2Color,
                            greenColor: greenColor,
                            mutedColor: mutedColor,
                          ),
                          _NotificationToggleItem(
                            icon: Icons.sms,
                            iconBg: PamodziColors.blueGl,
                            iconColor: PamodziColors.blue,
                            label: 'SMS Notifications',
                            description: 'Receive important alerts via SMS',
                            isOn: state.notificationSettings['sms'] ?? true,
                            onToggle: (val) => state.updateNotificationSettings('sms', val),
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            text2Color: text2Color,
                            greenColor: greenColor,
                            mutedColor: mutedColor,
                          ),
                          _NotificationToggleItem(
                            icon: Icons.email,
                            iconBg: PamodziColors.amberGl,
                            iconColor: PamodziColors.amber,
                            label: 'Email Notifications',
                            description: 'Receive updates via email',
                            isOn: state.notificationSettings['email'] ?? true,
                            onToggle: (val) => state.updateNotificationSettings('email', val),
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            text2Color: text2Color,
                            greenColor: greenColor,
                            mutedColor: mutedColor,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('NOTIFICATION TYPES', 
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: mutedColor, letterSpacing: 0.8)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          _NotificationToggleItem(
                            icon: Icons.calendar_today,
                            iconBg: PamodziColors.greenGl,
                            iconColor: greenColor,
                            label: 'Rent Reminders',
                            description: 'Upcoming rent due date reminders',
                            isOn: state.notificationSettings['rent_reminders'] ?? true,
                            onToggle: (val) => state.updateNotificationSettings('rent_reminders', val),
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            text2Color: text2Color,
                            greenColor: greenColor,
                            mutedColor: mutedColor,
                          ),
                          _NotificationToggleItem(
                            icon: Icons.build,
                            iconBg: PamodziColors.amberGl,
                            iconColor: PamodziColors.amber,
                            label: 'Maintenance Updates',
                            description: 'Status updates on maintenance requests',
                            isOn: state.notificationSettings['maintenance_updates'] ?? true,
                            onToggle: (val) => state.updateNotificationSettings('maintenance_updates', val),
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            text2Color: text2Color,
                            greenColor: greenColor,
                            mutedColor: mutedColor,
                          ),
                          _NotificationToggleItem(
                            icon: Icons.check_circle,
                            iconBg: PamodziColors.greenGl,
                            iconColor: greenColor,
                            label: 'Payment Confirmations',
                            description: 'Confirmations when payments are processed',
                            isOn: state.notificationSettings['payment_confirmations'] ?? true,
                            onToggle: (val) => state.updateNotificationSettings('payment_confirmations', val),
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            text2Color: text2Color,
                            greenColor: greenColor,
                            mutedColor: mutedColor,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationToggleItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor, surfaceColor, borderColor, textColor, text2Color, greenColor, mutedColor;
  final String label, description;
  final bool isOn;
  final Function(bool) onToggle;
  final bool isLast;

  const _NotificationToggleItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.description,
    required this.isOn,
    required this.onToggle,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.text2Color,
    required this.greenColor,
    required this.mutedColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(fontSize: 11, color: text2Color)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onToggle(!isOn),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: isOn ? greenColor : mutedColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── LANGUAGE SELECTION SCREEN ─────────────────────────────────────────────────
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

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
        child: Column(
          children: [
            SubHeader(title: 'Language'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SELECT YOUR LANGUAGE', 
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: mutedColor, letterSpacing: 0.8)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: state.languages.entries.map((entry) {
                          final isLast = entry.key == state.languages.keys.last;
                          final isSelected = entry.key == state.selectedLanguage;
                          
                          return _LanguageItem(
                            languageCode: entry.key,
                            languageName: entry.value,
                            isSelected: isSelected,
                            isLast: isLast,
                            onTap: () {
                              state.setLanguage(entry.key);
                              showToast('Language changed to ${entry.value}');
                            },
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            text2Color: text2Color,
                            greenColor: greenColor,
                            mutedColor: mutedColor,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: PamodziColors.blueGl,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: PamodziColors.blue.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: PamodziColors.blue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Full localization support is coming soon. Currently showing UI elements in selected language.',
                              style: TextStyle(fontSize: 11.5, color: PamodziColors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageItem extends StatelessWidget {
  final String languageCode, languageName;
  final bool isSelected, isLast;
  final VoidCallback onTap;
  final Color surfaceColor, borderColor, textColor, text2Color, greenColor, mutedColor;

  const _LanguageItem({
    required this.languageCode,
    required this.languageName,
    required this.isSelected,
    required this.isLast,
    required this.onTap,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.text2Color,
    required this.greenColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: isLast ? null : Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? greenColor.withOpacity(0.1) : PamodziColors.greenGl,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.language,
                  color: isSelected ? greenColor : mutedColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? greenColor : textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      languageCode.toUpperCase(),
                      style: TextStyle(fontSize: 10, color: text2Color, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: greenColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
