import 'package:flutter/material.dart';
import '../../../models/memory_palace.dart';
import '../../../services/memory_palace_service.dart';
import 'memory_palace_detail_screen.dart';

class MemoryPalacesListScreen extends StatefulWidget {
  const MemoryPalacesListScreen({super.key});

  @override
  State<MemoryPalacesListScreen> createState() => _MemoryPalacesListScreenState();
}

class _MemoryPalacesListScreenState extends State<MemoryPalacesListScreen> {
  final MemoryPalaceService _service = MemoryPalaceService();
  List<MemoryPalace> _palaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPalaces();
  }

  Future<void> _loadPalaces() async {
    final palaces = await _service.getPalaces();
    if (mounted) {
      setState(() {
        _palaces = palaces;
        _isLoading = false;
      });
    }
  }

  Future<void> _createPalace() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Memory Palace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              autofocus: true,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final newPalace = MemoryPalace(
                  id: 0, // Placeholder, ignored by create
                  name: nameController.text,
                  description: descriptionController.text,
                );
                Navigator.pop(context);
                final success = await _service.createPalace(newPalace);
                if (success) {
                  _loadPalaces();
                }
              }
            },
            child: const Text('Create'),
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
        title: const Text('Memory Palaces', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3B82F6),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _createPalace,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _palaces.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No palaces found.', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _createPalace,
                        child: const Text('Create Your First Palace'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _palaces.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final palace = _palaces[index];
                    return Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          palace.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF334155)),
                        ),
                        subtitle: palace.description != null && palace.description!.isNotEmpty
                            ? Text(palace.description!, style: const TextStyle(color: Color(0xFF64748B)))
                            : null,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MemoryPalaceDetailScreen(palaceId: palace.id, palaceName: palace.name),
                            ),
                          );
                          _loadPalaces(); // Refresh on return
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
