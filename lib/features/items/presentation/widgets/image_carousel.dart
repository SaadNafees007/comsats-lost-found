import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key, required this.imageUrls, this.height = 250});

  final List<String> imageUrls;
  final double height;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  List<String> get _validUrls =>
      widget.imageUrls.where((url) => url.trim().isNotEmpty).toList();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImage(String url, {bool isFullScreen = false}) {
    if (url.startsWith('data:image')) {
      // Extract the base64 part
      final base64String = url.split(',').last;
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: isFullScreen ? BoxFit.contain : BoxFit.cover,
        width: isFullScreen ? null : double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, size: 48),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: isFullScreen ? BoxFit.contain : BoxFit.cover,
      width: isFullScreen ? null : double.infinity,
      placeholder: (context, url) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: isFullScreen ? Colors.white : null),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: isFullScreen ? 64 : 48,
            color: isFullScreen ? Colors.white54 : null,
          ),
        ),
      ),
    );
  }

  void _openFullScreenViewer(BuildContext context, int initialIndex) {
    final validList = _validUrls;
    if (validList.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) {
          final pageController = PageController(initialPage: initialIndex);
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                '${initialIndex + 1} / ${validList.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            body: PageView.builder(
              controller: pageController,
              itemCount: validList.length,
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: _buildImage(validList[index], isFullScreen: true),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validList = _validUrls;
    if (validList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: validList.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final url = validList[index];
                    return GestureDetector(
                      onTap: () => _openFullScreenViewer(context, index),
                      child: Hero(
                        tag: 'item_image_$url',
                        child: _buildImage(url, isFullScreen: false),
                      ),
                    );
                  },
                ),
              ),
              if (validList.length > 1)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${validList.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (validList.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(validList.length, (index) {
              final isSelected = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: isSelected ? 20 : 6,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

