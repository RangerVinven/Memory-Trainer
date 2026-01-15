import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/pao_card.dart';
import '../../models/pao_number.dart';
import '../../models/pao_digit.dart';
import '../../services/pao_service.dart';

class PracticeSessionScreen extends StatefulWidget {
  final String type; // 'card' or 'number'
  final List<String> selectedSuits; // For cards
  final List<String> selectedRanges; // For numbers
  final int durationMinutes; // 0 for unlimited

  const PracticeSessionScreen({
    super.key,
    required this.type,
    required this.selectedSuits,
    required this.selectedRanges,
    required this.durationMinutes,
  });

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  final PaoService _paoService = PaoService();
  final Random _random = Random();
  
  List<dynamic> _allItems = [];
  List<dynamic> _filteredItems = [];
  dynamic _currentItem;
  bool _isRevealed = false;
  bool _isLoading = true;
  
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    if (widget.durationMinutes > 0) {
      _secondsRemaining = widget.durationMinutes * 60;
      _startTimer();
    }
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _finishSession();
      }
    });
  }

  void _finishSession() {
    _timer?.cancel();
    setState(() => _isFinished = true);
  }

  Future<void> _loadData() async {
    if (widget.type == 'card') {
      final cards = await _paoService.getCards();
      _allItems = cards;
      _filteredItems = cards.where((c) => widget.selectedSuits.contains(c.suit)).toList();
    } else {
      final numbers = await _paoService.getNumbers();
      final digits = await _paoService.getDigits();
      _allItems = [...digits, ...numbers];
      
      _filteredItems = _allItems.where((item) {
        if (item is PaoDigit) return widget.selectedRanges.contains('0-9 (Digits)');
        if (item is PaoNumber) {
          int n = item.number;
          if (n >= 0 && n <= 9) return widget.selectedRanges.contains('00-09');
          if (n >= 10 && n <= 19) return widget.selectedRanges.contains('10-19');
          if (n >= 20 && n <= 29) return widget.selectedRanges.contains('20-29');
          if (n >= 30 && n <= 39) return widget.selectedRanges.contains('30-39');
          if (n >= 40 && n <= 49) return widget.selectedRanges.contains('40-49');
          if (n >= 50 && n <= 59) return widget.selectedRanges.contains('50-59');
          if (n >= 60 && n <= 69) return widget.selectedRanges.contains('60-69');
          if (n >= 70 && n <= 79) return widget.selectedRanges.contains('70-79');
          if (n >= 80 && n <= 89) return widget.selectedRanges.contains('80-89');
          if (n >= 90 && n <= 99) return widget.selectedRanges.contains('90-99');
        }
        return false;
      }).toList();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _nextItem();
      });
    }
  }

  void _nextItem() {
    if (_filteredItems.isEmpty) return;
    setState(() {
      _currentItem = _filteredItems[_random.nextInt(_filteredItems.length)];
      _isRevealed = false;
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practice Complete')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Session Finished!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Menu'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(widget.durationMinutes > 0 ? _formatTime(_secondsRemaining) : 'Unlimited Practice'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredItems.isEmpty
              ? const Center(child: Text('No items selected for practice.'))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Item Card
                      Container(
                        height: 200,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Text(
                          _getDisplayName(_currentItem),
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: _getItemColor(_currentItem),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Reveal Area
                      if (_isRevealed) ...[
                        _buildPaoText('Person', _currentItem.person),
                        const SizedBox(height: 16),
                        _buildPaoText('Action', _currentItem.action),
                        const SizedBox(height: 16),
                        _buildPaoText('Object', _currentItem.object),
                      ] else
                        const SizedBox(height: 120), // Placeholder height to prevent jumps

                      const Spacer(),

                      // Control Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isRevealed ? _nextItem : () => setState(() => _isRevealed = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRevealed ? const Color(0xFF3B82F6) : Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _isRevealed ? 'Next Item' : 'Reveal',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _getDisplayName(dynamic item) {
    if (item is PaoCard) return item.displayName;
    if (item is PaoNumber) return item.displayName;
    if (item is PaoDigit) return item.displayName;
    return '?';
  }

  Color _getItemColor(dynamic item) {
    if (item is PaoCard && item.isRed) return const Color(0xFFDE0000);
    return const Color(0xFF334155);
  }

  Widget _buildPaoText(String label, String? value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0),
        ),
        const SizedBox(height: 4),
        Text(
          value ?? '?',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
