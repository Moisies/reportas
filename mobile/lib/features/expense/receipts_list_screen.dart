import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/app_strings.dart';
import 'expense_service.dart';

class ReceiptsListScreen extends StatefulWidget {
  static const id = '/receipts';
  const ReceiptsListScreen({super.key});

  @override
  State<ReceiptsListScreen> createState() => _ReceiptsListScreenState();
}

class _ReceiptsListScreenState extends State<ReceiptsListScreen> {
  List<Map<String, dynamic>> _receipts = [];
  Map<String, String> _imageHeaders = const {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final headers = await ExpenseService.receiptImageHeaders();
      final receipts = await ExpenseService.getMyReceipts();
      if (!mounted) return;
      setState(() {
        _imageHeaders = headers;
        _receipts = receipts;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = AppStrings.current.loadError;
        _loading = false;
      });
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> receipt) async {
    final s = AppStrings.current;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.deleteReceipt),
        content: Text(s.deleteReceiptConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.delete, style: TextStyle(color: AppConfig.errorColor)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final expenseId = receipt['expense_id'] as int;
    final previous = List<Map<String, dynamic>>.from(_receipts);
    setState(() => _receipts.removeWhere((r) => r['expense_id'] == expenseId));

    try {
      await ExpenseService.deleteReceipt(expenseId);
      if (!mounted) return;
      _showToast(s.receiptDeleted);
    } catch (_) {
      if (!mounted) return;
      setState(() => _receipts = previous);
      _showToast(s.deleteError, isError: true);
    }
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? AppConfig.errorColor : AppConfig.successColor,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return Scaffold(
      backgroundColor: AppConfig.background,
      appBar: AppBar(
        title: Text(s.myReceipts,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: AppConfig.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(s),
      ),
    );
  }

  Widget _buildBody(AppStrings s) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppConfig.primary));
    }

    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Icon(Icons.wifi_off, size: 48, color: AppConfig.textSecondary),
          const SizedBox(height: 12),
          Center(child: Text(_error!, style: const TextStyle(color: AppConfig.textSecondary))),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(onPressed: _load, child: Text(s.retry)),
          ),
        ],
      );
    }

    if (_receipts.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.receipt_long_outlined, size: 56, color: AppConfig.textSecondary),
          const SizedBox(height: 12),
          Center(
            child: Text(s.noReceiptsYet,
                style: const TextStyle(color: AppConfig.textSecondary)),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _receipts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) => _buildReceiptCard(_receipts[index]),
    );
  }

  Widget _buildReceiptCard(Map<String, dynamic> receipt) {
    final amount = (receipt['amount'] as num).toDouble();
    final date = DateTime.tryParse(receipt['expense_date'].toString());
    final dateText = date != null ? DateFormat('dd/MM/yyyy').format(date) : '';

    return Container(
      decoration: BoxDecoration(
        color: AppConfig.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppConfig.borderColor),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              ExpenseService.receiptImageUrl(receipt['expense_id'] as int),
              headers: _imageHeaders,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: AppConfig.background,
                child: const Icon(Icons.broken_image_outlined, color: AppConfig.textSecondary),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 60,
                  height: 60,
                  color: AppConfig.background,
                  child: const Center(
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receipt['expense_type_name'].toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  receipt['project_name'].toString(),
                  style: const TextStyle(color: AppConfig.textSecondary, fontSize: 12.5),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$dateText   •   \$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppConfig.errorColor),
            onPressed: () => _confirmDelete(receipt),
          ),
        ],
      ),
    );
  }
}
