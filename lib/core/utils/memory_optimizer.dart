import 'package:flutter/material.dart';

/// MemoryOptimizer provides utilities to optimize memory usage in the app
class MemoryOptimizer {
  /// The singleton instance
  static final MemoryOptimizer _instance = MemoryOptimizer._internal();

  /// Factory constructor to return the singleton instance
  factory MemoryOptimizer() => _instance;

  /// Internal constructor
  MemoryOptimizer._internal();

  /// Map to keep track of loaded images
  final Map<String, ImageProvider> _imageCache = {};

  /// Get an image from cache or create a new one
  ImageProvider getImage(String url, {double? width, double? height}) {
    if (_imageCache.containsKey(url)) {
      return _imageCache[url]!;
    }

    final provider = ResizeImage(
      NetworkImage(url),
      width: width?.toInt(),
      height: height?.toInt(),
    );

    _imageCache[url] = provider;
    return provider;
  }

  /// Clear the image cache
  void clearImageCache() {
    _imageCache.clear();
    PaintingBinding.instance.imageCache.clear();
  }

  /// Set the maximum size of the image cache
  void setImageCacheSize(int size) {
    PaintingBinding.instance.imageCache.maximumSize = size;
  }

  /// Evict an image from the cache
  void evictImage(String url) {
    if (_imageCache.containsKey(url)) {
      final imageProvider = _imageCache[url]!;
      imageProvider.evict().then((_) {
        _imageCache.remove(url);
      });
    }
  }

  /// Preload an image
  Future<void> preloadImage(
    String url,
    BuildContext context, {
    double? width,
    double? height,
  }) async {
    final provider = getImage(url, width: width, height: height);
    await precacheImage(provider, context);
  }

  /// Clear memory when app goes to background
  void clearMemoryOnBackground() {
    ImageCache imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
    imageCache.clearLiveImages();
  }
}
