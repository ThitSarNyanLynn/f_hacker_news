import 'dart:async';
import 'news_api_provider.dart';
import 'news_db_provider.dart';
import '../models/item_model.dart';

class Repository {
  List<Source> sources = <Source>[
    newsDbProvider,
    //in order to avoid making same instance multiple time, we make it global variable
    NewsApiProvider(),
  ];
  List<Cache> caches = <Cache>[
    newsDbProvider,
  ];

  /*NewsDbProvider dbProvider = NewsDbProvider();
  NewsApiProvider apiProvider = NewsApiProvider();*/

  //Iterate over sources when dbprovider get fetchTopIds implemented
  Future<List<int>> fetchTopIds() {
    return sources[1]
        .fetchTopIds(); //we didn't actually make fetchTopIds for dbProvider, so, we directly call apiProvider here as it is at index 1 in sources list
  }

  Future<ItemModel> fetchItem(int id) async {
    ItemModel item;
    var source;
    for (source in sources) {
      item = await source.fetchItem(id);
      if (item != null) {
        break;
      }
    }

    for (var cache in caches) {
      if (cache != source) {
        cache.addItem(item);
      }
    }
    return item;

    /*var item = await dbProvider.fetchItem(id);
    if (item != null) {
      return item;
    }
    item = await apiProvider.fetchItem(id);
    dbProvider.addItem(item);
    //although we need to put 'await' in this line, we won't coz we need to check id from database and not interested in adding to database
    return item;*/
  }

  clearCache() async {
    for (var cache in caches) {
      await cache.clear();
    }
  }
}

abstract class Source {
  Future<List<int>> fetchTopIds();

  Future<ItemModel> fetchItem(int id);
}

abstract class Cache {
  Future<int> addItem(ItemModel item);
  Future<int> clear();
}
