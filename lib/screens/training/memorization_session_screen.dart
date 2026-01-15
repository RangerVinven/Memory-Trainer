import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/training_service.dart';

class MemorizationSessionScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;

  const MemorizationSessionScreen({super.key, required this.sessionData});

  @override
  State<MemorizationSessionScreen> createState() => _MemorizationSessionScreenState();
}

class _MemorizationSessionScreenState extends State<MemorizationSessionScreen> {
  final TrainingService _service = TrainingService();
  
  // Session Data
  late int _sessionId;
  late String _type;
  late int _batchSize;
  late List<String> _items;
  
  // State
  // 0: Memorizing, 1: Recalling, 2: Results
  int _phase = 0; 
  
  // Memorization State
  int _currentBatchIndex = 0;
  Timer? _timer;
  int _elapsedSeconds = 0;

  // Recall State
  List<String> _recalledItems = [];
  String _currentInput = '';
  String? _selectedSuit;

  // Results State
  Map<String, dynamic>? _results;

  @override
  void initState() {
    super.initState();
    _sessionId = widget.sessionData['id'];
    _type = widget.sessionData['training_type'];
    _batchSize = widget.sessionData['batch_size'];
    
    // Parse items
    String data = widget.sessionData['training_data'];
    if (_type == 'number') {
      _items = [];
      for (int i = 0; i < data.length; i += 2) {
        if (i + 1 < data.length) {
          _items.add(data.substring(i, i + 2));
        } else {
          _items.add(data.substring(i));
        }
      }
    } else {
      _items = data.split(',');
    }

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsedSeconds++);
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // --- Phase 1: Memorization ---

  void _nextBatch() {
    int nextIndex = _currentBatchIndex + _batchSize;
    if (nextIndex >= _items.length) {
      _finishMemorization();
    } else {
      setState(() => _currentBatchIndex = nextIndex);
    }
  }

  Future<void> _finishMemorization() async {
    _timer?.cancel();
    await _service.updateSession(sessionId: _sessionId, durationSeconds: _elapsedSeconds);
    
    setState(() {
      _phase = 1;
      _recalledItems = [];
    });
  }

  // --- Phase 2: Recall ---
  
