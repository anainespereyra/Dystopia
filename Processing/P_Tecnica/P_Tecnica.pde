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
int PuertoLocal1 = 7100; //arduino
int PuertoLocal2 = 7200; //arduino
int PuertoLocal3 = 7300; //leap
int PuertoLocal4 = 7400; //leap
int PuertoLocal5 = 7500; //leap

//Puerto que recibe datos en PC de graficos
int puertoRemoto = 6100;

//Direccion ip de la computadora a la que le mandaremos mensajes
String ipRemota = "localhost";

//Conexiones UDP
UDP udp1, udp2, udp3, udp4, udp5;
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
int numF;
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
  numF = 0;
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
  
  
  for (Hand hand : leap.getHands ()) {

    PVector handPosition = hand.getPosition();
    
     posX = handPosition.x;
     posY = handPosition.y;
     numF = hand.getOutstretchedFingers().size();
     
  }
  
  int m3 = int(posX);
  int m4 = int(posY);
  int m5 = int(numF);
  
  String message3  = str(m3);
  String message4  = str(m4);
  String message5  = str(m5);
  
  //-------------------------------------------------------------//
  
  
  //-------------------------------------------------------------//
  //## ENVIO DE MENSAJES A ORDENADOR DE GRAFICOS ##//
  //-------------------------------------------------------------//
  
  udp1.send( message1, ipRemota, puertoRemoto ); //arduino
  udp2.send( message2, ipRemota, puertoRemoto ); //arduino
  udp3.send( message3, ipRemota, puertoRemoto ); //leap
  udp4.send( message4, ipRemota, puertoRemoto ); //leap
  udp5.send( message5, ipRemota, puertoRemoto ); //leap
  //-------------------------------------------------------------//
  
  
  //-------------------------------------------------------------//
  //## DEBUG ##//
  //-------------------------------------------------------------//
  /*
  println("Arduino1: " + valueArduino1);
  println("Arduino2: " + valueArduino2);
  println("POS X = " + posX);
  println("POS Y = " + posY);
  println("num dedos = " + numF);
  */
  //-------------------------------------------------------------//

  println("POS Y = " + posY);
  println("num dedos = " + numF);
    
}