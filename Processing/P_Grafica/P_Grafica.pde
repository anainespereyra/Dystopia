
//-------------------------------------------------------------//
//##DESCRIPCION##//
//-------------------------------------------------------------//
//Recepcion de datos de ordenador remoto de sensores por UDP
//-------------------------------------------------------------//
 
//-------------------------------------------------------------//
//##LIBRERIAS##//
//-------------------------------------------------------------//
import hypermedia.net.*; //UDP
import oscP5.*; //OSC
import netP5.*; //OSC
import codeanticode.syphon.*; //Syphon
//-------------------------------------------------------------//

//-------------------------------------------------------------//
//##CONECTIVIDAD##//
//-------------------------------------------------------------//
//Para conexion con Syphon
SyphonServer server;

//Para conexion OSC con Resolume
//Direccion ip de la computadora a la que le mandaremos mensajes (donde esta el Resolume)
String ipAddressToSendTo = "localhost";
OscP5 oscP5;
NetAddress myRemoteLocation;
OscBundle myBundle;
OscMessage myMessage;

//PuertoLocal que recibe de Resolume
int portToListenToResolume = 7001; 
//Puerto que envía a Resolume
int portToSendToResolume = 7000;
//ESTOS PUERTOS TIENEN QUE ESTAR SETEADOS EN RESOLUME

//Se definen objetos UDP
UDP udp;

//Puerto local por el que se reciben datos de sensores
int puertoLocal = 6100;

//Puertos remotos de pc de sensores
//Verificar que sean los mismos que en el otro codigo
int PuertoRemoto1 = 7100; //arduino 
int PuertoRemoto2 = 7200; //arduino 
int PuertoRemoto3 = 7300; //leap 
int PuertoRemoto4 = 7400; //leap 
int PuertoRemoto5 = 7500; //leap 
//-------------------------------------------------------------//

//-------------------------------------------------------------//
//##DATA##//
//-------------------------------------------------------------//
int val1 = 0; //arduino1
int val2 = 0; //arduino2
int val3 = 0; //leap (x)
int val4 = 0; //leap (y)
int val5 = 0; //leap (streched Fingers)

int MAX_DISTANCE = 50; //CAMBIAR TAMBIEN EN CODIGO ARDUINO

//Variables para la parte grafica
float t;
int[] numF = new int[5];
int n;
Vol[][] p = new Vol[150][150];
//-------------------------------------------------------------//



void settings(){
  size(1920, 530, P2D);
  PJOGL.profile=1;
}

  
  
void setup() {
  
  //-------------------------------------------------------------//
  //##CONECTIVIDAD##//
  //-------------------------------------------------------------//
  //Se crea conexion OSC para enviar ordenes a resolume
  oscP5 = new OscP5(this, portToListenToResolume);
  myRemoteLocation = new NetAddress(ipAddressToSendTo, portToSendToResolume);  
  myBundle = new OscBundle();
  myMessage = new OscMessage("/"); 

  // Se crea conexion UDP para recibir datos de sensores
  udp = new UDP( this, puertoLocal );
  udp.listen( true );
  
  //syphone
  server = new SyphonServer(this, "Processing Syphon");
  //-------------------------------------------------------------//
  
  //-------------------------------------------------------------//
  //##GRAFICA##//
  //-------------------------------------------------------------//
  background(0);
  fill(0,0,0,30);
  for(int i = 0; i < p.length * p.length; i++) {
    p[i/p.length][i%p.length] = new Vol(i/p.length * 4, i%p.length * 4);
  }
  //-------------------------------------------------------------//
}


//-------------------------------------------------------------//
//##RECEPCION DATOS ORDENADOR SENSORES##//
//-------------------------------------------------------------//
void receive( byte[] data, String ip, int port ) {	// <-- extended handler
  
  String message = new String( data );
  
  //Se clasifican mensajes segun el puerto de envio
  if (port == PuertoRemoto1) {
     val1 = int(message);
  } else if (port == PuertoRemoto2) {
     val2 = int(message);
  } else if (port == PuertoRemoto3) {
     val3 = int(message);
  } else if (port == PuertoRemoto4) {
     val4 = int(message);
  } else if (port == PuertoRemoto5) {
     val5 = int(message);
  }

}
//-------------------------------------------------------------//


void draw() {
  
  //-------------------------------------------------------------//
  //## GENERACION DE GRAFICOS ##//
  //-------------------------------------------------------------//
  
  //Funcion generacion particulas con arduino (distancia)
  float opacidad = map(float(val1), 0, float(MAX_DISTANCE), 0, 100);
  opacidad = opacidad - 10;
  for(n=0; n<530; n+=10) {
    stroke(150, opacidad);
    line(0, n, 1920, n);
  }
  
  
  //Funcion generación de particulas con el movimiento manos
  rect(0,0,width,height);
    stroke(255);
    for(Vol[] d:p)for(Vol q:d)
      q.update(val3*10,val4*10);
      t += 0.01;
      
  //-------------------------------------------------------------//
     
  //envio pantalla a Resolume   
  server.sendScreen();
  //-------------------------------------------------------------//
  
  
  
  //-------------------------------------------------------------//
  //## ENVIO DE ORDENES A RESOLUME CON OSC ##//
  //-------------------------------------------------------------//
  

  //Se escriben mensajes para Resolume
  myMessage.setAddrPattern("/layer1/clip1/video/opacity/values");
  myMessage.add(map(float(val2), 0.0, float(MAX_DISTANCE), 0.0, 1.0));
  myBundle.add(myMessage);
  myMessage.clear();
  
  //Envio del mensaje
  oscP5.send(myBundle, myRemoteLocation); 
  myBundle.clear();
  //-------------------------------------------------------------//

  
  //-------------------------------------------------------------//
  //## DEBUG ##//
  //-------------------------------------------------------------//
  /*
  println( "val1: "+val1 );
  println( "val2: "+val2 );
  println( "val3: "+val3 );
  println( "val4: "+val4 );
  println( "val5: "+val5 );
  */
  //-------------------------------------------------------------//

}



//Creamos la clase VOl
class Vol {
  float x;
  float y;
  float xv;
  float yv;
  float w;
  float ww;
  float gu;
  float hu;
  Vol(int x2, int y2) {
    x = random(width);
    y = random(height);
    w = random(1,1);
    ww = random(-1,1);
    gu = x2;
    hu = y2;
  }
  
  void update(float fingerX, float fingerY) {
    stroke(255, 255, 255, 30);
    float m = 100;
    float d = dist(width/m,height/m,mouseX/m,mouseY/m);
    xv += 0.001*(fingerX-x)*pow(d, ww)*w;
    yv += 0.001*(fingerY-y)*pow(d, ww)*w;
    float drg = (noise(x/20+492,y/20+490,t*5.2)-0.5)/300 + 1.05;
    xv /= drg;
    yv /= drg;
    xv += noise(x/20,y/20,t)-0.5;
    yv += noise(x/20,y/20+424,t)-0.5;
    x += xv;
    y += yv;
    line(x,y,x-xv/3,y-yv/3);
  }
}