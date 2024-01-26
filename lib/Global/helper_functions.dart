int convertStringToNumbers(String string) {
  String numberString = '';
  for (int i = 0; i < string.length; i++) {
    numberString = [numberString, string.codeUnitAt(i).toString()].join();
  }
  return int.parse(numberString);
}
