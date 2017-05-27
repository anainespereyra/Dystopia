import com.neurogami.leaphacking.*;


Vector avgPos;
int fingerCount;

float yMax, xMax;
float yMin, xMin;

int redZoneMinZ = 77;

LeapMotionP5 leap;



int PATTERN_LOOP = 0;
int TRACK_MUTE   = 1;

long lastActionTimestamp = 0;
long lastActionDelta = 2000;


int statePointer = 0;

int messageStates[] = {PATTERN_LOOP, TRACK_MUTE };
int MAX_STATES  = messageStates.length;

PImage modeScreens[] = new PImage[2];


int currentMessageState = PATTERN_LOOP;

// Need some sort of deque pattern thing or whatever it is called,
// where you justask for the next value in a circular data structure.
// May want a class for State so that it is easier to associate a value and a display name.


void nextState() {
  statePointer++;
  statePointer %= MAX_STATES;

}


void dispose() {
  println("XXXXXXXX TIME TO EXIT XXXXXXXXXXXXXXXX");
  sendRenoiseStop();
  //exit();

}

int currentState(){
  return(messageStates[statePointer] );
}

com.leapmotion.leap.Gesture.Type gestType;

void setup() {
  size(displayWidth, displayHeight, OPENGL);
  registerMethod("dispose", this);

  modeScreens[PATTERN_LOOP]  = loadImage("pattern_loop.png"); 
  modeScreens[TRACK_MUTE]  = loadImage("track_loop.png"); 

  setupOsc();
  noLoop();
  yMax = xMax =  -100;
  yMin = xMin =  1300;

  avgPos = Vector.zero();
  leap = new LeapMotionP5(this, true);
  leap.allowBackgroundProcessing(true);

  // CUrious detail: If you use the onFrame callback approach you do not need to
  // reference the Controller (except for inside the onFrame event), but if you
  // want to enable gestures you do need the controller reference.
  //
  // Need some pass-though proxy methods for controller-y stuff so that a user does not
  // have to first ask for a controller just to invoke stuff

  leap.controller.enableGesture(Gesture.Type.TYPE_SWIPE);
  leap.controller.enableGesture(Gesture.Type.TYPE_CIRCLE);

  // It's also possible now to set some parameters that determine when a gesture is 
  // detected. May want some P5-ish API on that as well.

  /*
   *
   Key string	            Value type	Default value	    Units
   Gesture.Swipe.MinLength	  float	      150	              mm
   Gesture.Swipe.MinVelocity	    float	      1000	            mm/s

   */

  if(leap.controller.config().setFloat("Gesture.Swipe.MinLength", 200.0f) &&
      leap.controller.config().setFloat("Gesture.Swipe.MinVelocity", 750f))
    leap.controller.config().save();
  /*
     Key string	              Value type	Default value	  Units
     Gesture.Circle.MinRadius	float	      5.0	            mm
     Gesture.Circle.MinArc	    float	      1.5*pi	      radians



     2*pi Radians are in a complete circle.

     2*pi  = 2 x 3.141593 or just 2 x 3.14 

     A full circle is therefor  6.283185 or just 6.28.

     The default is 3/4 of a full circle.  Good enough.

   */

  sendRenoiseStart();

}

void onFrame(com.leapmotion.leap.Controller controller) {
  processController(controller);
}

