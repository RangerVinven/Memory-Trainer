import 'package:flutter/material.dart';
import '../../../models/locus.dart';
import '../../../services/memory_palace_service.dart';

class LocusFormScreen extends StatefulWidget {
  final int palaceId;
  final Locus? locus; // If null, creating new. If provided, editing.
  final int? nextPosition; // Required if creating

  const LocusFormScreen({
    super.key,
    required this.palaceId,
    this.locus,
    this.nextPosition,
  });

  @override
  State<LocusFormScreen> createState() => _LocusFormScreenState();
}

class _LocusFormScreenState extends State<LocusFormScreen> {
  final MemoryPalaceService _service = MemoryPalaceService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _imageController;
  late TextEditingController _infoController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.locus?.name ?? '');
    _imageController = TextEditingController(text: widget.locus?.description ?? '');
    _infoController = TextEditingController(text: widget.locus?.information ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    bool success;
    if (widget.locus == null) {
      // Create
      final newLocus = Locus(
        id: 0,
        name: _nameController.text,
        description: _imageController.text,
        information: _infoController.text,
        position: widget.nextPosition!,
      );
      success = await _service.createLocus(widget.palaceId, newLocus);
    } else {
      // Update
      widget.locus!.name = _nameController.text;
      widget.locus!.description = _imageController.text;
      widget.locus!.information = _infoController.text;
      success = await _service.updateLocus(widget.palaceId, widget.locus!);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true); // Return true to indicate change
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save locus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.locus != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Locus' : 'Add Locus', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3B82F6),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white.withOpacity(_isSaving ? 0.7 : 1.0), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputGroup('Name', _nameController, hint: 'e.g. Front Door', isRequired: true),
              const SizedBox(height: 24),
              _buildInputGroup('Image', _imageController, hint: 'Describe the location...', maxLines: 3),
              const SizedBox(height: 24),
              _buildInputGroup('Information', _infoController, hint: 'What are you memorizing here?', maxLines: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup(String label, TextEditingController controller, {String? hint, int maxLines = 1, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16, color: Color(0xFF334155), height: 1.5),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            validator: isRequired ? (v) => v?.isEmpty == true ? '$label is required' : null : null,
          ),
        ),
      ],
    );
  }
}
