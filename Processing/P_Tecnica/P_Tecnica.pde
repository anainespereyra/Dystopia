//-------------------------------------------------------------//
//##DESCRIPCION##//
//-------------------------------------------------------------//
//Recepcion de datos de sensores
//Envio de datos a processing-processing ordenador remoto por UDP
//-------------------------------------------------------------//
 
//-------------------------------------------------------------//
//##LIBRERIAS##//
//-------------------------------------------------------------//
import hypermedia.net.*; //UDP
import processing.serial.*; //Serial
import oscP5.*; //OSC
import netP5.*; //OSC
import de.voidplus.leapmotion.*; //Leap
//-------------------------------------------------------------//

//-------------------------------------------------------------//
//##CONECTIVIDAD##//
//-------------------------------------------------------------//
//Puertos locales por los que se envian los datos
int PuertoLocal1 = 7100; //arduino1
int PuertoLocal2 = 7200; //arduino2
int PuertoLocal3 = 7300; //leapX
int PuertoLocal4 = 7400; //leapY
int PuertoLocal5 = 7500; //leapZ
int PuertoLocal6 = 7600; //HAND-DETECTED

//Puerto que recibe datos en PC de graficos
int puertoRemoto = 6100;

//Direccion ip de la computadora a la que le mandaremos mensajes
String ipRemota = "192.168.0.101";

//Conexiones UDP
UDP udp1, udp2, udp3, udp4, udp5, udp6;

//-------------------------------------------------------------//

//-------------------------------------------------------------//
//## ARDUINO ##//
//-------------------------------------------------------------//

//Conexiones serie para recibir datos de Arduino
Serial ArduinoPort1;
Serial ArduinoPort2;

//Variables Arduino
int valueArduino1;
int valueArduino2;
//-------------------------------------------------------------//

//-------------------------------------------------------------//
//## LEAP MOTION ##//
//-------------------------------------------------------------//
LeapMotion leap;

float posX;
float posY;
float posZ;
//int swipe = 0;
//int numF;
//-------------------------------------------------------------//

void setup() {
  
  //-------------------------------------------------------------//
  //## ARDUINO ##//
  //-------------------------------------------------------------//
  
  String port1 = Serial.list()[0]; 
  String port2 = Serial.list()[1];
  
  ArduinoPort1 = new Serial(this, port1, 9600);
  ArduinoPort2 = new Serial(this, port2, 9600);
  
  valueArduino1 = 0;
  valueArduino2 = 0;
  //-------------------------------------------------------------//
  
  
  
  //-------------------------------------------------------------//
  //## LEAP MOTION ##//
  //-------------------------------------------------------------//
  
  
  leap = new LeapMotion(this).allowGestures(); 
  leap = new LeapMotion(this);
  
  posX = 0;
  posY = 0;
  posZ = 0;
  //numF = 0;
  //-------------------------------------------------------------//
  
  
  
  //-------------------------------------------------------------//
  //## CONECTIVIDAD ##//
  //-------------------------------------------------------------//
  // Se crean conexiones UDP para enviar a pc de graficos
  udp1 = new UDP( this, PuertoLocal1 );
  udp2 = new UDP( this, PuertoLocal2 );
  udp3 = new UDP( this, PuertoLocal3 );
  udp4 = new UDP( this, PuertoLocal4 );
  udp5 = new UDP( this, PuertoLocal5 );
  udp6 = new UDP( this, PuertoLocal6 );

  //-------------------------------------------------------------//


}


