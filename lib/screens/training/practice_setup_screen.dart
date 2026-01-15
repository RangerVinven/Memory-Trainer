import 'package:flutter/material.dart';
import 'practice_session_screen.dart';

class PracticeSetupScreen extends StatefulWidget {
  const PracticeSetupScreen({super.key});

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Practice State
  final List<String> _suits = ['spades', 'hearts', 'clubs', 'diamonds'];
  final Map<String, bool> _selectedSuits = {
    'spades': true, 'hearts': true, 'clubs': true, 'diamonds': true
  };

  // 0-9 (Digits) plus decades 00-90
  final Map<String, bool> _selectedRanges = {
    '0-9 (Digits)': true,
    '00-09': true, '10-19': true, '20-29': true, '30-39': true, '40-49': true,
    '50-59': true, '60-69': true, '70-79': true, '80-89': true, '90-99': true,
  };

  int _durationMinutes = 0; // 0 means Unlimited

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startPractice(String type) {
    List<String> suits = _selectedSuits.entries.where((e) => e.value).map((e) => e.key).toList();
    List<String> ranges = _selectedRanges.entries.where((e) => e.value).map((e) => e.key).toList();

    if (type == 'card' && suits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one suit.')));
      return;
    }
    if (type == 'number' && ranges.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one range.')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeSessionScreen(
          type: type,
          selectedSuits: suits,
          selectedRanges: ranges,
          durationMinutes: _durationMinutes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Practice PAO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Cards', icon: Icon(Icons.style)),
            Tab(text: 'Numbers', icon: Icon(Icons.onetwothree)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCardConfig(),
          _buildNumberConfig(),
        ],
      ),
    );
  }

  Widget _buildCardConfig() {
    return _buildConfigScaffold(
      children: [
        _buildSectionHeader('SELECT SUITS'),
        ..._suits.map((suit) {
          String label = suit[0].toUpperCase() + suit.substring(1);
          String icon = '';
          Color color = Colors.black;
          if (suit == 'hearts' || suit == 'diamonds') color = Colors.red;
          if (suit == 'spades') icon = '♠️';
          if (suit == 'hearts') icon = '♥️';
          if (suit == 'clubs') icon = '♣️';
          if (suit == 'diamonds') icon = '♦️';

          return CheckboxListTile(
            title: Text('$icon $label', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            value: _selectedSuits[suit],
            activeColor: const Color(0xFF3B82F6),
            onChanged: (val) => setState(() => _selectedSuits[suit] = val ?? false),
          );
        }),
      ],
      onStart: () => _startPractice('card'),
    );
  }

  Widget _buildNumberConfig() {
    return _buildConfigScaffold(
      children: [
        _buildSectionHeader('SELECT RANGES'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedRanges.keys.map((range) {
            final isSelected = _selectedRanges[range]!;
            return FilterChip(
              label: Text(range),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedRanges[range] = val),
              selectedColor: const Color(0xFF3B82F6).withOpacity(0.2),
              checkmarkColor: const Color(0xFF3B82F6),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
      onStart: () => _startPractice('number'),
    );
  }

  Widget _buildConfigScaffold({required List<Widget> children, required VoidCallback onStart}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          const SizedBox(height: 32),
          _buildSectionHeader('DURATION'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _durationMinutes,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Unlimited (Until stopped)')),
                  DropdownMenuItem(value: 1, child: Text('1 Minute')),
                  DropdownMenuItem(value: 3, child: Text('3 Minutes')),
                  DropdownMenuItem(value: 5, child: Text('5 Minutes')),
                  DropdownMenuItem(value: 10, child: Text('10 Minutes')),
                  DropdownMenuItem(value: 15, child: Text('15 Minutes')),
                ],
                onChanged: (val) => setState(() => _durationMinutes = val!),
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: const Text('Start Practice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
