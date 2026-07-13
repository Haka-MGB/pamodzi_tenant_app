import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr_flutter;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';

/// Service to generate PDF documents for receipts and lease agreements
class PdfService {
  /// Generate receipt PDF
  Future<File> generateReceiptPdf(Payment payment, Tenant tenant) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#1A4D2E'),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '⬡ PAMODZI',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Official Payment Receipt',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#4ADE80'),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Text(
                        '✓ PAID',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Amount
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'AMOUNT PAID',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'K ${payment.amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 36,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Details table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    _buildDetailRow('Tenant', tenant.name),
                    _buildDetailRow('Unit', tenant.unit),
                    _buildDetailRow('Estate', tenant.estate),
                    _buildDetailRow('Period', payment.month),
                    _buildDetailRow('Payment Method', payment.method),
                    _buildDetailRow('Date & Time', '${payment.date}, ${DateFormat('HH:mm').format(DateTime.now())}'),
                    _buildDetailRow('Reference', payment.ref, isLast: true),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Verification section
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'VERIFICATION',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'pamodzi.zm/receipt/${payment.ref}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#1A4D2E'),
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Scan QR code in app or visit URL above to verify',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 30),

              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'This is an official receipt from Pamodzi Property Management',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Receipt ID: ${payment.ref}',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF to device
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/receipt_${payment.ref}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Generate lease agreement PDF
  Future<File> generateLeasePdf(Lease lease, Tenant tenant) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#1A4D2E'),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '⬡ PAMODZI',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Residential Tenancy Agreement',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Agreement details
            pw.Text(
              'TENANCY AGREEMENT',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),

            _buildLeaseSection('Parties to the Agreement', [
              'Landlord: ${lease.landlord}',
              'Tenant: ${lease.tenantName}',
              'Property: ${lease.property}',
            ]),

            _buildLeaseSection('Lease Terms', [
              'Start Date: ${lease.startDate}',
              'End Date: ${lease.endDate}',
              'Monthly Rent: K ${lease.monthlyRent.toStringAsFixed(2)}',
              'Due Date: ${lease.dueDate}',
              'Security Deposit: K ${lease.deposit.toStringAsFixed(2)}',
            ]),

            _buildLeaseSection('Payment Terms', [
              'Rent is due on the ${lease.dueDate}',
              'Late payments will incur a fee of K ${lease.lateFee.toStringAsFixed(0)} after ${lease.lateDays} days',
              'Payments can be made via mobile money or bank transfer',
            ]),

            _buildLeaseSection('Contact Information', [
              'Landlord Email: ${lease.landlordEmail}',
              'Tenant Email: ${tenant.email}',
              'Tenant Phone: ${tenant.phone}',
            ]),

            pw.SizedBox(height: 30),

            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSignatureBox('Landlord Signature', lease.landlord),
                _buildSignatureBox('Tenant Signature', lease.tenantName),
              ],
            ),

            pw.SizedBox(height: 30),

            // Footer
            pw.Center(
              child: pw.Text(
                'Generated on ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ];
        },
      ),
    );

    // Save PDF to device
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/lease_${tenant.name.replaceAll(' ', '_')}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Helper methods
  pw.Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: pw.BoxDecoration(
        border: isLast
            ? null
            : const pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300),
              ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLeaseSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        ...items.map((item) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10, bottom: 5),
              child: pw.Text(
                '• $item',
                style: const pw.TextStyle(fontSize: 11),
              ),
            )),
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildSignatureBox(String label, String name) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 200,
          height: 60,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          name,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }
}
