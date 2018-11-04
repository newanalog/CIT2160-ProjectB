Table table;
int rowCount;
ArrayList<Card> cards = new ArrayList<Card>();
static int infoPanelHeight = 352;
int squareSize = 32;
color cold = #00a8ff;
color hot = #f8410a;
int minYear;
int maxYear;
int currYear;
static float yearMinTemp = MAX_FLOAT;
static float yearMaxTemp = MIN_FLOAT;
int legendTop;
int detailsTop;
String[] months;
PFont font;

void setup() {
  size(1024, 768);
  smooth();
  background(0);
  legendTop = height-infoPanelHeight;
  detailsTop = legendTop+squareSize;
  months = split("J,F,M,A,M,J,J,A,S,O,N,D", ','); 
  font = createFont("Roboto-Bold.ttf", 96, true);
  textFont(font);
  
  importData();
  
  displayCards(minYear);  // set inital view to minimum dataset year
  createAxes();
  createLegend();
  
  mouseX = squareSize;  //set initial hover to update info panel
  mouseY = squareSize;
  mouseClicked();
}

void draw() {
  for(Card card : cards) {
    if(card.isOver()) {
      drawInfoPanel(card);  // update info panel background and data
      
      // update legend and pointer
      createLegend();
      fill(255);
      float pos = map(card.record.avgTemp, yearMinTemp, yearMaxTemp, squareSize, width);
      triangle(constrain(pos-5, squareSize, width), detailsTop, pos, legendTop+25, pos+5, detailsTop);
    } 
  }
}

void keyPressed() {
  // press left arrow to decrease year, right to increase
  // limits set to min and max year from dataset
  if(keyCode == 37 && currYear != minYear) {
    displayCards(--currYear);
  } else if (keyCode == 39 && currYear != maxYear) {
    displayCards(++currYear);
  }
}

void importData() {
  table = loadTable("weather.csv", "header");  // import data table
  rowCount = table.getRowCount();

  StringList dateStrings = table.getStringList("DATE");
  IntList years = new IntList();
  
  // get years from dataset to determin min max bounds for arrow keys
  for(String d : dateStrings) {
    String year = split(d, '-')[0];
    years.append(int(year)); 
  }
  
  minYear = years.min();
  maxYear = years.max();
}

ArrayList<TableRow> getRowsForYear(int year) {
  ArrayList<TableRow> results = new ArrayList<TableRow>();
  
  // iterate over table rows and find records for requested year
  for(int i = 0; i < table.getRowCount(); i++) {
    if(table.getRow(i).getString("DATE").contains(nf(year))) {
      results.add(table.getRow(i));
    }
  }

  return results;
}

void displayCards(int year) {
  currYear = year;
  yearMinTemp = MAX_FLOAT;
  yearMaxTemp = MIN_FLOAT;
  ArrayList<TableRow> rfy = getRowsForYear(year);
  ArrayList<WeatherRecord> records = new ArrayList<WeatherRecord>();
  
  surface.setTitle("Nashville Weather " + nf(currYear));
  
  for(TableRow row : rfy) {
    String dateStr = row.getString("DATE");
    float avgTemp = row.getFloat("TAVG");
    float minTemp = row.getFloat("TMIN");
    float maxTemp = row.getFloat("TMAX");
    float precip = row.getFloat("PRCP");
    
    yearMinTemp = min(avgTemp, yearMinTemp);
    yearMaxTemp = max(avgTemp, yearMaxTemp);
    
    records.add(new WeatherRecord(dateStr, avgTemp, minTemp, maxTemp, precip));
  }

  cards.clear();
  
  fill(0);
  rect(squareSize, squareSize, width-squareSize, legendTop);
  
  for(int i = 0; i < records.size(); i++) {
    WeatherRecord record = records.get(i);
    color k = lerpColor(cold, hot, norm(record.avgTemp, yearMinTemp, yearMaxTemp));
    Card c = new Card(squareSize*record.getDay(), squareSize*record.getMonth(), squareSize, squareSize, k, record);
    cards.add(c);
    c.display();
  }
}

void createAxes() {
  fill(0);
  fill(255);
  textSize(12);
  textAlign(CENTER);
  int currDay = 1;
  for(int x = squareSize; x < width; x+=squareSize) {
    text(nf(currDay), x+15, 20);
    currDay++;
  }
  
  int currMonth = 0;
  for(int y = squareSize; y < legendTop; y+=squareSize) {
    text(months[currMonth], 15, y+20);
    currMonth++;
  }
}

void createLegend() {
  int x = squareSize;
  int y = legendTop;
  
  // draw gradient
  color curr = cold;
  float pos = 0;
  for(int i = x; i < width; ++i) {
    pos = map(i, x, width, 0, 1);
    curr = lerpColor(cold, hot, pos);
    stroke(curr);
    line(i, y, i, y+squareSize);
  }
  
  // draw legend min/max
  textSize(16);
  fill(255);
  textAlign(LEFT, TOP);
  text((int)yearMinTemp + "°", x+5, y+5);
  textAlign(RIGHT, TOP);
  text((int)yearMaxTemp + "°", width-5, y+5);
  
  // draw legend borders
  stroke(0, 100);
  strokeWeight(1);
  line(x, y, width, y);
  line(x, y+squareSize, width, y+squareSize);
  noStroke();
}

void drawInfoPanel(Card card) {
  rectMode(CORNER);
  WeatherRecord record = card.record;
  fill(card.c);
  rect(squareSize, detailsTop+1, width, infoPanelHeight-1);
  fill(255);
  textAlign(CENTER, TOP);
  textSize(180);
  text(record.getFormattedAvgTemp(), 250, 470);
  textSize(48);
  text(record.getFormattedDate(), 230, 670);
  textAlign(LEFT, TOP);
  text("Min Temp: " + record.getFormattedMinTemp(), 510, 510);
  text("Max Temp: " + record.getFormattedMaxTemp(), 510, 580);
  text("Precipitation: " + record.getFormattedPrecip(), 510, 650);
} //<>//
