import 'package:flutter/material.dart';
import 'screens/news_list.dart';
import 'blocs/stories_provider.dart';
import 'screens/news_detail.dart';
import 'blocs/comments_provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommentsProvider(
      child: StoriesProvider(
        child: MaterialApp(
          title: 'News',
          onGenerateRoute: routes,
        ),
      ),
    );
  }

  Route routes(RouteSettings settings) {
    /* if u have many other types of page routes use
    switch (settings.name){
    case '/':    // and return whatever page u like
    }
     */
    if (settings.name == '/') {
      return MaterialPageRoute(
        builder: (context) {
          //hereeeeeeeeeeeee
          final storiesBloc=StoriesProvider.of(context);
          storiesBloc.fetchTopIds();

          return NewsList();
        },
      );
    } else {
      return MaterialPageRoute(builder: (context) {
        final commentsBloc = CommentsProvider.of(context);

        //extract the item id from settings.name and pass into NewsDetail
        final itemId = int.parse(settings.name
            .replaceFirst('/', '')); //this is removing / from /4232432747

        commentsBloc.fetchItemWithComments(itemId);

        //a fantastic location to do some initialization or data fetching for NewsDetail
        return NewsDetail(
          itemId: itemId,
        );
      });
    }
  }
}
