class Level {
  final int amountOfTiles;
  final bool passed;

  Level(this.amountOfTiles, this.passed);

  @override
  String toString() {
    return "{" + amountOfTiles.toString() + ", " + passed.toString() + "}";
  }
}