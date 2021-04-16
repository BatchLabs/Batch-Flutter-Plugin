import 'article.dart';
import 'package:flutter/foundation.dart' as foundation;

class CartModel extends foundation.ChangeNotifier {
  Set<Article> _articles = new Set();

  List<Article> get articles => List.unmodifiable(_articles.toList());

  void addArticle(Article article) {
    _articles.add(article);
    notifyListeners();
  }

  void clear() {
    _articles.clear();
    notifyListeners();
  }

  double get total {
    return _articles.fold(
        0, (previousValue, element) => previousValue + element.price);
  }

  void loadModel() {}
}
