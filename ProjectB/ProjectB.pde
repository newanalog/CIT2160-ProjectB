Table table;
PFont font;
String[] months;
int rowCount, minYear, maxYear, currYear, legendTop, detailsTop;
ArrayList<Card> cards = new ArrayList<Card>();
color cold = #00a8ff;
color hot = #f8410a;
int infoPanelHeight = 352;
int squareSize = 32;
float yearMinTemp = MAX_FLOAT;
float yearMaxTemp = MIN_FLOAT;

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
  
  mouseX = squareSize;  //set initial hover to 1st day
  mouseY = squareSize;
}

void draw() {
  for(Card card : cards) {
    if(card.isOver()) {
      drawInfoPanel(card);
      createLegend();
      
      // if missing avg temp for day, just return
      if (Float.isNaN(card.record.avgTemp)) return;
      
      // redraw pointer
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
  // import data table
  table = loadTable("weather.csv", "header");  
  rowCount = table.getRowCount();

  // get all dates from dataset
  StringList dateStrings = table.getStringList("DATE"); 
  IntList years = new IntList();
  
  // store dates in array so we can pick min/max
  for(String d : dateStrings) {
    String year = split(d, '-')[0];
    years.append(int(year)); 
  }
  
  // set min max year bounds for arrow keys
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

  // return array with only records for year 
  return results;
}

void displayCards(int year) {
  // track year being displayed globally
  currYear = year;
  
  // reset min/max temps to values that will be replaced
  yearMinTemp = MAX_FLOAT;
  yearMaxTemp = MIN_FLOAT;
  
  // get only records for year
  ArrayList<TableRow> rfy = getRowsForYear(year);
  ArrayList<WeatherRecord> records = new ArrayList<WeatherRecord>();
  
  // set title bar
  surface.setTitle("Nashville Weather " + nf(currYear));
  
  for(TableRow row : rfy) {
    // pluck properties we care about for a WeatherRecord
    String dateStr = row.getString("DATE");
    float avgTemp = row.getFloat("TAVG");
    float minTemp = row.getFloat("TMIN");
    float maxTemp = row.getFloat("TMAX");
    float precip = row.getFloat("PRCP");
    
    // update global min/max avg temps
    yearMinTemp = min(avgTemp, yearMinTemp);
    yearMaxTemp = max(avgTemp, yearMaxTemp);
    
    // add our new record to the array
    records.add(new WeatherRecord(dateStr, avgTemp, minTemp, maxTemp, precip));
  }

  // reset the card display area
  cards.clear();
  fill(0);
  rect(squareSize, squareSize, width-squareSize, legendTop);
  
  // iterate over records and create a new card to hold each one
  for(int i = 0; i < records.size(); i++) {
    WeatherRecord record = records.get(i);
    // map current record avg temp to min/max avg temp range
    color k = lerpColor(cold, hot, norm(record.avgTemp, yearMinTemp, yearMaxTemp));
    Card c = new Card(squareSize*record.getDay(), squareSize*record.getMonth(), squareSize, squareSize, k, record);
    // add new card to array
    cards.add(c);
    // show the card
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
    // write day of month numbers
    text(nf(currDay), x+15, 20);
    currDay++;
  }
  
  int currMonth = 0;
  for(int y = squareSize; y < legendTop; y+=squareSize) {
    // write month abbreviations
    text(months[currMonth], 15, y+20);
    currMonth++;
  }
}

void createLegend() {
  int x = squareSize;
  int y = legendTop;
  
  // draw gradient from cold to hot
  color curr = cold;
  float pos = 0;
  for(int i = x; i < width; ++i) {
    pos = map(i, x, width, 0, 1);
    curr = lerpColor(cold, hot, pos);
    stroke(curr);
    line(i, y, i, y+squareSize);
  }
  
  // write legend min/max
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
  // grab record off of card that was passed in
  WeatherRecord record = card.record;
  // set fill to card color
  fill(card.c);
  rect(squareSize, detailsTop+1, width, infoPanelHeight-1);
  // write record details to info panel area
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
