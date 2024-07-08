import 'package:batch_flutter/batch_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart' as foundation;

class SubscriptionsModel extends foundation.ChangeNotifier {
  static const String _subscriptionDefaultsSet = 'subscription_defaults_set';
  static const String _flashSalesKey = 'wants_flash_sales';
  static const String _suggestedContentKey = 'wants_suggested_content';
  static const String _suggestionTopicsCollection = 'suggestion_topics';
  static const String _suggestionTopicFashionKey = 'fashion';
  static const String _suggestionTopicOtherKey = 'other';

  bool _subscribedToFlashSales = true;
  bool _subscribedToSuggestedContent = true;
  bool _subscribedToFashionSuggestions = true;
  bool _subscribedToOtherSuggestions = true;

  get subscribedToFlashSales => this._subscribedToFlashSales;

  set subscribedToFlashSales(flashSales) {
    this._subscribedToFlashSales = flashSales;
    performSetterSideEffects();
  }

  get subscribedToSuggestedContent => this._subscribedToSuggestedContent;

  set subscribedToSuggestedContent(suggestedContent) {
    this._subscribedToSuggestedContent = suggestedContent;
    performSetterSideEffects();
  }

  get subscribedToFashionSuggestions => this._subscribedToFashionSuggestions;

  set subscribedToFashionSuggestions(suggestionFashion) {
    this._subscribedToFashionSuggestions = suggestionFashion;
    performSetterSideEffects();
  }

  get subscribedToOtherSuggestions => this._subscribedToOtherSuggestions;

  set subscribedToOtherSuggestions(suggestionOther) {
    this._subscribedToOtherSuggestions = suggestionOther;
    performSetterSideEffects();
  }

  Future<void> loadModel() async {
    final prefs = await SharedPreferences.getInstance();
    _subscribedToFlashSales = prefs.getBool(_flashSalesKey) ?? true;
    _subscribedToSuggestedContent = prefs.getBool(_suggestedContentKey) ?? true;
    _subscribedToFashionSuggestions = prefs.getBool(
            _suggestionTopicsCollection + "_" + _suggestionTopicFashionKey) ??
        true;
    _subscribedToOtherSuggestions = prefs.getBool(
            _suggestionTopicsCollection + "_" + _suggestionTopicOtherKey) ??
        true;
    notifyListeners();
  }

  void writeDefaultValues() async {
    final prefs = await SharedPreferences.getInstance();

    // Save changes to Batch on first load
    if (!prefs.containsKey(_subscriptionDefaultsSet)) {
      print("Saving default subscriptions in Batch");
      prefs.setBool(_subscriptionDefaultsSet, true);
      syncWithBatch();
      syncWithPreferences();
    }
  }

  void syncWithPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_flashSalesKey, _subscribedToFlashSales);
    prefs.setBool(_suggestedContentKey, _subscribedToSuggestedContent);
    prefs.setBool(
        _suggestionTopicsCollection + "_" + _suggestionTopicFashionKey,
        _subscribedToFashionSuggestions);
    prefs.setBool(_suggestionTopicsCollection + "_" + _suggestionTopicOtherKey,
        _subscribedToOtherSuggestions);
  }

  void syncWithBatch() {
    final editor = BatchProfile.instance.newEditor();

    editor.setBooleanAttribute(_flashSalesKey, _subscribedToFlashSales);
    editor.setBooleanAttribute(
        _suggestedContentKey, _subscribedToSuggestedContent);

    editor.removeAttribute(_suggestionTopicsCollection);

    if (_subscribedToFashionSuggestions) {
      editor.addToArray(_suggestionTopicsCollection, _suggestionTopicFashionKey);
    }
    if (_subscribedToOtherSuggestions) {
      editor.addToArray(_suggestionTopicsCollection, _suggestionTopicOtherKey);
    }

    editor.save();
  }

  void performSetterSideEffects() {
    notifyListeners();
    syncWithPreferences();
    syncWithBatch();
  }
}
