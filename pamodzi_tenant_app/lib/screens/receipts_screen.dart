import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/pdf_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ── RECEIPTS LIST ─────────────────────────────────────────────────────────────
class ReceiptsScreen extends StatelessWidget {
  const ReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? PamodziColors.bgDark : PamodziColors.bg;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(title: 'Receipts'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Tap any receipt to view & download',
                    style: TextStyle(fontSize: 11.5, color: mutedColor)),
              ),
            ),
            Expanded(
              child: state.payments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: mutedColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Receipts Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your payment receipts will appear here',
                            style: TextStyle(
                              fontSize: 13,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: state.payments.length,
                      itemBuilder: (ctx, i) {
                        final p = state.payments[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ReceiptListItem(
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
          ],
        ),
      ),
    );
  }
}

class _ReceiptListItem extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;

  const _ReceiptListItem({required this.payment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;
    final greenColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;

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
                child: const Icon(Icons.receipt_outlined, color: PamodziColors.green, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.month,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
                    const SizedBox(height: 2),
                    Text('${payment.method} · ${payment.date}',
                        style: TextStyle(fontSize: 10, color: mutedColor)),
                    Text(payment.ref, style: TextStyle(fontSize: 9.5, color: mutedColor, fontFamily: 'monospace')),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('K ${payment.amount.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: textColor)),
                  StatusBadge(status: payment.status),
                  const SizedBox(height: 4),
                  Text('PDF ↓', style: TextStyle(fontSize: 9.5, color: greenColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── RECEIPT DETAIL ────────────────────────────────────────────────────────────
class ReceiptDetailScreen extends StatefulWidget {
  final Payment payment;
  const ReceiptDetailScreen({super.key, required this.payment});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  final _pdfService = PdfService();
  bool _isGeneratingPdf = false;

  Future<void> _downloadPdf() async {
    setState(() => _isGeneratingPdf = true);

    try {
      final state = context.read<AppState>();
      final file = await _pdfService.generateReceiptPdf(widget.payment, state.tenant);
      
      setState(() => _isGeneratingPdf = false);

      if (mounted) {
        showToast('Receipt saved to: ${file.path}');
        
        // Optionally share the file immediately
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Receipt for ${widget.payment.month}',
          text: 'Payment receipt for ${widget.payment.month} - K${widget.payment.amount}',
        );
      }
    } catch (e) {
      setState(() => _isGeneratingPdf = false);
      if (mounted) {
        showToast('Error generating PDF: $e');
      }
    }
  }

  Future<void> _shareReceipt() async {
    try {
      final state = context.read<AppState>();
      final file = await _pdfService.generateReceiptPdf(widget.payment, state.tenant);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Receipt for ${widget.payment.month}',
        text: 'Payment receipt for ${widget.payment.month} - K${widget.payment.amount}',
      );
    } catch (e) {
      if (mounted) {
        showToast('Error sharing receipt: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            SubHeader(title: 'Receipt'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Receipt card
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                      ),
                      child: Column(
                        children: [
                          // Receipt head
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: greenColor.withOpacity(0.06),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              border: Border(bottom: BorderSide(color: borderColor)),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('⬡ PAMODZI',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: greenColor, letterSpacing: -0.3)),
                                    Text('Official Payment Receipt',
                                        style: TextStyle(fontSize: 11, color: mutedColor)),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: greenColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('✓ PAID',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                ),
                              ],
                            ),
                          ),

                          // Amount
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                            child: Column(
                              children: [
                                Text('Amount Paid',
                                    style: TextStyle(fontSize: 11, color: mutedColor, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text('K ', style: TextStyle(fontSize: 16, color: mutedColor, fontWeight: FontWeight.w500)),
                                    Text('${widget.payment.amount.toStringAsFixed(0)}',
                                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.04)),
                                    Text('.00', style: TextStyle(fontSize: 16, color: mutedColor, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Receipt lines
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                            child: Column(
                              children: [
                                _ReceiptLine(k: 'Tenant', v: 'Chanda Mulenga', textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                                _ReceiptLine(k: 'Unit', v: 'A3 · Parklands Estate', textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                                _ReceiptLine(k: 'Period', v: widget.payment.month, textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                                _ReceiptLine(k: 'Method', v: widget.payment.method, textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                                _ReceiptLine(k: 'Date & Time', v: '${widget.payment.date}, 09:22 AM', textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                                _ReceiptLine(k: 'Landlord', v: 'James Mwale', textColor: textColor, text2Color: text2Color, borderColor: borderColor),
                                _ReceiptLine(
                                  k: 'Reference',
                                  v: widget.payment.ref,
                                  textColor: textColor,
                                  text2Color: text2Color,
                                  borderColor: Colors.transparent,
                                  valStyle: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, color: greenColor, fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          // Footer buttons
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: borderColor)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _shareReceipt,
                                    icon: const Icon(Icons.share, size: 15),
                                    label: const Text('Share'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: textColor,
                                      side: BorderSide(color: borderColor),
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isGeneratingPdf ? null : _downloadPdf,
                                    icon: _isGeneratingPdf 
                                        ? const SizedBox(
                                            width: 15,
                                            height: 15,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Icon(Icons.download, size: 15),
                                    label: Text(_isGeneratingPdf ? 'Generating...' : 'PDF'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: greenColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    
                    // QR Code for verification
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            QrImageView(
                              data: 'https://pamodzi.zm/receipt/${widget.payment.ref}',
                              version: QrVersions.auto,
                              size: 150,
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scan to verify',
                              style: TextStyle(
                                fontSize: 11,
                                color: mutedColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      'Scan QR or visit pamodzi.zm/receipt/${widget.payment.ref} to verify',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.5, color: mutedColor),
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

class _ReceiptLine extends StatelessWidget {
  final String k, v;
  final Color textColor, text2Color, borderColor;
  final TextStyle? valStyle;

  const _ReceiptLine({
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
      padding: const EdgeInsets.symmetric(vertical: 9),
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