  void _submitRecall() async {
    String recallData;
    if (_type == 'number') {
      recallData = _recalledItems.join();
    } else {
      recallData = _recalledItems.join(',');
    }

    final result = await _service.updateSession(sessionId: _sessionId, recallData: recallData);
    
    if (mounted && result != null) {
      setState(() {
        _phase = 2;
        _results = result;
      });
    }
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(_getTitle(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3B82F6),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: _phase == 0 ? [
          Center(child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(_formatTime(_elapsedSeconds), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ))
        ] : null,
      ),
      body: _buildBody(),
    );
  }

  String _getTitle() {
    switch (_phase) {
      case 0: return 'Memorize';
      case 1: return 'Recall';
      case 2: return 'Results';
      default: return '';
    }
  }

  Widget _buildBody() {
    switch (_phase) {
      case 0: return _buildMemorizationView();
      case 1: return _buildRecallView();
      case 2: return _buildResultsView();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildMemorizationView() {
    int endIndex = (_currentBatchIndex + _batchSize < _items.length) ? _currentBatchIndex + _batchSize : _items.length;
    List<String> currentBatch = _items.sublist(_currentBatchIndex, endIndex);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: currentBatch.map((item) => _buildItemCard(item)).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextBatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                endIndex == _items.length ? 'Finish Memorizing' : 'Next Batch',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecallView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Recalled: ${_recalledItems.length} / ${_items.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._recalledItems.map((item) => Chip(
                  label: Text(_formatRecallItem(item)),
                  onDeleted: () {
                    setState(() {
                      // Note: Deleting from middle might shift sequence logic if strictly ordered
                      // But for simplicity allowing removal
                      _recalledItems.remove(item);
                    });
                  },
                  deleteIcon: const Icon(Icons.close, size: 14),
                )),
                if (_currentInput.isNotEmpty || _selectedSuit != null)
                  Chip(
                    label: Text(_formatRecallItem(_selectedSuit != null ? _selectedSuit! : _currentInput) + (_type == 'card' ? '?' : '')),
                    backgroundColor: Colors.grey.shade200,
                  )
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: _type == 'card' ? _buildCardInput() : _buildNumberInput(),
        ),
      ],
    );
  }

  Widget _buildNumberInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _currentInput = '';
                  if (_recalledItems.isNotEmpty) _recalledItems.removeLast();
                });
              }, 
              child: const Text('Backspace', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: _recalledItems.length >= _items.length ? _submitRecall : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
              child: const Text('Submit'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 5,
          childAspectRatio: 1.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(10, (index) {
            return OutlinedButton(
              onPressed: () => _onNumberInput(index.toString()),
              child: Text('$index', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            );
          }),
        ),
      ],
    );
  }

  void _onNumberInput(String digit) {
    setState(() {
      _currentInput += digit;
      if (_currentInput.length == 2) {
        _recalledItems.add(_currentInput);
        _currentInput = '';
      }
    });
  }

  Widget _buildCardInput() {
    final suits = ['S', 'H', 'C', 'D'];
    final ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedSuit = null;
                  if (_recalledItems.isNotEmpty) _recalledItems.removeLast();
                });
              }, 
              child: const Text('Backspace', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: _recalledItems.length >= _items.length ? _submitRecall : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
              child: const Text('Submit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: suits.map((s) {
            String icon = '';
            Color color = Colors.black;
            if (s == 'S') icon = '♠️';
            if (s == 'H') { icon = '♥️'; color = Colors.red; }
            if (s == 'C') icon = '♣️';
            if (s == 'D') { icon = '♦️'; color = Colors.red; }

            bool isSelected = _selectedSuit == s;

            return GestureDetector(
              onTap: () => setState(() => _selectedSuit = s),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.transparent,
                  border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(icon, style: TextStyle(fontSize: 24, color: color)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 7, 
          childAspectRatio: 1.0,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          physics: const NeverScrollableScrollPhysics(),
          children: ranks.map((r) {
            return OutlinedButton(
              onPressed: _selectedSuit == null ? null : () => _onCardInput(r),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white,
              ),
              child: Text(r, style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _onCardInput(String rank) {
    if (_selectedSuit == null) return;
    setState(() {
      _recalledItems.add('$rank$_selectedSuit');
      _selectedSuit = null;
    });
  }

  Widget _buildItemCard(String text) {
    bool isRed = false;
    if (_type == 'card') {
      isRed = text.contains('H') || text.contains('D');
    }
    
    String display = text;
    if (_type == 'card') {
      String r = text.substring(0, text.length - 1);
      String s = text.substring(text.length - 1);
      if (s == 'S') s = '♠️';
      if (s == 'H') s = '♥️';
      if (s == 'D') s = '♦️';
      if (s == 'C') s = '♣️';
      display = "$r$s";
    }

    return Container(
      width: 100,
      height: 140,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Text(
        display,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: isRed ? Colors.red : const Color(0xFF334155),
        ),
      ),
    );
  }

  String _formatRecallItem(String item) {
    if (_type != 'card') return item;
    if (item.isEmpty) return '';
    if (item.length < 2) return item;
    String r = item.substring(0, item.length - 1);
    String s = item.substring(item.length - 1);
    switch (s) {
      case 'S': s = '♠️'; break;
      case 'H': s = '♥️'; break;
      case 'D': s = '♦️'; break;
      case 'C': s = '♣️'; break;
    }
    return "$r$s";
  }

  Widget _buildResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Accuracy",
            style: const TextStyle(fontSize: 18, color: Color(0xFF64748B)),
          ),
          Text(
            "${_results?['accuracy_percentage']}%",
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context), 
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Back to Menu'),
          )
        ],
      ),
    );
  }
}