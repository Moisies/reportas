import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/app_strings.dart';
import '../auth/auth_service.dart';
import '../auth/biometric_lock_screen.dart';
import '../expense/expense_service.dart';
import '../expense/photo_preview_screen.dart';
import '../expense/receipts_list_screen.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  static const id = '/receipt';
  const ReceiptScreen({super.key});

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  final _amountCtrl   = TextEditingController();
  final _exchangeCtrl = TextEditingController(text: '1.00');
  final _descCtrl     = TextEditingController();

  List<Map<String, dynamic>> _companies    = [];
  List<Map<String, dynamic>> _allProjects  = []; // todos sin filtro
  List<Map<String, dynamic>> _projects     = []; // los que se muestran
  List<Map<String, dynamic>> _expenseTypes = [];

  int?     _selectedCompanyId;
  int?     _selectedProjectId;
  int?     _selectedTypeId;
  DateTime _selectedDate    = DateTime.now();
  File?    _receiptImage;
  bool     _loading         = false;
  bool     _initializing    = true;
  bool     _fetchingRate    = false;
  String?  _initError;
  String   _currencyCode    = 'USD';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ExpenseService.getCompanies(),
        ExpenseService.getProjects(),
        ExpenseService.getExpenseTypes(),
      ]);
      if (mounted) {
        setState(() {
          _companies    = results[0];
          _allProjects  = results[1];
          _projects     = results[1]; // inicialmente todos
          _expenseTypes = results[2];
          _initializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError    = AppStrings.current.loadError;
          _initializing = false;
        });
      }
    }
  }

  void _onCompanyChanged(int? companyId) {
    setState(() {
      _selectedCompanyId = companyId;
      _selectedProjectId = null;
      _currencyCode      = 'USD';
      _exchangeCtrl.text = '1.00';
      // Filtro local — sin API call
      _projects = companyId == null
          ? _allProjects
          : _allProjects.where((p) =>
              int.parse(p['CompanyId'].toString()) == companyId).toList();
    });
  }

  Future<void> _onProjectChanged(int? projectId) async {
    if (projectId == null) return;
    setState(() {
      _selectedProjectId = projectId;
      _currencyCode      = 'USD';
      _exchangeCtrl.text = '1.00';
    });

    final iso = await ExpenseService.getProjectCurrency(projectId);
    if (!mounted) return;
    setState(() => _currencyCode = iso);

    await _fetchRate();
  }

  Future<void> _onDateChanged(DateTime date) async {
    setState(() => _selectedDate = date);
    await _fetchRate();
  }

  Future<void> _fetchRate() async {
    if (_selectedProjectId == null) return;
    if (_currencyCode == 'USD') {
      setState(() => _exchangeCtrl.text = '1.00');
      return;
    }

    setState(() => _fetchingRate = true);
    final rate = await ExpenseService.getExchangeRate(
      date:     DateFormat('yyyy-MM-dd').format(_selectedDate),
      currency: _currencyCode,
    );
    if (mounted) {
      setState(() {
        _exchangeCtrl.text = rate.toStringAsFixed(4);
        _fetchingRate      = false;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked == null) return;

    final fixedFile = await _fixOrientation(File(picked.path));

    // La app de cámara nativa ya deja confirmar/repetir la foto,
    // así que no duplicamos ese paso aquí. La miniatura resultante
    // sí abre una vista previa propia para mantener o cambiar la foto.
    if (mounted) {
      setState(() => _receiptImage = fixedFile);
    }
  }

  /// Aplica físicamente la rotación indicada en el EXIF a los píxeles de la
  /// imagen y la guarda ya derecha, para que se vea igual en cualquier
  /// visor (PC, galería, etc.), respete o no la orientación EXIF.
  Future<File> _fixOrientation(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return file;

    final oriented = img.bakeOrientation(decoded);
    await file.writeAsBytes(img.encodeJpg(oriented, quality: 85));
    return file;
  }

  Future<void> _reviewPhoto() async {
    if (_receiptImage == null) return;

    final keep = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoPreviewScreen(image: _receiptImage!),
      ),
    );

    if (keep == false && mounted) {
      await _pickPhoto();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppConfig.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) await _onDateChanged(picked);
  }

  Future<void> _submit() async {
    final s = AppStrings.current;
    if (_selectedProjectId == null) return _showToast(s.selectProject, isError: true);
    if (_selectedTypeId == null)    return _showToast(s.selectExpenseType, isError: true);
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return _showToast(s.enterValidAmount, isError: true);
    if (_receiptImage == null)      return _showToast(s.takeReceiptPhoto, isError: true);

    setState(() => _loading = true);
    try {
      final result = await ExpenseService.submitExpense(
        projectId:     _selectedProjectId!,
        expenseTypeId: _selectedTypeId!,
        amount:        amount,
        exchangeRate:  double.tryParse(_exchangeCtrl.text) ?? 1.0,
        expenseDate:   DateFormat('yyyy-MM-dd').format(_selectedDate),
        description:   _descCtrl.text.trim(),
        receiptImage:  _receiptImage!,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        _showToast(AppStrings.current.expenseRegistered);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) _resetForm();
      } else {
        _showToast(result['message'] ?? AppStrings.current.registrationError, isError: true);
      }
    } catch (e) {
      if (mounted) _showToast(AppStrings.current.sendError, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetForm() {
    _amountCtrl.clear();
    _exchangeCtrl.text = '1.00';
    _descCtrl.clear();
    setState(() {
      _selectedCompanyId = null;
      _selectedProjectId = null;
      _selectedTypeId    = null;
      _selectedDate      = DateTime.now();
      _receiptImage      = null;
      _currencyCode      = 'USD';
      _projects          = _allProjects; // restaura todos los proyectos
    });
  }

  void _showToast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? AppConfig.errorColor : AppConfig.successColor,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  Future<void> _logout() async {
    await AuthService.logout(); // solo borra auth_token, guarda biometric_token
    if (mounted) Navigator.pushReplacementNamed(context, BiometricLockScreen.id);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _exchangeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.background,
      appBar: AppBar(
        title: Text(AppStrings.current.registerExpense,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: AppConfig.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReceiptsListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator(color: AppConfig.primary))
          : _initError != null
              ? _buildError()
              : _buildForm(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off, size: 48, color: AppConfig.textSecondary),
          const SizedBox(height: 12),
          Text(_initError!, textAlign: TextAlign.center,
              style: const TextStyle(color: AppConfig.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() { _initializing = true; _initError = null; });
              _loadData();
            },
            child: Text(AppStrings.current.retry),
          ),
        ]),
      ),
    );
  }

  Widget _buildForm() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            // Empresa (opcional — filtra proyectos)
            _buildNullableDropdown(
              label: AppStrings.current.companyOptional,
              value: _selectedCompanyId,
              items: _companies.map((c) => DropdownMenuItem<int>(
                value: int.parse(c['CompanyId'].toString()),
                child: Text(c['CompanyName'].toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)),
              )).toList(),
              onChanged: _onCompanyChanged,
              icon: Icons.business_outlined,
            ),
            const SizedBox(height: 8),

            // Proyecto (filtrado localmente por empresa)
            _buildDropdown(
              label: AppStrings.current.project,
              value: _selectedProjectId,
              items: _projects.map((p) => DropdownMenuItem<int>(
                value: int.parse(p['ProjectId'].toString()),
                child: Text(p['ProjectName'].toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13)),
              )).toList(),
              onChanged: _onProjectChanged,
              icon: Icons.folder_outlined,
            ),
            const SizedBox(height: 8),

            // Tipo de gasto
            _buildDropdown(
              label: AppStrings.current.expenseType,
              value: _selectedTypeId,
              items: _expenseTypes.map((t) => DropdownMenuItem<int>(
                value: int.parse(t['ExpenseTypeId'].toString()),
                child: Text(t['DisplayName'].toString(),
                    style: const TextStyle(fontSize: 13)),
              )).toList(),
              onChanged: (v) => setState(() => _selectedTypeId = v),
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 8),

            // Monto (la tasa de cambio se sigue calculando y enviando internamente,
            // pero ya no se muestra al usuario)
            _buildTextField(
              controller: _amountCtrl,
              label: AppStrings.current.amount,
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
            ),
            const SizedBox(height: 8),

            // Fecha (fila completa)
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: TextEditingController(
                    text: DateFormat('dd/MM/yyyy').format(_selectedDate),
                  ),
                  label: AppStrings.current.expenseDate,
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Descripción — multilínea, más alta
            _buildDescriptionField(),
            const SizedBox(height: 8),

            // Sección de foto — más grande
            _buildPhotoSection(),

            const Spacer(),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text(AppStrings.current.registerExpense,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppConfig.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppConfig.borderColor),
      ),
      child: TextField(
        controller: _descCtrl,
        maxLength: 255,
        maxLines: 3,
        minLines: 3,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: AppConfig.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: AppStrings.current.descriptionLabel(_descCtrl.text.length),
          labelStyle: const TextStyle(color: AppConfig.textSecondary, fontSize: 13),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 48),
            child: Icon(Icons.notes_outlined, color: AppConfig.primary, size: 20),
          ),
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Botón cámara — más alto
        Expanded(
          child: SizedBox(
            height: 72,
            child: ElevatedButton(
              onPressed: _loading ? null : _pickPhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: _receiptImage != null
                    ? AppConfig.successColor
                    : AppConfig.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    _receiptImage == null ? AppStrings.current.takePhoto : AppStrings.current.changePhoto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Thumbnail grande si hay foto
        if (_receiptImage != null) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _reviewPhoto,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _receiptImage!,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ] else ...[
          // Placeholder cuando no hay foto
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppConfig.borderColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.image_outlined,
                size: 32, color: AppConfig.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
    required IconData icon,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppConfig.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppConfig.borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: value,
          hint: Row(children: [
            Icon(icon, size: 18, color: AppConfig.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppConfig.textSecondary, fontSize: 14)),
          ]),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppConfig.textSecondary),
          items: items,
          onChanged: onChanged,
          style: const TextStyle(color: AppConfig.textPrimary, fontSize: 13),
        ),
      ),
    );
  }

  // Dropdown que permite null (para empresa opcional)
  Widget _buildNullableDropdown({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
    required IconData icon,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppConfig.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppConfig.borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: value,
          hint: Row(children: [
            Icon(icon, size: 18, color: AppConfig.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppConfig.textSecondary, fontSize: 14)),
          ]),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppConfig.textSecondary),
          items: [
            // Opción para limpiar filtro
            DropdownMenuItem<int>(
              value: null,
              child: Text(AppStrings.current.allCompanies,
                  style: const TextStyle(color: AppConfig.textSecondary, fontSize: 13,
                      fontStyle: FontStyle.italic)),
            ),
            ...items,
          ],
          onChanged: onChanged,
          style: const TextStyle(color: AppConfig.textPrimary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      readOnly: readOnly,
      onChanged: maxLength != null ? (_) => setState(() {}) : null,
      style: const TextStyle(color: AppConfig.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppConfig.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon,
            color: readOnly ? AppConfig.textSecondary : AppConfig.primary, size: 20),
        counterText: '',
        filled: true,
        fillColor: readOnly ? const Color(0xFFF0F0F0) : AppConfig.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppConfig.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppConfig.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: readOnly ? AppConfig.borderColor : AppConfig.primary,
            width: readOnly ? 1 : 1.5,
          ),
        ),
      ),
    );
  }
}
