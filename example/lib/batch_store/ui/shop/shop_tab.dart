import 'package:batch_flutter_example/batch_store/data/articles_fake_datasource.dart';
import 'package:batch_flutter_example/batch_store/data/model/article.dart';
import 'package:batch_flutter_example/batch_store/event_manager.dart';
import 'package:batch_flutter_example/batch_store/ui/article/article_details_page.dart';
import 'package:batch_flutter_example/batch_store/ui/shop/shop_article_row_item.dart';
import 'package:flutter/material.dart';

class ShopTab extends StatelessWidget {
  const ShopTab({Key? key}) : super(key: key);

  void _onItemTapped(BuildContext context, Article article) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ArticleDetailsPage(article: article)));
    EventManager.trackArticleVisit(article);
  }

  @override
  Widget build(BuildContext context) {
    List<Article> allArticles = ArticlesFakeDatasource.allArticles;
    return GridView.builder(
        gridDelegate:
            SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300),
        itemCount: allArticles.length,
        itemBuilder: (BuildContext context, int index) {
          final Article article = allArticles[index];
          return InkWell(
            child: ShopArticleRowItem(
              article: article,
            ),
            enableFeedback: true,
            onTap: () => _onItemTapped(context, article),
          );
        });
  }
}
