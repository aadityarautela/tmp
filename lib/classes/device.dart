class WaterData {
  String id;
  int waterLevel;
  double waterLevelPercentage;

  WaterData(this.id);

  void getData(int wL, double wLP) {
    this.waterLevel = wL;
    this.waterLevelPercentage = wLP;
  }
}
