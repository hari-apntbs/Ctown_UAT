import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager extends CacheManager {
  static const key = 'customCache';

  static final CustomCacheManager instance = CustomCacheManager._();

  CustomCacheManager._()
      : super(
    Config(
      key,
      stalePeriod: const Duration(days: 7), // Cache duration
      maxNrOfCacheObjects: 100,            // Max cache objects
    ),
  );
}