import 'package:flutter/material.dart';
import '../../../models/memory_palace.dart';
import '../../../models/locus.dart';
import '../../../services/memory_palace_service.dart';
import 'locus_form_screen.dart';
import 'locus_detail_screen.dart';

class MemoryPalaceDetailScreen extends StatefulWidget {
  final int palaceId;
  final String palaceName;

  const MemoryPalaceDetailScreen({
    super.key,
    required this.palaceId,
    required this.palaceName,
  });

  @override
  State<MemoryPalaceDetailScreen> createState() => _MemoryPalaceDetailScreenState();
}

class _MemoryPalaceDetailScreenState extends State<MemoryPalaceDetailScreen> {
  final MemoryPalaceService _service = MemoryPalaceService();
  MemoryPalace? _palace;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPalace();
  }

  Future<void> _loadPalace() async {
    final palace = await _service.getPalace(widget.palaceId);
    if (mounted) {
      setState(() {
        _palace = palace;
        _isLoading = false;
      });
    }
  }

  Future<void> _createLocus() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocusFormScreen(
          palaceId: widget.palaceId,
          nextPosition: (_palace?.loci.length ?? 0) + 1,
        ),
      ),
    );

    if (result == true) {
      _loadPalace();
    }
  }

  Future<void> _onLocusTap(Locus locus) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocusDetailScreen(
          palaceId: widget.palaceId,
          locus: locus,
        ),
      ),
    );

    if (result == true) {
      // Returned from delete or just generic refresh needed
      _loadPalace();
    } else {
      // Even if just viewing/editing, refreshing ensures we show latest data
      _loadPalace(); 
    }
  }

  void _onReorder(int oldIndex, int newIndex) async {
    if (_palace == null) return;
    
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _palace!.loci.removeAt(oldIndex);
      _palace!.loci.insert(newIndex, item);
    });

    // Sync with server (using new position, 1-based index)
    // Actually, acts_as_list handles reordering relative to others usually,
    // but the API implementation uses `insert_at` which takes a 1-based position.
    final locus = _palace!.loci[newIndex];
    await _service.reorderLocus(widget.palaceId, locus.id, newIndex + 1);
  }

  Future<void> _editPalace() async {
    if (_palace == null) return;
    final nameController = TextEditingController(text: _palace!.name);
    final descriptionController = TextEditingController(text: _palace!.description);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Palace Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
               final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete Palace?'),
                  content: const Text('This will delete all loci inside.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                Navigator.pop(context); // Close edit dialog
                await _service.deletePalace(widget.palaceId);
                if (mounted) Navigator.pop(context); // Go back to list
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              _palace!.name = nameController.text;
              _palace!.description = descriptionController.text;
              Navigator.pop(context);
              await _service.updatePalace(_palace!);
              setState(() {}); // refresh title
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(_palace?.name ?? widget.palaceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3B82F6),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editPalace),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createLocus,
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _palace == null
              ? const Center(child: Text('Error loading palace'))
              : _palace!.loci.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No loci yet.', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _createLocus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                              elevation: 2,
                            ),
                            child: const Text('Add Locus', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _palace!.loci.length,
                      onReorder: _onReorder,
                      itemBuilder: (context, index) {
                        final locus = _palace!.loci[index];
                        return Card(
                          key: ValueKey(locus.id),
                          color: Colors.white,
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                              child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
                            ),
                            title: Text(locus.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: locus.description != null && locus.description!.isNotEmpty
                                ? Text(locus.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                                : null,
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
                            onTap: () => _onLocusTap(locus),
                          ),
                        );
                      },
                    ),
    );
  }
}