void draw() {
  
  //-------------------------------------------------------------//
  //## PROCESAMIENTO DATOS ARDUINO ##//
  //-------------------------------------------------------------//

  //Recepcion datos de Arduino
  
  
  if ( ArduinoPort1.available() > 0) {  // If data is available,
    valueArduino1 = ArduinoPort1.read();         // read it and store it in val
  }
  if ( ArduinoPort2.available() > 0) {  // If data is available,
    valueArduino2 = ArduinoPort2.read();         // read it and store it in val
  }
  
  //se pasa a string para enviar la data
  String message1  = str(valueArduino1);
  String message2  = str(valueArduino2);
  
  //-------------------------------------------------------------//
  
  
  //-------------------------------------------------------------//
  //## PROCESAMIENTO DATOS LEAP MOTION ##//
  //-------------------------------------------------------------//
  
  //pasamos una variable a grafica para indicarle si hay alguna mano detectada o no
  int m6 = 0;
  
  if (leap.hasHands()) {
    m6 = 1;
  }else{
    m6 = 0;
  }
  
  for (Hand hand : leap.getHands ()) {

    PVector handPosition = hand.getPosition();
    
     posX = handPosition.x;
     posY = handPosition.y;  
     posZ = handPosition.z;
     //numF = hand.getOutstretchedFingers().size();

    
  }
  
  
  int m3 = int(posX);
  int m4 = int(posY);
  int m5 = int(posZ);
  
  
  String message3  = str(m3);
  String message4  = str(m4);
  String message5  = str(m5);
  String message6  = str(m6);
  //-------------------------------------------------------------//
  
  
  //-------------------------------------------------------------//
  //## ENVIO DE MENSAJES A ORDENADOR DE GRAFICOS ##//
  //-------------------------------------------------------------//
  
  udp1.send( message1, ipRemota, puertoRemoto ); //arduino1
  udp2.send( message2, ipRemota, puertoRemoto ); //arduino2
  udp3.send( message3, ipRemota, puertoRemoto ); //leapX
  udp4.send( message4, ipRemota, puertoRemoto ); //leapY
  udp5.send( message5, ipRemota, puertoRemoto ); //leapZ
  udp6.send( message6, ipRemota, puertoRemoto ); //hasHands
  
  //-------------------------------------------------------------//
  
  
  //-------------------------------------------------------------//
  //## DEBUG ##//
  //-------------------------------------------------------------//
  
  /*println("Arduino1: " + valueArduino1);
  println("Arduino2: " + valueArduino2);
  println("POS X = " + posX);
  println("POS Y = " + posY);
  println("num dedos = " + numF);*/
  
  //-------------------------------------------------------------//
  //println("HAS HAND = " + m6);
    
}





/*void leapOnSwipeGesture(SwipeGesture g, int state){
  
  String message6;
  PVector direction        = g.getDirection();
  int m6 = 0;
  message6 = str(m6);
  switch(state){
    case 1: // Start
      break;
    case 2: // Update
      break;
    case 3: // Stop
      //println("Posicio inicial" + positionStart);
      //println("Posicio actual" + position);
      //println("DIRECCIÓ: " + direction.x);
      if (direction.x >= 0){
          //Moviment DRETA
          //println("DRETA");
         // println("SwipeGesture: " + id);
         m6 = 1;
         message6  = str(m6);
      }else{
          //println("ESQUERRA");
          //println("SwipeGesture: " + id);
          m6 = 2;
          message6  = str(m6);
      }
      break;
  }
  //udp6.send( message6, ipRemota, puertoRemoto ); //leap-swipe
  
  
}

void leapOnCircleGesture(CircleGesture g, int state){

  float   durationSeconds  = g.getDurationInSeconds();
  int     direction        = g.getDirection();
  
  String message7;
  int m7 = 0;
  message7 = str(m7);

  switch(state){
    case 1: // Start
      break;
    case 2: // Update
      break;
    case 3: // Stop
      //println("CircleGesture: " + id);
      break;
  }

  switch(direction){
    case 0: // Anticlockwise/Left gesture
     //Anticlockwise (left)
      //println("ANTICLOCKWISE (LEFT) ");
      //println("Circle Gesture Direction: " + direction);
      //println("Duration" + durationSeconds*100); //microseconds
      m7 = 2;
      message7  = str(m7);
      break;
    case 1: // Clockwise/Right gesture
            //Clockwise (right)
      //println("CLOCKWISE (RIGHT) ");
      //println("Circle Gesture Direction: " + direction);
      //println("Duration" + durationSeconds*100); //microseconds
      m7 = 1;
      message7  = str(m7);
      break;
  }
  //udp7.send( message7, ipRemota, puertoRemoto ); //leap-swipe
  m7 = 0;
}*/