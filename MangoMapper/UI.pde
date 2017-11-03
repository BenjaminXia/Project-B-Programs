public enum BUTTON_STATE{
    DEFAULT,HOVER,PRESSED
};

public enum BUTTON_TRIGGER{
  PRESSED,RELEASED,HELD;    
};

public enum BUTTON_TYPE{
  RECT,TEXT_EXPANDING,BORDER,CUSTOM
}

public enum UI_BUTTON_COLOR_SCHEME{
  DEFAULT            ( new float[][][]{ { {0, 0, 0.8, 1},   {0, 0, 0.9, 1},   {0, 0, 0.5, 1} },
                                        { {0, 0, 0.35, 1},  {0, 0, 0.35, 1},  {0, 0, 0.35, 1} },
                                        { {0, 0, 0, 1},     {0, 0, 0, 1},     {0, 0, 0, 1} } } ),
                                        
  SELECTOR_PRESSED   ( new float[][][]{ { {0, 0, 0.9, 1},   {0, 0, 0.9, 1},   {0, 0, 0.5, 1} },
                                        { {0, 0, 0.35, 1},  {0, 0, 0.35, 1},  {0, 0, 0.35, 1} },
                                        { {0, 0, 0, 1},     {0, 0, 0, 1},     {0, 0, 0, 1} } } ),
                                        
  SELECTOR_DEFAULT   ( new float[][][]{ { {0, 0, 0.5, 1},   {0, 0, 0.6, 1},  {0, 0, 0.4, 1} },
                                        { {0, 0, 0.35, 1},  {0, 0, 0.35, 1},  {0, 0, 0.35, 1} },
                                        { {0, 0, 0, 1},     {0, 0, 0, 1},     {0, 0, 0, 1} } } ),
                                        
  BORDER             ( new float[][][]{ { {0, 0, 0, 0 },   {0, 0, 0, 0 },  {0, 0, 0, 0.5 } },
                                        { {0, 0, 0, 0 },  {0, 0, 0, 0.8 },  {0, 0, 0, 0.8} },
                                        { {0, 0, 0, 0},     {0, 0, 0, 0},     {0, 0, 0, 0} } } );

   
   public float[][][] colorArray;
   private UI_BUTTON_COLOR_SCHEME( float[][][] floatArray  ){
     colorArray = floatArray;                        
   }
   
   public float[][][] getArray(){
     return colorArray; 
   }
}

class UI_Button{
  private Rectangle relativeBox, box;
  private String text;
  private int prevWidth = 0, prevHeight = 0;
  private BUTTON_STATE state;
  private BUTTON_TRIGGER trigger = BUTTON_TRIGGER.RELEASED;
  private HSIColor[] fillColors, strokeColors, textColors;
  private float textSize;
  private BUTTON_TYPE type = BUTTON_TYPE.RECT;
  
  UI_Button( String txt, float var1, float var2, float var3, float var4, int rectMode ){
    state = BUTTON_STATE.DEFAULT;
    text = txt;
    relativeBox = new Rectangle( var1, var2, var3, var4, rectMode );
    box = new Rectangle( 0, 1, 2, 3, CENTER );
    setBox();
    setColorScheme( BUTTON_TYPE.RECT );    
  }
  
  UI_Button( String txt, float var1, float var2, float var3, float var4, int rectMode, BUTTON_TRIGGER trig ){
    this( txt, var1, var2, var3, var4, rectMode );
    trigger = trig; 
  }
  /*
  UI_Button( String txt, float var1, float var2, float var3, float var4, int rectMode, int colorScheme ){
    this( txt, var1, var2, var3, var4, rectMode );
    setColorScheme( colorScheme );
  } */
  
  UI_Button( String txt, float var1, float var2, float var3, float var4, int rectMode, BUTTON_TYPE newType ){
    this( txt, var1, var2, var3, var4, rectMode );
    type = newType;
    setColorScheme( type );
  }
  
  UI_Button( String txt, float var1, float var2, float var3, float var4, int rectMode, BUTTON_TYPE newType, UI_BUTTON_COLOR_SCHEME scheme ){
    this( txt, var1, var2, var3, var4, rectMode );
    type = newType;
    setColorScheme( scheme );
  }
  
  UI_Button( String txt, float var1, float var2, float var3, float var4, int rectMode, UI_BUTTON_COLOR_SCHEME scheme ){
    this( txt, var1, var2, var3, var4, rectMode );
    //type = newType;
    setColorScheme( scheme );
  }
  
  public void setTrigger( BUTTON_TRIGGER newTrig ){
    trigger = newTrig; 
  }
  
  public void reset(){ //reset state
    state = BUTTON_STATE.DEFAULT; 
  }
  
  public void setColorScheme( UI_BUTTON_COLOR_SCHEME scheme ){
    fillColors = new HSIColor[3];
    strokeColors = new HSIColor[3];
    textColors = new HSIColor[3];
    
    float[][][] array = scheme.getArray();
    
    for( int i=0; i<3; i++ ){
      fillColors[i] = new HSIColor( array[0][i] );
      strokeColors[i] = new HSIColor( array[1][i] );
      textColors[i] = new HSIColor( array[2][i] );
    }
  }
  
