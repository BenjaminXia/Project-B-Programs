class Rectangle {
  float x1,y1,x2,y2;
  float x,y,boxW, boxH;  
  float defaultW, defaultH;
  //int type = CORNERS;
  
  Rectangle( float var1, float var2, float var3, float var4, int rectType ){
    set( var1, var2, var3, var4, rectType );
    defaultW = boxW;
    defaultH = boxH;
  }
  
  public void setDefualtDimensions( float w, float h ){
    defaultW = w;
    defaultH = h;
  }
  
  public void set( float var1, float var2, float var3, float var4, int rectType ){
    if( rectType == CENTER ){
      x = var1;
      y = var2;
      boxW = var3;
      boxH = var4;
      x1 = x - boxW/2;
      x2 = x + boxW/2;
      y1 = y - boxH/2;
      y2 = y + boxH/2;
    } else if( rectType == CORNERS ){
      x1 = var1;
      y1 = var2;
      x2 = var3; 
      y2 = var4;
      x = (x2 + x1)/2;
      y = (y2 + y1)/2;
      boxW = x2 - x1;
      boxH = y2 - y1;
    } else if( rectType == CORNER ){
      x1 = var1;
      y1 = var2;
      boxW = var3;
      boxH = var4;
      x2 = x1 + boxW;
      y2 = y1 + boxH;
      x = (x2 + x1)/2;
      y = (y2 + y1)/2; 
    }
  }
  
  public void translate( float translateX, float translateY ){
     x1 += translateX;
     x2 += translateX;
     x += translateX;
     y1 += translateY;
     y2 += translateY;
     y += translateY;
  }
  
  public void setDimensions( float newW, float newH ){
    this.set( x, y, newW, newH, CENTER ); 
  }
  
  public void setCenter( float xPos, float yPos ){
    set( xPos, yPos, boxW, boxH, CENTER );
  } 
  
  public void setCorner( float x1, float y1 ){
    set( x1, y1, boxW, boxH, CORNER ); 
  }
  
  //rescales the rectangle around the center
  public void reScale( float scaleFactor ){
    boxW *= scaleFactor;
    boxH *= scaleFactor;
    x1 = x - boxW/2;
    x2 = x + boxW/2;
    y1 = y - boxH/2;
    y2 = y + boxH/2;
  }
  
  public void setScale( float scaleFactor ){
    boxW = defaultW*scaleFactor;
    boxH = defaultH*scaleFactor;
    x1 = x - boxW/2;
    x2 = x + boxW/2;
    y1 = y - boxH/2;
    y2 = y + boxH/2;
  }
  
  public void rescale( float focusX, float focusY, float scaleFactor ){
    
  }
  
  public void printInfo(){
    println( "x:"+x+" y:"+y+" w:"+boxW+" h:"+boxH+" x1:"+x1+" y1:"+y1+" x2:"+x2+" y2:"+y2);
  }
  
  void drawBorder( float xPos, float yPos, float hue ){
    stroke( hue, 1, 1 );
    noFill();
    rectMode( CORNER );
    rect( xPos, yPos, boxW, boxH );
  }
  
  public boolean isWithin( float pointX, float pointY ){
    return (pointX>=this.x1 && pointX<=this.x2 && pointY>=y1 && pointY<=y2); 
  }
  
  public boolean isWithin( int pointX, int pointY ){
    return (pointX>=this.x1 && pointX<=this.x2 && pointY>=y1 && pointY<=y2); 
  }
  
  public void drawBorder( float hue ){
    stroke( hue, 1, 1 );
    noFill();
    rectMode( CORNER );
    rect( x1, y1, boxW, boxH );
  }
  
  public void drawBorder(){ //caller must set fill, stroke, strokeWeight
    rectMode( CORNER );
    rect( x1, y1, boxW, boxH); 
  }
  
  public void drawRect(){
    rectMode( CORNERS );
    rect( x1, y1, x2, y2 );
  }
  
  public void drawRelative(){
    rectMode( CORNERS );
    rect( x1*width, y1*height, x2*width, y2*height );
  }
  
  public void drawBorder( float weight, float hue ){
    strokeWeight( weight );
    stroke( hue, 1, 1 );
    noFill();
    rectMode( CENTER );
    rect( x, y, boxW - weight, boxH - weight );
    strokeWeight( 1 );
  }
  
  public Rectangle clone(){
    return new Rectangle( this.x, this.y, this.boxW, this.boxH, CENTER ); 
  } 
}

class Float2 {
  float x, y;
  Float2( float xIn, float yIn ){
    x = xIn;
    y = yIn;
  }
  
  public void set(float xIn, float yIn ){
    x = xIn;
    y = yIn;
  }
}
/*
float[] rectMap(Rectangle src, Rectangle dest, float xIn, float yIn){
  float[] retVal = new float[2];
  retVal[0] = (xIn - src
  return retVal;
}*/