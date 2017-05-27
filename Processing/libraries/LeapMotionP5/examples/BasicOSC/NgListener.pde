
class NgListener extends Listener {

  //  We want to track a)  Do we have a "gun" hand formation, and b) if so, 
  //  in what direction is it pointing, and at what angle?
  // Do we want to track yaw, pitch, and roll?

  boolean haveGun = false;
  boolean havePull = false;

  Vector indexDirection = Vector.zero();

  Vector palmNormal = Vector.zero();
  Vector handDirection = Vector.zero();
   Vector palmPosition = Vector.zero();
   
  float FINGER_RADS = radians(60); //   PI/3.5;   

  int currentThumbID = 0;
  int currentIndexID = 0;


  int previousThumbID = 0;
  int previousIndexID = 0;

  int baselineIndexLength = 0;

  boolean haveBaselineIndexLength;
  int frameCountForBaselineIndexLength = 0;
  int maxFrameCountForBaselineIndexLength = 100;

  //---------------------------------------------------------------------
  boolean haveBaselineIndexLength() {
    return haveBaselineIndexLength;
  }

  //---------------------------------------------------------------------
  void buildBaselineIndexLength(Finger indexFinger){
    if (haveBaselineIndexLength) {
      return;
    }

    frameCountForBaselineIndexLength++;

    if (baselineIndexLength == 0 ) {
      baselineIndexLength = (int)indexFinger.length();
    } else {
      baselineIndexLength += (int)indexFinger.length() ;
      baselineIndexLength = (int) (baselineIndexLength/2);
    }

    if(frameCountForBaselineIndexLength > maxFrameCountForBaselineIndexLength) {
      haveBaselineIndexLength = true;
    }

  }

  //---------------------------------------------------------------------
  void onInit(Controller controller) {
    println("Initialized");
  }

  //---------------------------------------------------------------------
  void onConnect(Controller controller) {
    println("Connected");
  }

  //---------------------------------------------------------------------
  void onDisconnect(Controller controller) {
    println("Disconnected");
  }


  //---------------------------------------------------------------------
  boolean havePull() {
    return havePull;
  }

  //---------------------------------------------------------------------
  void onFrame(Controller controller) {
// To avoid possible flickering in the sketch we do not want to change the haveGun state unless
// we have a reason.  If we set it to false at the start of each onFrame and then changed it we found the 
// matching hand formation there is the chance that the sketch will poll the data and grab that intial temporay
// state.

// Instead, we initalize to false, then only change it if the data support one or the other state.

    Frame frame = controller.frame();
    HandList hands = frame.hands();

    // What we want to do is somehow detect when the user curls then uncurls the "trigger" finger
    // That means we have two states: gun ( exactly 2 fingers, of proper angle), and then 1 (?) finger.
    // 
    // Can we detect when the trigger finger is curling?  Not _missing_, but halfway to being curled
    // back into the hand. 
    // We also need to track the time delta between "gun" and "shooting" so that we initiate
    // only one "fire!" event.

    if (hands.count() > 0 ) {
      println("Hand!");
      
      Hand hand = hands.get(0);
      
      FingerList fingers = hand.fingers();
      
      if (fingers.count() == 2) {
          
        Finger f1 = fingers.get(0);
        Finger f2 = fingers.get(1);
        println("2 Fingers! Lengths: 1 = " + f1.length() + ";\t2 = " + f2.length() );
        detectGun(f1, f2);
        if (haveGun) {
      
          println("Gun!");
          palmNormal = hand.palmNormal();
          handDirection = hand.direction();
          palmPosition = hand.palmPosition();
        } else {
          println("NO Gun!");
        }
     
      } else {
        println( "wrong  finger count! ("+ fingers.count() + ") NO GUN ");
        haveGun = false;
      }
      
    }  else  { // There are no hands, so thre is no gun
      haveGun = false;
      println("NO GUN! NO HNADS!");
    } 
  } 


  /*


     Some options:

1: Track finger IDs frame-to-frame.  If we have the same two fingers, and have established which is the
thumb, and have the length of the index finger, then if we find the index finger is shorter by 
not-quite-half then treat that as a trigger pull.

2: Track thumb and index.  If we have established a gun formation, and then suddenly have only the thumb,
treat that as a trigger action.

The problem with 2 is that you get a pull event if you rotate the hand to occlude the thumb.

This *shouldn't* happen but seems to.


The best would be to reqire two fingers, verifu that they are the same T and I from the gun formation, and if
the I is short enough (but still visible) it triggers the pull.

We need to establish a baseline length for I; comparing to previous frames doesn't help.


   */

  //---------------------------------------------------------------------
  void detectPull(Finger thumb){
    havePull = false;
    if(haveGun) {
      if (thumb.id() == previousThumbID ) {
        // We decide that if we have a single finger, and it's
        // the thumb from a previous gun formation, then this is a pull
        // action

        havePull = true;
        haveGun = false; // Make the user resestablish position
        println("*********************************************************************************");
        println("*********************   B L A AM ! ***************************************************");
        println("*********************************************************************************");
        // Leave the IDs variables alone
        return;
      }

    }
  }

  //------------------------------------------------------------
  void detectGun(Finger thumb, Finger index){

    if (index.length() < thumb.length() ){
      Finger ft = thumb;
      thumb = index;
      index = ft;
    }


    havePull = false;

    currentThumbID = thumb.id();
    currentIndexID = index.id();

    buildBaselineIndexLength(index);

    if (haveGun) {
      // If we have already established the hand formation then see if the finger lengths
      // may have changed by comparing to previous finger IDs. 

      if(haveBaselineIndexLength) {

        if (index.length() <  baselineIndexLength - ((int) baselineIndexLength/3 ) ) {
          havePull = true;
          haveGun = false; // Make the user resestablish position?
          println("*********************************************************************************");
          println("*********************   BANGO! ***************************************************");
          println("*********************************************************************************");
          // Leave the IDs variables alone
          return;
        } 
      }
    }



    //  We should have established here that the longer and shorter fingers are the same as last time we checked
    float rads = thumb.direction().angleTo(index.direction());

    println("Finger rads: " + rads + "; FINGER_RADS = " + FINGER_RADS  );
    println("baselineIndexLength: " + baselineIndexLength + ";  (int)index.length() = " +  (int)index.length()  );

    if ( rads  > FINGER_RADS ) {
      indexDirection =  index.direction();
      haveGun  = true;    
      previousThumbID = currentThumbID;
      previousIndexID = currentIndexID;
    } else {
      indexDirection =  Vector.zero();
      haveGun  = false;  
    } 

  }

  //------------------------------------------------------------
  Vector indexDirection(){
    return indexDirection;
  }

  //------------------------------------------------------------
  Vector handDirection(){
    return handDirection;
  }


  //------------------------------------------------------------
  Vector palmNormal(){
    return palmNormal;
  }

  Vector palmPosition(){
    return palmPosition;
  }

  //------------------------------------------------------------
  boolean haveGun(){
    return haveGun;
  }
} 

