import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/success_animation.dart';
import '../services/payment_service.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final _paymentService = PaymentService();
  bool _isProcessing = false;

  Future<void> _processPayment(BuildContext context, AppState state) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      PaymentResult result;

      switch (state.selectedPaymentMethod) {
        case 'airtel':
          result = await _paymentService.processAirtelMoney(
            amount: 2200.00,
            phoneNumber: '0977123456',
            reference: state.rentRef,
            description: 'Rent payment for ${state.rentPeriod}',
          );
          break;
        case 'mtn':
          result = await _paymentService.processMtnMomo(
            amount: 2200.00,
            phoneNumber: '0960000012',
            reference: state.rentRef,
            description: 'Rent payment for ${state.rentPeriod}',
          );
          break;
        case 'bank':
          result = await _paymentService.processBankTransfer(
            amount: 2200.00,
            reference: state.rentRef,
            accountNumber: '1001234002200',
          );
          break;
        case 'deposit':
          // For deposit slip upload, we'll simulate success
          result = PaymentResult(
            success: true,
            transactionId: 'DEP${DateTime.now().millisecondsSinceEpoch}',
            message: 'Deposit slip recorded. Awaiting verification.',
            reference: state.rentRef,
            requiresManualConfirmation: true,
          );
          break;
        default:
          result = PaymentResult(
            success: false,
            message: 'Unknown payment method',
            reference: state.rentRef,
          );
      }

      setState(() => _isProcessing = false);

      if (!mounted) return;

      if (result.success) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, a, __) => PaySuccessScreen(
              method: _methodName(state.selectedPaymentMethod),
              message: result.message,
              transactionId: result.transactionId ?? 'N/A',
            ),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        showToast('Payment failed: ${result.message}');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        showToast('Error processing payment: $e');
      }
    }
  }

  String _methodName(String method) {
    switch (method) {
      case 'airtel': return 'Airtel Money';
      case 'mtn': return 'MTN Mobile Money';
      case 'bank': return 'Bank Transfer';
      case 'deposit': return 'Deposit Slip Upload';
      default: return method;
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
            SubHeader(title: 'Pay Rent'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(k: 'Period', v: state.rentPeriod, textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                          _SummaryRow(k: 'Unit', v: '${state.tenant.unit} · ${state.tenant.estate}', textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                          _SummaryRow(
                            k: 'Reference',
                            v: state.rentRef,
                            textColor: textColor,
                            text2Color: text2Color,
                            borderColor: borderColor,
                            valStyle: TextStyle(fontFamily: 'monospace', color: greenColor, fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Amount due', style: TextStyle(color: text2Color, fontSize: 13)),
                                Text('K 2,200',
                                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: greenColor, letterSpacing: -0.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Payment method
                    SectionHeader(title: 'Payment method'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _MethodItem(
                            method: 'airtel',
                            icon: Icons.phone_android,
                            iconBg: Colors.red.withOpacity(0.08),
                            iconColor: Colors.red,
                            name: 'Airtel Money',
                            sub: 'Send to 0977 ••• 456',
                            selected: state.selectedPaymentMethod,
                            onTap: () => context.read<AppState>().setPaymentMethod('airtel'),
                          ),
                          const SizedBox(height: 8),
                          _MethodItem(
                            method: 'mtn',
                            icon: Icons.sim_card,
                            iconBg: Colors.amber.withOpacity(0.1),
                            iconColor: const Color(0xFFCC9900),
                            name: 'MTN Mobile Money',
                            sub: 'Send to 096 ••• 012',
                            selected: state.selectedPaymentMethod,
                            onTap: () => context.read<AppState>().setPaymentMethod('mtn'),
                          ),
                          const SizedBox(height: 8),
                          _MethodItem(
                            method: 'bank',
                            icon: Icons.account_balance,
                            iconBg: PamodziColors.blueGl,
                            iconColor: PamodziColors.blue,
                            name: 'Bank Transfer',
                            sub: 'Zanaco · Acc: 100•••2200',
                            selected: state.selectedPaymentMethod,
                            onTap: () => context.read<AppState>().setPaymentMethod('bank'),
                          ),
                          const SizedBox(height: 8),
                          _MethodItem(
                            method: 'deposit',
                            icon: Icons.camera_alt_outlined,
                            iconBg: PamodziColors.greenGl,
                            iconColor: greenColor,
                            name: 'Upload Deposit Slip',
                            sub: 'Photo of bank receipt',
                            selected: state.selectedPaymentMethod,
                            onTap: () => context.read<AppState>().setPaymentMethod('deposit'),
                          ),
                        ],
                      ),
                    ),

                    // Pay button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Tooltip(
                        message: 'Process rent payment',
                        child: PamodziButton(
                          label: _isProcessing ? 'Processing...' : 'Pay K 2,200 securely',
                          icon: _isProcessing ? null : Icons.lock_outline,
                          isLoading: _isProcessing,
                          onTap: () => _processPayment(context, state),
                        ),
                      ),
                    ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          'Protected by Pamodzi · Your landlord will receive a confirmation',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10.5, color: mutedColor),
                        ),
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

class _SummaryRow extends StatelessWidget {
  final String k, v;
  final Color textColor, text2Color, borderColor;
  final TextStyle? valStyle;

  const _SummaryRow({
    required this.k,
    required this.v,
    required this.textColor,
    required this.text2Color,
    required this.borderColor,
    this.valStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: 1))),
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

class _MethodItem extends StatelessWidget {
  final String method, name, sub, selected;
  final IconData icon;
  final Color iconBg, iconColor;
  final VoidCallback onTap;

  const _MethodItem({
    required this.method,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.name,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = method == selected;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final greenColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? greenColor.withOpacity(0.06) : surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? greenColor : borderColor,
            width: isSelected ? 1.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 2),
                  Text(sub, style: TextStyle(fontSize: 11, color: mutedColor)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? greenColor : Colors.transparent,
                border: Border.all(color: isSelected ? greenColor : borderColor, width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── PAY SUCCESS SCREEN ────────────────────────────────────────────────────────
class PaySuccessScreen extends StatelessWidget {
  final String method;
  final String message;
  final String transactionId;
  
  const PaySuccessScreen({
    super.key,
    required this.method,
    required this.message,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? PamodziColors.bgDark : PamodziColors.bg;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final text2Color = isDark ? PamodziColors.text2Dark : PamodziColors.text2;
    final greenColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success ring with animation
              const SuccessAnimation(size: 80),
              const SizedBox(height: 24),
              Text('Payment submitted!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.3)),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: text2Color, height: 1.5),
              ),
              const SizedBox(height: 28),

              // Mini receipt
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _ReceiptMiniRow(k: 'Reference', v: 'CM-PRKL-MAY26', textColor: textColor, text2Color: text2Color, borderColor: borderColor,
                        valStyle: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, color: greenColor, fontSize: 12)),
                    _ReceiptMiniRow(k: 'Amount', v: 'K 2,200.00', textColor: textColor, text2Color: text2Color, borderColor: borderColor,
                        valStyle: TextStyle(fontWeight: FontWeight.w700, color: greenColor, fontSize: 13)),
                    _ReceiptMiniRow(k: 'Status', v: 'Pending confirmation', textColor: textColor, text2Color: text2Color, borderColor: borderColor,
                        valStyle: const TextStyle(color: PamodziColors.amber, fontWeight: FontWeight.w600, fontSize: 12)),
                    _ReceiptMiniRow(k: 'Date', v: '28 Jun 2026', textColor: textColor, text2Color: text2Color, borderColor: Colors.transparent),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              PamodziButton(
                label: 'Back to Home',
                onTap: () {
                  // Pop back to root
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 12),
              PamodziButton(
                label: 'View receipts',
                outlined: true,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptMiniRow extends StatelessWidget {
  final String k, v;
  final Color textColor, text2Color, borderColor;
  final TextStyle? valStyle;

  const _ReceiptMiniRow({
    required this.k,
    required this.v,
    required this.textColor,
    required this.text2Color,
    required this.borderColor,
    this.valStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(color: text2Color, fontSize: 12)),
          Text(v, style: valStyle ?? TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
