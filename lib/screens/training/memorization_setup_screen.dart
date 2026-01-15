import 'package:flutter/material.dart';
import '../../services/training_service.dart';
import 'memorization_session_screen.dart';

class MemorizationSetupScreen extends StatefulWidget {
  const MemorizationSetupScreen({super.key});

  @override
  State<MemorizationSetupScreen> createState() => _MemorizationSetupScreenState();
}

class _MemorizationSetupScreenState extends State<MemorizationSetupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TrainingService _trainingService = TrainingService();
  bool _isLoading = false;
  
  // State for Cards
  int _cardItemCount = 52;
  int _cardBatchSize = 3;

  // State for Numbers
  int _numberItemCount = 20;
  int _numberBatchSize = 5;

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

  Future<void> _startTraining(String type) async {
    setState(() => _isLoading = true);

    int count = type == 'card' ? _cardItemCount : _numberItemCount;
    int batch = type == 'card' ? _cardBatchSize : _numberBatchSize;
    
    final session = await _trainingService.createSession(
      type: type,
      itemCount: count,
      batchSize: batch,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (session != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemorizationSessionScreen(sessionData: session),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start session')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('New Training Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          _buildConfigForm('card', _cardItemCount, _cardBatchSize, (c, b) {
            setState(() {
              _cardItemCount = c;
              _cardBatchSize = b;
            });
          }),
          _buildConfigForm('number', _numberItemCount, _numberBatchSize, (c, b) {
            setState(() {
              _numberItemCount = c;
              _numberBatchSize = b;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildConfigForm(
    String type,
    int currentCount,
    int currentBatch,
    Function(int, int) onChanged,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputGroup(
            'Total Items',
            'How many ${type}s to memorize?',
            currentCount,
            (val) => onChanged(val, currentBatch),
          ),
          const SizedBox(height: 24),
          _buildInputGroup(
            'Batch Size',
            'Items per screen',
            currentBatch,
            (val) => onChanged(currentCount, val),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _startTraining(type),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Begin Training', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputGroup(String label, String help, int value, Function(int) onChanged) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  controller: TextEditingController(text: value.toString())
                    ..selection = TextSelection.collapsed(offset: value.toString().length),
                  onChanged: (val) {
                    final int? num = int.tryParse(val);
                    if (num != null) onChanged(num);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(help, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
      ],
    );
  }
}
