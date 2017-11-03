/*
Characterize camera, put grid in front of camera, use matlab to get transformation matrix
*/
import processing.video.*;
import blobscanner.*;
import processing.serial.*;
import java.util.Arrays;
Serial port;
VideoFeed videoFeed;
Map map;
Float2 sensorPosNoOff = new Float2(0, 0), mappedOut = new Float2(0, 0);
Rectangle outGridRect;
Log dataLog = new Log();
int fps = 30;
boolean isRecording = false;

void setup() {
  size(1250, 800);
  frameRate(fps);
  //size(640, 480);
  //colorMode(360, 1, 1, 1);
  PFont font = createFont("", 10);
  String[] cameras = Capture.list();
  String cap = cameras[0];
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    textSize(10);
    for(int i=0; i < cameras.length; i++) {
      if(cameras[i].matches("name=DroidCam Source 3,size=[0-9x]+,fps=30")) {
        cap = cameras[i];
        //delay(10000);
      } else {
        //cap = cameras[0];
      }
    }
  }      
  
  float vidH = height/2;
  float vidW = vidH * 640.0/480;
  videoFeed = new VideoFeed(this, new Rectangle(5 + vidW/2, vidH * 1.5, vidW, vidH, CENTER), new Rectangle(5 + vidW/2, vidH * 0.5, vidW, vidH, CENTER), cap);
  map = new Map(new Rectangle(900, height/2, 500, 500, CENTER));
  //videoFeed.setRawRect(new Rectangle(5 + vidW/2, vidH * 0.5, vidW, vidH, CENTER));
  while(port == null ) {
    port = new Serial(this, "COM11", 57600);
  }
  port.bufferUntil('\n');
  //colorMode(HSB, 360, 1, 1, 1);
  outGridRect = new Rectangle(1000, 240, 400, 400, CENTER);
  
  //sensorPosNoOff = new Float2(0, 0);
  //centerSensor();
  //calibrationTimer = millis();
  dataLog.start();
}

void draw() {
  checkCalibration();
  background(120);
  videoFeed.update();
  videoFeed.display();
  map.display();
  //map.display();
  //imageMap.displayDot();
  //sensorToActual.mouseUpdate();
  showFPS();
  fill(255, 255, 255);
  //textSize(20);
  //text("Scale:" + videoFeed.imgScale, 700, 20);
  
  //set(0, 0, cam);
  if(isRecording) {
    dataLog.add(map.getDataString()); 
  }
}

int fpsTimer = 0, fpsElapsedTimer, prevFrameTime, frameCounter = 0, frames = 0;
void showFPS(){
  colorMode(HSB, 360, 1, 1);
  fill( 120, 1, 1 );
  //textFont( arial );
  textSize( 15 );
  textAlign( RIGHT );  
  text( frames, width - 5, 15 );
  textAlign(LEFT);
  frameCounter++;
  if( millis() - fpsTimer > 1000 ){  
    fpsTimer = millis();
    frames = frameCounter; 
    if( frames == 59 ) frames = 60;
    frameCounter = 0;
  }
  colorMode(RGB, 255, 255, 255, 255);
}