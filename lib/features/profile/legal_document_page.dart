import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// A page that displays a legal document from an asset file.
class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    required this.title,
    required this.assetPath,
    super.key,
  });

  final String title;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder<String>(
        future: rootBundle.loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load document.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              snapshot.data ?? '',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          );
        },
      ),
    );
  }
}
