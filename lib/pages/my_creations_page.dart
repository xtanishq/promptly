import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/creations_store.dart';
import '../image_and_text/presentation/pages/creation_card.dart';
import '../screens/primary_button.dart';
import '../utils/AppTheme.dart';

class MyCreationsPage extends StatelessWidget {
  const MyCreationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final creations = CreationsStore().creations;
    final bool isEmpty = creations.isEmpty;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Creations",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your saved AI edits",
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isEmpty ? _buildEmptyState(context) : _buildGrid(creations),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.surfacePrimary,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 64,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No creations yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMain,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Generate your first AI edit to see it here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: "Explore Features",
              onTap: () {
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Creation> creations) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: creations.length,
      itemBuilder: (context, index) {
        final creation = creations[index];
        final dateStr = DateFormat('MMM dd, yyyy').format(creation.date);
        
        return CreationCard(
          imageUrl: creation.imageUrl,
          featureLabel: creation.featureLabel,
          dateStr: dateStr,
          onTap: () {
            context.push('/image-preview', extra: creation.imageUrl);
          },
        );
      },
    );
  }
}
