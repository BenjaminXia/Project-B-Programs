class Log {
  ArrayList<String> strings = new ArrayList<String>();
  boolean isLogging = false;
  String header = "";
  int logStartTime = 0;
  int sampleCount;
  Log() {
    
  }
  
  public void start() {
    ArrayList<String> strings = new ArrayList<String>();
    this.add(header);
    isLogging = true;
    logStartTime = millis();
    sampleCount = 0;
  }
  
  public void stop() {
     isLogging = false;
  }
  
  public void save(String addr) {
    String[] saveStr = strings.toArray(new String[0]);
    saveStrings(addr, saveStr);
  }
  
  public void add(String add){
    strings.add(add); 
    sampleCount++;
  }
  
  //use default logging setup
  public void add() {
    /*
    if(isLogging) {
      String timeStr = "" + (millis() - logStartTime);
      String rawStr = "\t" + sensorPosNoOff.x + "\t" + sensorPosNoOff.y;
      String mapStr;
      if(mappedOut == null) {
        mapStr = "\t0.0\t0.0";
      } else mapStr = "\t" + mappedOut.x + "\t" + mappedOut.y;
      
      String tipStr = "\t" + sensorToActual.outPos.x + "\t" + sensorToActual.outPos.y;
      String platStr = "\t" + videoFeed.plateFracPos.x + "\t" + videoFeed.plateFracPos.y;
      
      String outStr = timeStr + rawStr + mapStr + tipStr + platStr;
      this.add(outStr);
    }
    */
  }
  
  
}