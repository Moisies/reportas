import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';

class ExpenseService {
  static const _storage = FlutterSecureStorage();

  static Future<List<Map<String, dynamic>>> getCompanies() async {
    final response = await ApiClient.instance.get('/companies');
    final data = response.data['data'] as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getProjects({int? companyId}) async {
    final queryParams = companyId != null ? {'company_id': companyId} : null;
    final response = await ApiClient.instance.get(
      '/projects',
      queryParameters: queryParams,
    );
    final data = response.data['data'] as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getExpenseTypes() async {
    final response = await ApiClient.instance.get('/expense-types');
    final data = response.data['data'] as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<String> getProjectCurrency(int projectId) async {
    try {
      final response = await ApiClient.instance.get('/projects/$projectId/currency');
      return response.data['data']['iso_code'] as String? ?? 'USD';
    } catch (_) {
      return 'USD';
    }
  }

  static Future<double> getExchangeRate({
    required String date,
    required String currency,
  }) async {
    if (currency.toUpperCase() == 'USD') return 1.0;
    try {
      final response = await ApiClient.instance.get(
        '/exchange-rate',
        queryParameters: {'date': date, 'currency': currency.toLowerCase()},
      );
      return (response.data['data']['rate'] as num).toDouble();
    } catch (_) {
      return 1.0;
    }
  }

  static Future<Map<String, dynamic>> submitExpense({
    required int projectId,
    required int expenseTypeId,
    required double amount,
    double exchangeRate = 1.0,
    required String expenseDate,
    String description = '',
    required File receiptImage,
  }) async {
    final deviceId = await _storage.read(key: 'device_id') ?? '';

    final formData = FormData.fromMap({
      'project_id':      projectId,
      'expense_type_id': expenseTypeId,
      'amount':          amount,
      'exchange_rate':   exchangeRate,
      'expense_date':    expenseDate,
      'description':     description,
      'device_id':       deviceId,
      'receipt_image':   await MultipartFile.fromFile(
        receiptImage.path,
        filename: 'receipt.jpg',
      ),
    });

    final response = await ApiClient.instance.post(
      '/expenses',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return response.data;
  }

  static Future<List<Map<String, dynamic>>> getMyReceipts() async {
    final response = await ApiClient.instance.get('/expenses/mine');
    final data = response.data['data'] as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<void> deleteReceipt(int expenseId) async {
    await ApiClient.instance.delete('/expenses/$expenseId');
  }

  /// Headers para pedir la imagen del recibo con Image.network / NetworkImage,
  /// que no pasan por el interceptor de ApiClient.
  static Future<Map<String, String>> receiptImageHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String receiptImageUrl(int expenseId) {
    return '${AppConfig.baseUrl}/expenses/$expenseId/receipt-image';
  }
}
