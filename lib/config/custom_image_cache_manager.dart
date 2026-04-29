
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;



//Класс управления кэшем изображений, в настоящее время не используется
class CustomCacheManager extends CacheManager {
  static const key = "customCache";

  static CustomCacheManager? _instance;

  factory CustomCacheManager() {
    return _instance ??= CustomCacheManager._();
  }

  CustomCacheManager._() : super(Config(key));

  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }

}