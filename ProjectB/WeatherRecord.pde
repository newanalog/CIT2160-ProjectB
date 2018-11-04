class WeatherRecord {
  String date;
  float avgTemp, minTemp, maxTemp, precip;
  
  WeatherRecord(String date, float avgTemp, float minTemp, float maxTemp, float precip) {
    this.date = date;
    this.avgTemp = avgTemp;
    this.minTemp = minTemp;
    this.maxTemp = maxTemp;
    this.precip = precip;
  }

  int getYear() {
    return int(split(date, '-')[0]);
  }
  
  int getMonth() {
    return int(split(date, '-')[1]);
  }
  
  int getDay() {
    return int(split(date, '-')[2]);
  }
  
  String getFormattedDate() {
    return split(date, '-')[1] + "/"
      + split(date, '-')[2] + "/"
      + split(date, '-')[0];
  }
  
  String getFormattedMinTemp() {
    return int(minTemp) + "°";
  }
  
  String getFormattedMaxTemp() {
    return int(maxTemp) + "°";
  }
  
  String getFormattedAvgTemp() {
    return int(avgTemp) + "°";
  }
  
  String getFormattedPrecip() {
    return precip + "\"";
  }
}
