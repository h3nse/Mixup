/// Singleton for storing item id's.
class Items {
  static final Items _instance = Items._internal();

  factory Items() {
    return _instance;
  }

  Items._internal();

  Map<String, int> itemMap = {
    "Spaghetti": 1,
    "Salad": 2,
    "Tomato": 3,
    "Meat": 4,
    "Egg": 5,
    "Cheese": 6,
  };

  int getItemId(String itemName) {
    return itemMap[itemName] ?? -1;
  }
}
