import 'package:flutter/material.dart';
import 'numbers/pao_numbers_list_screen.dart';
import 'cards/pao_cards_list_screen.dart';

class PaosScreen extends StatelessWidget {
  const PaosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case 'cards':
            builder = (BuildContext context) => const PaoCardsListScreen();
            break;
          case 'numbers':
            builder = (BuildContext context) => const PaoNumbersListScreen();
            break;
          default:
            builder = (BuildContext context) => const PaosMenu();
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}

class PaosMenu extends StatelessWidget {
  const PaosMenu({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'PAO Systems',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3B82F6),
        centerTitle: false,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOptionCard(
                context,
                title: 'Card PAO',
                subtitle: '52 Playing Cards',
                icon: Icons.style,
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pushNamed(context, 'cards');
                },
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                title: 'Number PAO',
                subtitle: '00-99 & 0-9',
                icon: Icons.onetwothree,
                color: primaryColor,
                onTap: () {
                  Navigator.pushNamed(context, 'numbers');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}