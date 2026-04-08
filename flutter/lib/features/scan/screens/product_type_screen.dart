import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'camera_screen.dart';

class ProductTypeScreen extends StatelessWidget {
  const ProductTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('What are you scanning?')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choose product type',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This helps us analyse the ingredients correctly',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _TypeCard(
              icon: Icons.restaurant_outlined,
              title: 'Food product',
              subtitle: 'Snacks, beverages, packaged food',
              color: AppColors.green,
              bgColor: AppColors.greenLight,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CameraScreen(productType: 'food'),
                ),
              ),
            ).animate(delay: 100.ms).slideY(begin: 0.3).fadeIn(),
            const SizedBox(height: 16),
            _TypeCard(
              icon: Icons.spa_outlined,
              title: 'Cosmetic product',
              subtitle: 'Skincare, haircare, makeup',
              color: AppColors.amber,
              bgColor: AppColors.amberLight,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CameraScreen(productType: 'cosmetic'),
                ),
              ),
            ).animate(delay: 200.ms).slideY(begin: 0.3).fadeIn(),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color, bgColor;
  final VoidCallback onTap;
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF888888))),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
        ]),
      ),
    );
  }
}
