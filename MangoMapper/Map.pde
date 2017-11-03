public class Map {
  private Rectangle screenRect;
  private ArrayList<Float2> sampledPositions;
  private float sensorX, sensorY, sensorZ, camX, camY, camXAbs, camYAbs, prevCamX, prevCamY;
  private float sensorXOffset, sensorYOffset, sensorZOffset;
  private String rawSensorData;
  private float cameraZoomLevel = 0.5, sensorZoomLevel = 0.1;
  private PImage pointMap;

  public Map(Rectangle screenRect) {
    colorMode(HSB, 360, 1, 1, 1);
    this.screenRect = screenRect;
    pointMap = createImage((int)screenRect.boxW, (int)screenRect.boxH, ARGB);
    pointMap.loadPixels();
    for (int i = 0; i < pointMap.pixels.length; i++) {
      pointMap.pixels[i] = color(0, 0, 0, 1); 
    }
    pointMap.updatePixels();
    colorMode(RGB, 255, 255, 255, 255);
  }

  public void setSensorPos(float x, float y, float z) {
    if(prevCamX == camX && prevCamY == camY) return;
    sensorX = x;
    sensorY = y;
    sensorZ = z;
  }
  
  public void centerSensor() {
    sensorXOffset = sensorX;
    sensorYOffset = sensorY;
    sensorZOffset = sensorZ;
  }
  
  public void setRawSensorData(String data) {
    rawSensorData = data;
  }
  
  public void setCameraPos(float x, float y) {
    prevCamX = camX;
    prevCamY = camY;
    camX = x;
    camY = y;
    camXAbs = screenRect.boxW*camX/cameraZoomLevel;
    camYAbs = screenRect.boxH*camY/cameraZoomLevel;
    if(isRecording) {
      addToImage((int)camXAbs, -(int)camYAbs); 
    }
  }
  
  public void addToImage(int x, int y) {
     colorMode(HSB, 360, 1, 1, 1);
     pointMap.loadPixels();
     int xAbs = x + (int)(screenRect.boxW/2);
     int yAbs = y + (int)(screenRect.boxH/2);
     pointMap.pixels[yAbs*pointMap.width + xAbs] = color((sensorZ*3000)%360, 1, 1, 1); 
     pointMap.updatePixels();
     colorMode(RGB, 255, 255, 255, 255);
  }
  
  public String getDataString() {
    return rawSensorData + "\t" + camXAbs + "\t" + camYAbs + "\t2.5";
  } 

  public void display() {
    //draw image
    imageMode(CENTER);
    image(pointMap, screenRect.x, screenRect.y);
    
    colorMode(HSB, 360, 1, 1, 1);
    strokeWeight(3);
    if(isRecording) {
      stroke(0, 0, 1);
    } else {
      stroke(0, 0, 0.5);
    }
    noFill();
    screenRect.drawRect();
    strokeWeight(1);
    line(screenRect.x, screenRect.y1, screenRect.x, screenRect.y2);
    line(screenRect.x1, screenRect.y, screenRect.x2, screenRect.y);

    //draw sensor dot;
    stroke(0, 0, 1);
    strokeWeight(3);
    noFill();
    ellipse(screenRect.x + screenRect.boxW*(sensorX-sensorXOffset)/sensorZoomLevel, screenRect.y - screenRect.boxH*(sensorY-sensorYOffset)/sensorZoomLevel, 10, 10);

    //draw camera dot;
    stroke(120, 1, 1);
    strokeWeight(3);
    noFill();
    ellipse(screenRect.x + camXAbs, screenRect.y - camYAbs, 10, 10);

    strokeWeight(1);
    colorMode(RGB, 255, 255, 255, 255);
  }
}