float xPos = 0, yPos = 0, xOffset = 0, yOffset = 0;
float quadScale = 1;
boolean first = true;
int delayTime = 130;
DelayedData sensorDelay = new DelayedData(delayTime);

void serialEvent(Serial myPort) {
  String dataIn = port.readStringUntil('\n'); 
  if(first) {
    first = false;
    return;
  }
  sensorDelay.add(dataIn, millis());
  //sensorPosNoOff.set((xPos - xOffset)/quadScale, (yPos - yOffset)/quadScale);
  String delayedData = sensorDelay.get(millis());
  if(delayedData != null) {
    MangoDataSample sample = new MangoDataSample(delayedData);
    float x = (float)sample.getPillarData(0).getX();
    float y = (float)sample.getPillarData(0).getY();
    float z = (float)sample.getPillarData(0).getZ();
    map.setSensorPos(x, y, z);
    map.setRawSensorData(delayedData);
  } else {
    //sensorPosNoOff.set(0, 0); 
  }
}

void centerSensor(){
  xOffset = xPos;
  yOffset = yPos;
}

int calibrationTimer;
boolean initialCalibrated = false;
void checkCalibration() {
  if(!initialCalibrated && calibrationTimer - millis() > 1000) {
    calibrate();
    initialCalibrated = true;
  }
}

void calibrate() {
  centerSensor();
  videoFeed.centerImage(); 
}