import 'dart:async';

import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/services/media_search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Page for searching external APIs to auto-fill entry data.
class MediaSearchPage extends ConsumerStatefulWidget {
  const MediaSearchPage({super.key});

  @override
  ConsumerState<MediaSearchPage> createState() => _MediaSearchPageState();
}

class _MediaSearchPageState extends ConsumerState<MediaSearchPage> {
  final _searchController = TextEditingController();
  final _debounce = Debouncer(milliseconds: 500);

  MediaType? _selectedType;
  List<MediaSearchResult> _results = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(mediaSearchServiceProvider);
      final results = await service.search(query, type: _selectedType);

      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Search failed. Please check your API keys.';
          _isLoading = false;
        });
      }
    }
  }

  void _onQueryChanged(String query) {
    _debounce.run(_search);
  }

  void _onTypeChanged(MediaType? type) {
    setState(() {
      _selectedType = type;
    });
    _search();
  }

  void _selectResult(MediaSearchResult result) {
    // Navigate to entry edit with prefill data
    context.go('/entry/new', extra: result);
  }

  void _skipSearch() {
    // Navigate directly to entry creation without pre-filled data
    context.go('/entry/new');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Media'),
        actions: [
          TextButton(
            onPressed: _skipSearch,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search for books, movies, TV shows...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Type filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedType == null,
                  onSelected: (_) => _onTypeChanged(null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Books'),
                  selected: _selectedType == MediaType.book,
                  onSelected: (_) => _onTypeChanged(MediaType.book),
                  avatar: _selectedType == MediaType.book
                      ? null
                      : const Icon(Icons.book, size: 18),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Movies'),
                  selected: _selectedType == MediaType.movie,
                  onSelected: (_) => _onTypeChanged(MediaType.movie),
                  avatar: _selectedType == MediaType.movie
                      ? null
                      : const Icon(Icons.movie, size: 18),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('TV Shows'),
                  selected: _selectedType == MediaType.tv,
                  onSelected: (_) => _onTypeChanged(MediaType.tv),
                  avatar: _selectedType == MediaType.tv
                      ? null
                      : const Icon(Icons.tv, size: 18),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Results
          Expanded(
            child: _buildBody(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _search,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Search for books, movies, or TV shows',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Results will auto-fill entry details',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: _skipSearch,
                child: const Text('Create entry manually'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _MediaResultCard(
          result: result,
          onTap: () => _selectResult(result),
        );
      },
    );
  }
}

class _MediaResultCard extends StatelessWidget {
  const _MediaResultCard({
    required this.result,
    required this.onTap,
  });

  final MediaSearchResult result;
  final VoidCallback onTap;

  IconData get _typeIcon {
    switch (result.type) {
      case MediaType.book:
        return Icons.book;
      case MediaType.movie:
        return Icons.movie;
      case MediaType.tv:
        return Icons.tv;
      case MediaType.music:
        return Icons.music_note;
      case MediaType.other:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            SizedBox(
              width: 80,
              height: 120,
              child: result.coverUrl != null
                  ? Image.network(
                      result.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                    )
                  : _buildPlaceholder(theme),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type badge and year
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _typeIcon,
                                size: 12,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                result.type.label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (result.releaseYear != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            result.releaseYear!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      result.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Creator
                    if (result.creator != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.creator!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Extra info
                    if (result.extraInfo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.extraInfo!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Select indicator
            Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          _typeIcon,
          size: 32,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}

/// Simple debouncer for search input.
class Debouncer {
  Debouncer({required this.milliseconds});

  final int milliseconds;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
