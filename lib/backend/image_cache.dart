import 'dart:collection';
import 'dart:typed_data';

class ImageCacheManager {
  final Map<String, Uint8List> _cache = LinkedHashMap<String, Uint8List>();
  final int _maxCacheSize;

  ImageCacheManager({int maxCacheSize = 10}) : _maxCacheSize = maxCacheSize;

  Future<Uint8List?> getImageFromCache(String key) async {
    if (_cache.containsKey(key)) {
      // Move the accessed item to the end to indicate it's the most recently used
      Uint8List? value = _cache.remove(key);
      if (value != null) {
        _cache[key] = value;
      }
      return value;
    }
    return null;
  }

  void addToCache(String key, Uint8List value) {
    if (_cache.containsKey(key)) {
      // If the key already exists, update its value
      _cache[key] = value;
    } else {
      // Add the new key-value pair
      _cache[key] = value;
      // If the cache size exceeds the maximum allowed, remove the least recently used item
      if (_cache.length > _maxCacheSize) {
        _cache.remove(_cache.keys.first);
      }
    }
  }
}