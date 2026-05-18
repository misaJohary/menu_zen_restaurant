import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../l10n/generated/app_localizations.dart';

class PhotosTab extends StatelessWidget {
  final List<String> pictures;
  const PhotosTab({super.key, required this.pictures});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (pictures.isEmpty) {
      return EmptyState(
        icon: PhosphorIconsDuotone.image,
        title: l10n.photosEmptyTitle,
        body: l10n.photosEmptyBody,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xxxl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.s,
        mainAxisSpacing: AppSpacing.s,
        childAspectRatio: 4 / 3,
      ),
      itemCount: pictures.length,
      itemBuilder: (context, index) => _PhotoTile(
        imageUrl: pictures[index],
        onTap: () => _openViewer(context, index),
      ),
    );
  }

  void _openViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _PhotosViewer(
          pictures: pictures,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const _PhotoTile({required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.canvas),
          errorWidget: (_, __, ___) => Container(
            color: scheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: Icon(
              PhosphorIconsRegular.imageBroken,
              color: scheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotosViewer extends StatefulWidget {
  final List<String> pictures;
  final int initialIndex;

  const _PhotosViewer({required this.pictures, required this.initialIndex});

  @override
  State<_PhotosViewer> createState() => _PhotosViewerState();
}

class _PhotosViewerState extends State<_PhotosViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context).photosCounter(
            _currentIndex + 1,
            widget.pictures.length,
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.pictures.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) => InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: widget.pictures[index],
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(
                  PhosphorIconsRegular.imageBroken,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
