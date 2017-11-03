class VideoFeed {
  public Capture cam;
  public Detector bd, pd;
  private int vidW = 640, vidH = 480;
  public Rectangle screenRect, rawRect = null, roi;
  public float threshold;
  private PImage frameRaw, frame, lastFrame;
  
  private float imgXPos = 0, imgYPos = 0, imgXOffset = vidW/2, imgYOffset = vidH/2;
  private int imgScale = 30;
  private float xRatio, yRatio;
  private Float2 fracPos = new Float2(0, 0), plateFracPos = new Float2(0, 0); //normalized to screen height
  
  //private boolean plateDetectOn = true;
  
  VideoFeed(PApplet pa, Rectangle screenPos, Rectangle rawPos, String cap) {
    bd = new Detector(pa, 255);
    pd = new Detector(pa, 255);
    screenRect = screenPos;
    rawRect = rawPos;
    xRatio = (screenRect.boxW/vidW);
    yRatio = (screenRect.boxH/vidH);
    int areaW = 100, areaH = 100;
    roi = new Rectangle(screenPos.x, screenPos.y, areaW, areaH, CENTER);
    bd.setRoi(320 - areaW/2, 240 - areaH/2, areaW, areaH); 
    //pd.setRoi(320 - int(areaW/1.5), 240 - int(areaH/1.5), areaW, areaH); 
    cam = new Capture(pa, cap);
    cam.start();
  }
  
  void setRawRect(Rectangle rect) {
    rawRect = rect; 
  }
  
  //cloned to save time, should merge into general purpose func which returns val
  private void findCentroids(Detector detector, PImage img) {
    detector.imageFindBlobs(img);
    detector.loadBlobsFeatures(); 
    strokeWeight(5);
    stroke(255, 0, 0);
    detector.findCentroids();
    if(detector.getBlobsNumber() > 0) {
      int id = getBiggestBlobIndex(detector); 
      //point(detector.getCentroidX(id), detector.getCentroidY(id));
      imgXPos = detector.getCentroidX(id);//*0.4 + imgXPos*0.6;
      imgYPos = detector.getCentroidY(id);//*0.4 + imgYPos*0.6;;
      //imageMap.setDot((imgXPos - imgXOffset)*(float)imgScale/10000.0,-(imgYPos - imgYOffset)*(float)imgScale/10000.0);
      fracPos.set((imgXPos - imgXOffset)*2/vidH, -(imgYPos - imgYOffset)*2/vidH);
      //println(fracPos.x + " " + fracPos.y);
      fill(0,200,100);
      //text("x-> " + detector.getCentroidX(id) + "\n" + "y-> " + detector.getCentroidY(id), detector.getCentroidX(id), detector.getCentroidY(id)-7);
      /*println("Blob 0 has centroid's coordinates at x:" 
                  + detector.getCentroidX(0) 
                  + " and y:" 
                  + detector.getCentroidY(0)); */
      /*color boundingBoxCol = color(255, 0, 0);
      int boundingBoxThickness = 1;
      detector.drawBox(boundingBoxCol, boundingBoxThickness);*/
    }
    strokeWeight(1);
  }
  
  private void drawBoxes(Detector detector, Rectangle rect) {
    //colorMode(HSB, 360, 1, 1, 1);
    //stroke(boxColor);
    //strokeWeight(thickness);
    stroke(120, 1, 1);
    strokeWeight(1);
    noFill();
    PVector[] A = detector.getA();
    //PVector[] B = bd.getB();
    //PVector[] C = bd.getC();
    PVector[] D = detector.getD();
    
    int xOffset = (int)(rect.x1);
    int yOffset = (int)(rect.y1);
    //println(D[0].x*xRatio + xOffset + " " + D[0].y*yRatio + yOffset);
    if (A.length > 0)
      for (int i = 0; i < A.length; i++) {
        rectMode(CORNERS);
        rect(A[i].x*xRatio + xOffset, A[i].y*yRatio + yOffset, D[i].x*xRatio + xOffset, D[i].y*yRatio + yOffset);
        /*line(sroix + A[i].x, sroiy + A[i].y, sroix + B[i].x,
            sroiy + B[i].y);
        line(sroix + B[i].x, sroiy + B[i].y, sroix + D[i].x,
            sroiy + D[i].y);
        line(sroix + A[i].x, sroiy + A[i].y, sroix + C[i].x,
            sroiy + C[i].y);
        line(sroix + C[i].x, sroiy + C[i].y, sroix + D[i].x,
            sroiy + D[i].y);*/
      }
    strokeWeight(1);
    //colorMode(RGB, 255, 255, 255, 255);
  }

  public void centerImage(){
    imgXOffset = imgXPos;
    imgYOffset = imgYPos;
  }
  
  //void filterGreen(
  private int getBiggestBlobIndex(Detector d) {
    int nbrBlobs = d.getBlobsNumber();
    // If we have no blobs return
    if (nbrBlobs ==0)
      return -1;
    d.weightBlobs(false);
    BlobWeight[] blobs = new BlobWeight[nbrBlobs];
    for (int i = 0; i < blobs.length; i++)
      blobs[i] = new BlobWeight(i, d.getBlobWeight(i));
    Arrays.sort(blobs);
    return blobs[0].id;
  }

  private class BlobWeight implements Comparable<BlobWeight> {
    public int id;
    public Integer weight;
  
    public BlobWeight(int id, Integer weight) {
      this.id = id;
      this.weight = weight;
    }
  
    public int compareTo(BlobWeight b) {
      // Reverse so heaviest are first in list
      return new Integer(b.weight).compareTo(weight);
    }
  }
    
  public void update(){
    if (cam.available() == true) { 
      colorMode(HSB, 360, 1, 1, 1);
      cam.read();
      frameRaw = cam.copy();
      frame = cam.copy();
      
      frame.filter(INVERT);
      frame.filter(THRESHOLD, 0.93);

      colorMode(RGB, 255, 255, 255, 255);
      findCentroids(bd, frame); 
      
      map.setCameraPos(fracPos.x, fracPos.y);
    }
    
  }
  
  public void display(){
    colorMode(HSB, 360, 1, 1, 1);
    if(frame != null) {
      imageMode(CORNERS);
      image(frame, screenRect.x1, screenRect.y1, screenRect.x2, screenRect.y2);
      stroke(120, 1, 1, 0.5);
      line(screenRect.x, screenRect.y1, screenRect.x, screenRect.y2);
      line(screenRect.x1, screenRect.y, screenRect.x2, screenRect.y);
    //println(frame.width + " " + frame.height);
     if(rawRect != null) {
       image(frameRaw, rawRect.x1, rawRect.y1, rawRect.x2, rawRect.y2);
       stroke(120, 1, 1, 0.5);
       line(rawRect.x, rawRect.y1, rawRect.x, rawRect.y2);
       line(rawRect.x1, rawRect.y, rawRect.x2, rawRect.y);
     }

      this.drawBoxes(bd, screenRect);
    } 
    stroke(240, 1, 1);
    roi.drawRect();
    
    strokeWeight(3);
    stroke(0, 0, 1);
    noFill();
    screenRect.drawRect();
    if(rawRect != null) {
      rawRect.drawRect(); 
    }
    strokeWeight(1);
    colorMode(RGB, 255, 255, 255, 255);
    
  }
}