  public void setColorScheme( BUTTON_TYPE schemeType ){
    fillColors = new HSIColor[3];
    strokeColors = new HSIColor[3];
    textColors = new HSIColor[3];
    //default is all off
    fillColors[0] = new HSIColor( 0, 0, 0, 0 );
    fillColors[1] = new HSIColor( 0, 0, 0, 0 );
    fillColors[2] = new HSIColor( 0, 0, 0, 0 );
      
    strokeColors[0] = new HSIColor( 0, 0, 0, 0 );
    strokeColors[1] = new HSIColor( 0, 0, 0, 0 );
    strokeColors[2] = new HSIColor( 0, 0, 0, 0 );
      
    textColors[0] = new HSIColor( 0, 0, 0, 0 );
    textColors[1] = new HSIColor( 0, 0, 0, 0 );
    textColors[2] = new HSIColor( 0, 0, 0, 0 );
    
    if( schemeType == BUTTON_TYPE.BORDER ){ //empty box type, with gray press, no text color
      fillColors[0] = new HSIColor( 0, 0, 0, 0 );
      fillColors[1] = new HSIColor( 0, 0, 0, 0 );
      fillColors[2] = new HSIColor( 0, 0, 0, 0.5 );
      
      strokeColors[0] = new HSIColor( 0, 0, 0, 0 );
      strokeColors[1] = new HSIColor( 0, 0, 0.8 );
      strokeColors[2] = new HSIColor( 0, 0, 0.8 );
    } else if( schemeType == BUTTON_TYPE.TEXT_EXPANDING ){         //text only
      textColors[0] = new HSIColor( 0, 0, 0.7 );
      textColors[1] = new HSIColor( 0, 0, 1 );
      textColors[2] = new HSIColor( 0, 0, 0.4 );
    } else { //default type
      fillColors[0] = new HSIColor( 0, 0, 0.8 );
      fillColors[1] = new HSIColor( 0, 0, 0.9 );
      fillColors[2] = new HSIColor( 0, 0, 0.5 );
      
      strokeColors[0] = new HSIColor( 0, 0, 0.35 );
      strokeColors[1] = new HSIColor( 0, 0, 0.35 );
      strokeColors[2] = new HSIColor( 0, 0, 0.35 );
      
      textColors[0] = new HSIColor( 0, 0, 0 );
      textColors[1] = new HSIColor( 0, 0, 0 );
      textColors[2] = new HSIColor( 0, 0, 0 );
    }
  }
  
  public void setPosition( float xPos, float yPos ){
    box.setCenter( xPos, yPos ); 
  }
  
  private void setBox(){
    box.set( relativeBox.x1*width, relativeBox.y1*height, relativeBox.x2*width, relativeBox.y2*height, CORNERS );
  }
  
  public boolean isWithin( float xPos, float yPos ){
    return relativeBox.isWithin( xPos, yPos ); 
  }
  
  public boolean update(){
    if( prevWidth != width || prevHeight != height ){ //check for window resizes
      setBox();
    }
    prevWidth = width;
    prevHeight = height;
    
    boolean triggerFlag = false;
    
    if( box.isWithin( mouseX, mouseY ) ){
      if( mousePressed && mouseButton == LEFT ){
        if( state != BUTTON_STATE.PRESSED && trigger == BUTTON_TRIGGER.PRESSED ) triggerFlag = true; //pressed trigger
        if( state == BUTTON_STATE.HOVER ) state = BUTTON_STATE.PRESSED; //can only transition to pressed from hover
      } else {
        if( state == BUTTON_STATE.PRESSED && trigger == BUTTON_TRIGGER.RELEASED ) triggerFlag = true; //released trigger
        if( state == BUTTON_STATE.DEFAULT && type == BUTTON_TYPE.TEXT_EXPANDING ); //UISounds.trigger( UI_SOUND.HOVER ); //trigger hover sound for text buttons
        state = BUTTON_STATE.HOVER;
        if( trigger == BUTTON_TRIGGER.HELD ) triggerFlag = true; //held trigger
      }
    } else {
      state = BUTTON_STATE.DEFAULT;
    }
    //if( triggerFlag ) UISounds.trigger( UI_SOUND.CLICK_SHORT );
    return triggerFlag;
  }
  
  public void display(){
    int stateIndex = 0;
    if( state == BUTTON_STATE.DEFAULT ) stateIndex = 0;
    else if( state == BUTTON_STATE.HOVER ) stateIndex = 1;
    else if( state == BUTTON_STATE.PRESSED ) stateIndex = 2;
    
    fillColors[stateIndex].setFill();
    strokeColors[stateIndex].setStroke();
    strokeWeight( 2 );
    box.drawRect();
    textAlign( CENTER, CENTER );
    //textFont( arial );
    textSize( box.boxH*0.7 );
    if( type == BUTTON_TYPE.TEXT_EXPANDING && state != BUTTON_STATE.DEFAULT ) textSize( box.boxH*0.75*1.1 ); //slightly expand text if type is text expanding
    
    textColors[stateIndex].setFill();
    text( text, box.x, box.y - box.boxH*0.1 );
    strokeWeight( 1 );
  }
}