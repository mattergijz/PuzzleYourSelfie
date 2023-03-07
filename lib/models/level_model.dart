class Level {
  final int number;
  final int verticalAmount;
  final int horizontalAmount;
  bool passed;
  final int time;

  Level(this.number, this.verticalAmount, this.horizontalAmount, this.time, this.passed);

  setPassed(bool passed){
    this.passed = passed;
  }

  @override
  String toString() {
    return "{Number: $number, Amount Of Tiles: ${horizontalAmount * verticalAmount}, Time: $time, Passed: $passed }";
  }
}