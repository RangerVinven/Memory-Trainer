import 'package:flutter/material.dart';
import '../../../models/locus.dart';
import '../../../services/memory_palace_service.dart';
import 'locus_form_screen.dart';

class LocusDetailScreen extends StatefulWidget {
  final int palaceId;
  final Locus locus;

  const LocusDetailScreen({
    super.key,
    required this.palaceId,
    required this.locus,
  });

  @override
  State<LocusDetailScreen> createState() => _LocusDetailScreenState();
}

class _LocusDetailScreenState extends State<LocusDetailScreen> {
  late Locus _locus;
  final MemoryPalaceService _service = MemoryPalaceService();

  @override
  void initState() {
    super.initState();
    _locus = widget.locus;
  }

  Future<void> _edit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocusFormScreen(
          palaceId: widget.palaceId,
          locus: _locus,
        ),
      ),
    );

    if (result == true) {
      setState(() {}); // Refresh UI with updated object
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Locus?'),
        content: const Text('Are you sure you want to remove this locus?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _service.deleteLocus(widget.palaceId, _locus.id);
      if (mounted) Navigator.pop(context, true); // Return true to refresh parent list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(_locus.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3B82F6),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Image', _locus.description),
            const SizedBox(height: 24),
            _buildSection('Information', _locus.information),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            content != null && content.isNotEmpty ? content : 'Blank',
            style: TextStyle(
              fontSize: 16, 
              color: content != null && content.isNotEmpty ? const Color(0xFF334155) : const Color(0xFF94A3B8),
              fontStyle: content != null && content.isNotEmpty ? FontStyle.normal : FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