void processController(com.leapmotion.leap.Controller controller) {


  Frame frame = controller.frame();
  HandList hands = frame.hands();

  if (hands != null) {
    if (hands.count() > 0 ) {

      //println("\tDraw: Have hands.count() = " + hands.count() );
      //println("****************** Hand ****************************");
      Hand hand = hands.get(0);

      FingerList fingers = hand.fingers();
      fingerCount = fingers.count();
      if (fingerCount > 0) {
        //println(" ******** Fingers " + fingerCount + " ****** ");

        avgPos = Vector.zero();

        for (Finger finger : fingers) {
          avgPos = avgPos.plus(finger.tipPosition());
        }

        avgPos = avgPos.divide(fingerCount);
        // println("avgPos x: " + avgPos.getX() );
        // println(" # # # # # # # # # # #   * * * * * * * *  Fingers " + fingerCount  + " > 1 SEND OSC * * * * * *   # # # # # # # #");
        if (frame.gestures().count() > 1 ) {

          println(" ********************************************************************************************* ");
          println(" ***********            GESTURES                ************************************************ ");
          println(" ********************************************************************************************* ");

          for(int n=0; n < frame.gestures().count(); n++) {
            gestType = frame.gestures().get(n).type();

            if (frame.gestures().get(n).state() == com.leapmotion.leap.Gesture.State.STATE_STOP ) {
              if (gestType  == com.leapmotion.leap.Gesture.Type.TYPE_CIRCLE ) {
                println(" ***********      ( ( ( ( ( (   C I R C L E ) ) ) ) ) )         ************************************************ ");
                if  ( frame.timestamp() - lastActionTimestamp  > lastActionDelta ) {
                  lastActionTimestamp  = frame.timestamp();
                  nextState();
                }

              }

              if (gestType == com.leapmotion.leap.Gesture.Type.TYPE_SWIPE ) {
                if (currentState() == PATTERN_LOOP ) {
                  sendSetPatternLoop( fingerCount );
                } 
              }
            }



          }


        }


        redraw();
      } // if fingers

    } //  if hands 

  }

}

PImage stateBackground() {
  return modeScreens[currentState()];
}




//-------------------------------------------------------------------
void draw() {
  background(stateBackground());


  writePosition();
}


//-------------------------------------------------------------------
Vector lastPos() {
  Vector  lp = avgPos;

  // Although the point-rendering is restricted to the size of the screen,
  // it's interesting to see the range values detected.
  if (lp.getX() < xMin ){ xMin = lp.getX(); }
  if (lp.getY() < yMin ){ yMin = lp.getY(); }

  if (lp.getX() > xMax ){  xMax = lp.getX(); }
  if (lp.getY() > yMax ){  yMax = lp.getY(); }

  // println(lp);

  return lp;
}



int mapXforScreen(float xx) {
  int topX = 150;
  int x  = constrain( int(xx), topX * -1, topX);
  return( int( map(x, topX * -1, topX, 0, width) ) );
}

//-------------------------------------------------------------------
int mapYforScreen(float yy) {

  int topY = 300;
  int y  = constrain( int(yy), 0, topY);

  return( int( map(y, 0, topY,  height, 0) ) );
}


//-------------------------------------------------------------------
int zToColorInt(float fz) {

  int z = int(fz);

  int minZ = -220;
  int maxZ = 200;

  if (z < minZ) {
    return 0;
  }

  if (z > maxZ) {
    return 255;
  }

  return int(map(z, minZ, maxZ,  0, 255));
}


boolean inTriggerZone(float fz) {

  int z = int(fz);

  if ( z > redZoneMinZ ) {
    return true;
  }

  return(false);

}

void writePosition(){

  int zMap = zToColorInt( lastPos().getZ());
  int baseY = mapYforScreen( lastPos().getY() );
  int inc = 30;
  int xLoc = mapXforScreen(lastPos().getX()); 

  textSize(32);


  fill(zMap, zMap, zMap);

  if (inTriggerZone(lastPos().getZ()) ) {
    fill(255, 0, 0);

  }
  // println("lastPos() X : " + lastPos() );
  text("X: " + lastPos().getX() , xLoc, baseY);
  text("Y: "  + lastPos().getY(), xLoc, baseY + inc*2 );
  text("Z: "  + lastPos().getZ(), xLoc, baseY + inc*3 );
  text("Fingers: "  + fingerCount, xLoc, baseY + inc*4 );
  //  text("min X: "  + xMin, xLoc, baseY + inc*4 );
  // text("max X: "  + xMax, xLoc, baseY + inc*5 );

  ///  text("min Y: "  + yMin, xLoc, baseY + inc*6 );
  // text("max Y: "  + yMax, xLoc, baseY + inc*7 );

}

