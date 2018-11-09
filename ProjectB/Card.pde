class Card {
  float x, y, w, h;
  color c;
  WeatherRecord record;
  
  Card(float x, float y, float w, float h, color c, WeatherRecord record) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;
    this.record = record;
  }

  void display() {
    fill(c);
    noStroke();
    rect(x, y, w, h);
  }
  
  boolean isOver() {
    boolean isInHoriz = mouseX >= x && mouseX <= x+w;
    boolean isInVert = mouseY >= y && mouseY <= y+h;
    
    return isInHoriz && isInVert;
  }
}
