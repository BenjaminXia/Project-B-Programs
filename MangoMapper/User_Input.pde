void keyReleased(){
  if(key == ' ') {
    //centerSensor();
    isRecording = !isRecording;
    println("Recording:" + isRecording);
  }
  
  if(key == 'c') {
    map.centerSensor();
    videoFeed.centerImage();
  }
  
  if(key == 's') {
    //sensorToActual.save("sensor2actual.txt");
    dataLog.save("map.txt");
  }
  
  if(key == 'r') {
    //sensorToActual.load("sensor2actual.txt");
  }
  
  if(key == 'l') {
    //sensorToActual.toggleLogMode(); 
  }
  
  if(key == 'm') {
    //sensorToActual.mouseMode = !sensorToActual.mouseMode; 
  }
  
  if(key == 'p') {
    //videoFeed.plateDetectOn = !videoFeed.plateDetectOn; 
  }
  
  if(key == 'k') {
    if(!dataLog.isLogging) dataLog.start();
    else dataLog.stop();
  }
  
  if(key == 'j') {
    dataLog.stop();
    dataLog.save("log.txt");
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e == 1){
    //videoFeed.imgScale -= 1; 
  } else {
    //videoFeed.imgScale += 1; 
  }
}