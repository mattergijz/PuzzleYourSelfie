class Level {
  final int number;
  final int amountOfTiles;
  final bool passed;

  Level(this.number, this.amountOfTiles, this.passed);

  @override
  String toString() {
    return "{Number: ${number}, Amount Of Tiles: ${amountOfTiles}, Passed: ${passed} }";
  }
}