import 'package:flutter/foundation.dart' as foundation;

import 'cart.dart';

class BatchStoreAppStateModel extends foundation.ChangeNotifier {
  CartModel cart = new CartModel();

  void loadModel() {}
}
