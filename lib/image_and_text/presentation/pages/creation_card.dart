import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promptly/utils/AppTheme.dart';

class CreationCard extends StatelessWidget {
  final String imageUrl;
  final String featureLabel;
  final String dateStr;
  final VoidCallback onTap;

  const CreationCard({
    Key? key,
    required this.imageUrl,
    required this.featureLabel,
    required this.dateStr,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderSubtle, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.surfacePrimary,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPurple),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: AppTheme.textMuted),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfacePrimary.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderSubtle, width: 1),
                      ),
                      child: Text(
                        featureLabel,
                        style: const TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                dateStr,

              ),
            ),
          ],
        ),
      ),
    );
  }
}
