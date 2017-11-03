class HSIColor{
  public float h = 0, s = 0, i = 0, a = 1;
  boolean alphaSet = false;
  
  HSIColor( float hVal, float sVal, float iVal ){
    h = hVal;
    s = sVal;
    i = iVal;
  }
  
  HSIColor( float hVal, float sVal, float iVal, float aVal ){
    h = hVal;
    s = sVal;
    i = iVal;
    a = aVal;
    if( a < 1 ) alphaSet = true;
  } 
  
  HSIColor( float[] array ){
    this( array[0], array[1], array[2], array[3] ); //hope you don't get an out of bounds error  
  }
  
  public void setFill(){
    if( !alphaSet ) fill( h, s, i ); 
    else fill( h, s, i, a );
  }
  
  public void setStroke(){
    if( !alphaSet ) stroke( h, s, i );
    else stroke( h, s, i, a ); 
  }
  
  public HSIColor clone(){
    HSIColor retVal;
    if( !alphaSet ) retVal = new HSIColor( h, s, i );
    else retVal = new HSIColor( h, s, i, a );
    return retVal;
  }
  
}