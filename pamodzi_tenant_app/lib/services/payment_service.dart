import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Payment service to handle mobile money and bank transfers
class PaymentService {
  // In production, this would be your actual payment gateway API
  static const String _apiBaseUrl = 'https://api.pamodzi.zm/v1';

  /// Process Airtel Money payment
  Future<PaymentResult> processAirtelMoney({
    required double amount,
    required String phoneNumber,
    required String reference,
    required String description,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // In production, call actual Airtel Money API
      // final response = await http.post(
      //   Uri.parse('$_apiBaseUrl/payments/airtel'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'amount': amount,
      //     'phone': phoneNumber,
      //     'reference': reference,
      //     'description': description,
      //   }),
      // );

      // For demo: simulate success
      return PaymentResult(
        success: true,
        transactionId: 'AM${DateTime.now().millisecondsSinceEpoch}',
        message: 'Payment initiated. Please approve on your phone.',
        reference: reference,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Payment failed: ${e.toString()}',
        reference: reference,
      );
    }
  }

  /// Process MTN Mobile Money payment
  Future<PaymentResult> processMtnMomo({
    required double amount,
    required String phoneNumber,
    required String reference,
    required String description,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      // In production, call actual MTN MoMo API
      return PaymentResult(
        success: true,
        transactionId: 'MTN${DateTime.now().millisecondsSinceEpoch}',
        message: 'Payment initiated. Check your phone for approval.',
        reference: reference,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Payment failed: ${e.toString()}',
        reference: reference,
      );
    }
  }

  /// Process Bank Transfer
  Future<PaymentResult> processBankTransfer({
    required double amount,
    required String reference,
    required String accountNumber,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // In production, verify bank transfer details
      return PaymentResult(
        success: true,
        transactionId: 'BT${DateTime.now().millisecondsSinceEpoch}',
        message: 'Bank transfer details recorded. Transfer to:\nZanaco Bank\nAcc: 1001234002200\nRef: $reference',
        reference: reference,
        requiresManualConfirmation: true,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Failed to process bank transfer: ${e.toString()}',
        reference: reference,
      );
    }
  }

  /// Verify payment status (for checking if payment was completed)
  Future<bool> verifyPayment(String transactionId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // In production, call verification API
      // final response = await http.get(
      //   Uri.parse('$_apiBaseUrl/payments/verify/$transactionId'),
      // );
      
      // For demo: return true
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Payment result model
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String message;
  final String reference;
  final bool requiresManualConfirmation;

  PaymentResult({
    required this.success,
    this.transactionId,
    required this.message,
    required this.reference,
    this.requiresManualConfirmation = false,
  });
}
