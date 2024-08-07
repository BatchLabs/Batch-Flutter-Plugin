import 'package:batch_flutter/batch_profile.dart';

import 'data/model/article.dart';

class EventManager {
  static void trackArticleVisit(Article article) {
    BatchProfile.instance.trackEvent(name: "ARTICLE_VIEW", attributes: BatchEventAttributes().putString("\$label", article.name));
  }

  static void trackAddArticleToCart(Article article) {
    BatchProfile.instance.trackEvent(name: "ADD_TO_CART", attributes: BatchEventAttributes().putString("\$label", article.name));
  }

  static void trackCheckout(double amount) {
    BatchProfile.instance.trackEvent(name: "CHECKOUT", attributes: BatchEventAttributes().putDouble("amount", amount));
  }
}
