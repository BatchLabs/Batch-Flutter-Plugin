import 'package:batch_flutter/batch_user.dart';

import 'data/model/article.dart';

class EventManager {
  static void trackArticleVisit(Article article) {
    BatchUser.instance.trackEvent(name: "ARTICLE_VIEW", label: article.name);
  }

  static void trackAddArticleToCart(Article article) {
    BatchUser.instance.trackEvent(name: "ADD_TO_CART", label: article.name);
  }

  static void trackCheckout(double amount) {
    BatchUser.instance.trackEvent(name: "CHECKOUT");
    BatchUser.instance.trackTransaction(amount);
  }
}
