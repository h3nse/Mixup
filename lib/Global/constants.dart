class Constants {
  static const String itemDeclaration = '<item>';
  static const String processDeclaration = '<process>';
  static const String playerDeclaration = '<player>';

  static const Map<String, List> items = {
    'Tomato': ['cut'],
    'Spaghetti': ['boil'],
    'Meat': ['cut', 'fry'],
    'Egg': [
      {
        'prerequisites': {
          'cut': ['boil'],
        },
        'negative prerequisites': {
          'fry': ['boil']
        }
      },
      'cut',
      'fry',
      'boil'
    ],
    'Cheese': [
      {
        'prerequisites': {
          'fry': ['cut']
        },
        'negative prerequisites': {}
      },
      'cut',
      'fry'
    ],
    'Salad': ['cut']
  }; // TODO Make class??

  static const Map<String, String> processStatements = {
    'cut': 'Cutting',
    'fry': 'Frying',
    'boil': 'Boiling'
  };

  static const Map<String, int> processWait = {'cut': 3, 'fry': 6, 'boil': 10};
}
