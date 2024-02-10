import 'package:flutter/material.dart';

class DisplayManager extends ChangeNotifier {
  Image _itemImage = Image.asset('assets/No_item.jpg');

  Image get itemImage => _itemImage;

  void changeItemImage(String item) {
    String imagePath = 'assets/$item.jpg';
    if (item == '') {
      imagePath = 'assets/No_item.jpg';
    }
    _itemImage = Image.asset(imagePath);
    notifyListeners();
  }
}
