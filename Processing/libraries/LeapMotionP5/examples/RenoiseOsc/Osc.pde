import oscP5.*;
import netP5.*;

OscP5 oscP5;

String configFile      = "config.txt";
Config config;

String clientOSCAddress = "127.0.0.1";
String renoiseAddress = "127.0.0.1";

NetAddress oscClientAddress;

int    clientOSCPort    = 8081;
int    renoiseOSCPort    = 7013;

OscBundle bundle; // = new OscBundle();

//-----------------------------------------------------------
void setupOsc()  {

  loadData();
  // oscP5 will let you construct an instance where you pass a IP address
  // but that does not work for us.
  // oscP5 = new OscP5(this, renoiseAddress, renoiseOSCPort);
  oscP5 = new OscP5(this, renoiseOSCPort);

  println(" Using OSC config values:");
  println(" renoiseOSCAddress:\t" + renoiseAddress);
  println(" renoiseOSCPort:\t" + renoiseOSCPort);

}

//-----------------------------------------------------------
void loadData(){
  println("***************************** DEBUG: load data ... ******************************"); // DEBUG

  config = new Config(configFile);
  config.load();
  clientOSCAddress = config.value("clientOSCAddress");
  renoiseAddress  = config.value("renoiseAddress"); 
  clientOSCPort    = config.intValue("clientOSCPort");
  renoiseOSCPort     = config.intValue("renoiseOSCPort"); 

  oscClientAddress = new NetAddress(renoiseAddress, renoiseOSCPort );
}


void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
  println(" arguments: "+theOscMessage.arguments()[0].toString());

  float value = (Float)theOscMessage.arguments()[0];
  float x, y; // If we get an `xy` message
  
  int control = 2;
  String[] parts = split(theOscMessage.addrPattern(), "/");
  println("parts[control]: '" + parts[control]  + "'" );

  String[] res;

  String reRotary = "(rotary)(.)";
  String reToggle = "(toggle)(.)";
  String rePush   = "(push)(.)";
  String reFader  = "(fader)(.)";
  String reXy  = "(xy)"; // Seems not to have an number

 

  res = match(parts[control], reFader);
  if (res != null) {
    println("FADER for " + res[2] );

      switch (int(res[2]) ){
        case 1:
          break;

        case 2:
         //fadeInterval  = int(map(value, 0.0, 1.0, 200., 400.)); 
          break;

          
        case 3:
         //fadeAmount  = map(value, 0.0, 1.0, 10., 100.); 

          break;
          
        case 4:
         //scMod = map(value, 0.0, 1.0, 1., 2.); 
          break;
      }
 //   rectScale[ int(res[2]) ] = map(value, 0.0, 1.0, 0.1, SCREEN_WIDTH);
    return;
  } 



  res = match(parts[control], reXy);
  if (res != null) {
    println("XY message"  );
   x = (Float)theOscMessage.arguments()[0];

  y = (Float)theOscMessage.arguments()[1];
  println("Have x, y = " + x + ", " + y ); // DEBUG

 //   rectScale[ int(res[2]) ] = map(value, 0.0, 1.0, 0.1, SCREEN_WIDTH);
    return;
  } 

}



void sendSetPatternLoop(int patternIndex ) {

  OscMessage m1 = new OscMessage("/renoise/transport/loop/sequence");
//  /renoise/transport/loop/sequence 2 2 | /renoise/song/sequence/schedule_set 2
  m1.add(patternIndex); 
  m1.add(patternIndex);
  
 
  OscMessage m2 = new OscMessage("/renoise/song/sequence/schedule_set");
  m2.add(patternIndex); 
  
  bundle = new OscBundle();
  bundle.add(m1);
  bundle.add(m2);

  bundle.setTimetag(bundle.now() + 100); // See why the example was adding time to this

  println(" renoiseOSCAddress:\t" + renoiseAddress);
  println(" renoiseOSCPort:\t" + renoiseOSCPort);

  
 // oscP5.send(bundle, oscClientAddress); 
  /// Gah! Not all servers understand bundles.  osc-ruby, for example. 
  oscP5.send(m1, oscClientAddress); 
  oscP5.send(m2, oscClientAddress); 
  println(". . . . . . . . . . . . . . . . . . . . . . . . Message sent.. . . . . . . . . . . . . . . . . . . . . . . . . . . . ");

  
  }

void sendSwapMessage(int t1, int t2) {

  OscMessage myMessage = new OscMessage("/ng/song/swap_volume");
 
  myMessage.add(t1); 
  myMessage.add(t2);
  myMessage.add(1.0); // This is currently ignored
 
  oscP5.send(myMessage, oscClientAddress); 
}

void sendLoopSchedule(int p1, int p2) {

  OscMessage myMessage = new OscMessage("/ng/loop/schedule");
 
  myMessage.add(p1); 
  myMessage.add(p2);
 
  oscP5.send(myMessage, oscClientAddress); 

}

void sendRenoiseStart() {
 println("Send renoise start message to " + oscClientAddress);
 OscMessage myMessage = new OscMessage("/renoise/transport/start");
 oscP5.send(myMessage, oscClientAddress); 
}


void sendRenoiseStop() {
 println("Send renoise stop message to " + oscClientAddress);
 OscMessage myMessage = new OscMessage("/renoise/transport/stop");
 oscP5.send(myMessage, oscClientAddress); 
}
