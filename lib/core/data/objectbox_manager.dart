import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scannutplus/objectbox.g.dart'; // Created by build_runner

class ObjectBoxManager {
  static const String errDbNotInit = 'ERR_DB_NOT_INIT';
  late final Store store;
  
  static ObjectBoxManager? _instance;
  
  ObjectBoxManager._create(this.store);

  static Future<void> init() async {
    if (_instance != null) return;
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "scannut-db"));
    _instance = ObjectBoxManager._create(store);
  }

  static Store get currentStore {
      if (_instance == null) {
          throw Exception(errDbNotInit);
      }
      return _instance!.store;
  }
}
