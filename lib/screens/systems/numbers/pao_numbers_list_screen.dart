import 'package:flutter/material.dart';
import '../../../models/pao_number.dart';
import '../../../models/pao_digit.dart';
import '../../../services/pao_service.dart';

class PaoNumbersListScreen extends StatefulWidget {
  const PaoNumbersListScreen({super.key});

  @override
  State<PaoNumbersListScreen> createState() => _PaoNumbersListScreenState();
}

class _PaoNumbersListScreenState extends State<PaoNumbersListScreen> {
  final PaoService _paoService = PaoService();
  final ScrollController _scrollController = ScrollController();
  
  List<PaoNumber> _numbers = [];
  List<PaoDigit> _digits = [];
  bool _isLoading = true;

  // Grid layout constants
  final int _crossAxisCount = 2;
  final double _childAspectRatio = 0.8;
  final double _crossAxisSpacing = 16.0;
  final double _mainAxisSpacing = 16.0;
  final double _padding = 16.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final numbers = await _paoService.getNumbers();
    final digits = await _paoService.getDigits();
    
    if (mounted) {
      setState(() {
        _numbers = numbers;
        _digits = digits;
        _isLoading = false;
      });
    }
  }

  // Calculate where to scroll to
  void _jumpToDecade(int decadeStart) {
    if (_numbers.isEmpty) return;

    // Calculate heights
    final double screenWidth = MediaQuery.of(context).size.width;
    final double gridWidth = screenWidth - (_padding * 2);
    final double itemWidth = (gridWidth - (_crossAxisSpacing * (_crossAxisCount - 1))) / _crossAxisCount;
    final double itemHeight = itemWidth / _childAspectRatio;
    final double rowHeight = itemHeight + _mainAxisSpacing;

    // 1. Height of Digits Section
    // Digits count = 10. Rows = ceil(10/2) = 5.
    final double digitsHeight = (5 * rowHeight); 
    
    // 2. Headers Height (approximate, based on widget definition)
    const double headersHeight = 60.0 + 60.0; // Two 60px headers (Digits title + Numbers title)
    
    // 3. Jump Bar Height (approximate)
    const double jumpBarHeight = 60.0;

    // 4. Target Row in Numbers Grid
    // Decade start (e.g. 30). Index = 30. Row = 30 / 2 = 15.
    final int targetRow = (decadeStart / _crossAxisCount).floor();
    final double numbersOffset = targetRow * rowHeight;

    final double totalOffset = digitsHeight + headersHeight + jumpBarHeight + numbersOffset;

    _scrollController.animateTo(
      totalOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _editNumber(PaoNumber number) async {
    final personController = TextEditingController(text: number.person);
    final actionController = TextEditingController(text: number.action);
    final objectController = TextEditingController(text: number.object);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${number.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: personController, decoration: const InputDecoration(labelText: 'Person')),
            TextField(controller: actionController, decoration: const InputDecoration(labelText: 'Action')),
            TextField(controller: objectController, decoration: const InputDecoration(labelText: 'Object')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                number.person = personController.text;
                number.action = actionController.text;
                number.object = objectController.text;
              });
              Navigator.pop(context);
              await _paoService.updateNumbers([number]);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _editDigit(PaoDigit digit) async {
    final personController = TextEditingController(text: digit.person);
    final actionController = TextEditingController(text: digit.action);
    final objectController = TextEditingController(text: digit.object);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${digit.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: personController, decoration: const InputDecoration(labelText: 'Person')),
            TextField(controller: actionController, decoration: const InputDecoration(labelText: 'Action')),
            TextField(controller: objectController, decoration: const InputDecoration(labelText: 'Object')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                digit.person = personController.text;
                digit.action = actionController.text;
                digit.object = objectController.text;
              });
              Navigator.pop(context);
              await _paoService.updateDigits([digit]);
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
        title: const Text('PAO Numbers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3B82F6),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(_padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Jump Bar
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      separatorBuilder: (c, i) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final int decade = index * 10;
                        final String label = decade.toString().padLeft(2, '0');
                        return ActionChip(
                          label: Text(label),
                          backgroundColor: Colors.white,
                          onPressed: () => _jumpToDecade(decade),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Digits Header
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Digits (0-9)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                  ),

                  // Digits Grid
                  _buildGrid(_digits, shrinkWrap: true),

                  const SizedBox(height: 24),

                  // Numbers Header
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Numbers (00-99)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                  ),

                  // Numbers Grid
                  _buildGrid(_numbers, shrinkWrap: true),
                  
                  // Bottom padding for easier scrolling
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildGrid(List<dynamic> items, {bool shrinkWrap = false}) {
    return GridView.builder(
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        childAspectRatio: _childAspectRatio,
        crossAxisSpacing: _crossAxisSpacing,
        mainAxisSpacing: _mainAxisSpacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            if (item is PaoNumber) _editNumber(item);
            if (item is PaoDigit) _editDigit(item);
          },
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const Divider(),
                  _buildFieldRow(Icons.person, item.person),
                  const SizedBox(height: 4),
                  _buildFieldRow(Icons.directions_run, item.action),
                  const SizedBox(height: 4),
                  _buildFieldRow(Icons.category, item.object),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldRow(IconData icon, String? value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value?.isNotEmpty == true ? value! : '-',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
