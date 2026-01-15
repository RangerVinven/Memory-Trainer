import 'package:flutter/material.dart';
import '../../../models/pao_card.dart';
import '../../../services/pao_service.dart';

class PaoCardsListScreen extends StatefulWidget {
  const PaoCardsListScreen({super.key});

  @override
  State<PaoCardsListScreen> createState() => _PaoCardsListScreenState();
}

class _PaoCardsListScreenState extends State<PaoCardsListScreen> {
  final PaoService _paoService = PaoService();
  final ScrollController _scrollController = ScrollController();
  
  List<PaoCard> _cards = [];
  bool _isLoading = true;

  // Grid constants
  final int _crossAxisCount = 2;
  final double _childAspectRatio = 0.8;
  final double _crossAxisSpacing = 16.0;
  final double _mainAxisSpacing = 16.0;
  final double _padding = 16.0;

  // Suit order: Spades, Hearts, Clubs, Diamonds (Swapped 3rd/4th from standard S,H,D,C)
  final List<String> _suitOrder = ['spades', 'hearts', 'clubs', 'diamonds'];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    final cards = await _paoService.getCards();
    // Sort cards based on custom suit order
    cards.sort((a, b) {
      int suitComparison = _suitOrder.indexOf(a.suit).compareTo(_suitOrder.indexOf(b.suit));
      if (suitComparison != 0) return suitComparison;
      // Define rank order if needed, but assuming API order is fine or handled similarly
      return 0; // Keep existing rank order
    });

    if (mounted) {
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    }
  }

  void _jumpToSuit(String suit) {
    if (_cards.isEmpty) return;

    // Calculate heights
    final double screenWidth = MediaQuery.of(context).size.width;
    final double gridWidth = screenWidth - (_padding * 2);
    final double itemWidth = (gridWidth - (_crossAxisSpacing * (_crossAxisCount - 1))) / _crossAxisCount;
    final double itemHeight = itemWidth / _childAspectRatio;
    final double rowHeight = itemHeight + _mainAxisSpacing;

    // Jump Bar Height + Spacing
    const double topOffset = 50.0 + 16.0; 

    // Find index of first card of this suit
    int firstIndex = _cards.indexWhere((c) => c.suit == suit);
    if (firstIndex == -1) return;

    // Calculate row
    int targetRow = (firstIndex / _crossAxisCount).floor();
    
    double offset = targetRow * rowHeight + topOffset;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _editCard(PaoCard card) async {
    final personController = TextEditingController(text: card.person);
    final actionController = TextEditingController(text: card.action);
    final objectController = TextEditingController(text: card.object);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${card.displayName}'),
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
                card.person = personController.text;
                card.action = actionController.text;
                card.object = objectController.text;
              });
              Navigator.pop(context);
              
              final success = await _paoService.updateCards([card]);
              if (mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save changes')));
              }
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
        title: const Text('Card PAO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                children: [
                  // Suit Jump Bar
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _suitOrder.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final suit = _suitOrder[index];
                        String label = '';
                        String icon = '';
                        Color color = Colors.black;

                        switch (suit) {
                          case 'spades': label = 'Spades'; icon = '♠️'; color = Colors.black; break;
                          case 'hearts': label = 'Hearts'; icon = '♥️'; color = Colors.red; break;
                          case 'clubs': label = 'Clubs'; icon = '♣️'; color = Colors.black; break;
                          case 'diamonds': label = 'Diamonds'; icon = '♦️'; color = Colors.red; break;
                        }

                        return ActionChip(
                          avatar: Text(icon, style: TextStyle(color: color)),
                          label: Text(label),
                          backgroundColor: Colors.white,
                          onPressed: () => _jumpToSuit(suit),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cards Grid
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _crossAxisCount,
                      childAspectRatio: _childAspectRatio,
                      crossAxisSpacing: _crossAxisSpacing,
                      mainAxisSpacing: _mainAxisSpacing,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      return GestureDetector(
                        onTap: () => _editCard(card),
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
                                  card.displayName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: card.isRed ? const Color(0xFFDE0000) : const Color(0xFF334155),
                                  ),
                                ),
                                const Divider(),
                                _buildFieldRow(Icons.person, card.person),
                                const SizedBox(height: 4),
                                _buildFieldRow(Icons.directions_run, card.action),
                                const SizedBox(height: 4),
                                _buildFieldRow(Icons.category, card.object),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Bottom padding
                  const SizedBox(height: 80),
                ],
              ),
            ),
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
