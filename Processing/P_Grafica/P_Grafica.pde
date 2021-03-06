


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
//import codeanticode.syphon.*; //Syphon
import spout.*; //Spout (como syphon para windows)
import ddf.minim.*; //audio
//import processing.sound.*;


//-------------------------------------------------------------//

//-------------------------------------------------------------//
//##CONECTIVIDAD##//
//-------------------------------------------------------------//
//Para conexion con Syphon
//SyphonServer server;
Spout spout;

//Audio array para archivar toda la 'data
//SoundFile[] file;

//para controlar las notas del audio
int nota = 0;
int sonidoLeap= 0;
int sonidoCentral= 0;
//para saber cuantos archivos de audio tendremos

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
int PuertoRemoto6 = 7600; //leap hand detected y/n -> 0/1
//int PuertoRemoto7 = 7700; //leap circle

//-------------------------------------------------------------//

//-------------------------------------------------------------//
//##DATA##//
//-------------------------------------------------------------//
int val1 = 0; //arduino1
int val2 = 0; //arduino2
int val3 = 0; //leap (x)
int val4 = 0; //leap (y)
int val5 = 0; //leap (z)
int val6 = 0; //leap hand detected


//int val7 = 0; //leap (swipe gesture 0=none;1=right;2=left)
//int val8 = 0; //leap (circle gesture 0=none;1=right;2=left)


int MAX_DISTANCE_ARDUINO = 50; //CAMBIAR TAMBIEN EN CODIGO ARDUINO

int MAX_DISTANCE_LEAPX = 85; 
int MAX_DISTANCE_LEAPY = 90; //TENER EN CUENTA QUE LA Y SE MIDE AL REVES
int MAX_DISTANCE_LEAPZ = 70;

//Variables para la parte grafica

int cuantos = 30000;
Textura[] tex ;
float rx = 0;
float ry = 0;

//input audios
Minim minim;

AudioPlayer player1;
AudioPlayer player2;
AudioPlayer player3;
AudioPlayer player4;
AudioPlayer player5;
AudioPlayer player6;
AudioPlayer player7;
AudioPlayer player8;
AudioPlayer player9;
AudioPlayer player10;
AudioInput input;


int movimientoX = 0;
int movimientoY = 0;
int movimientoZ = 0;


//float t;
//int[] numF = new int[5];
//int n;
//Vol[][] p = new Vol[70][70];
//-------------------------------------------------------------//


void settings() {
  size(1920, 530, P3D);
  //PJOGL.profile=1;
}
/*void settings(){
  size(1920, 1080, P2D);
  PJOGL.profile=1;
}*/

  
  
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
  //server = new SyphonServer(this, "Processing Syphon");
  spout = new Spout(this);
  spout.createSender("SpoutProc");
  
  //-------------------------------------------------------------//
  
  //-------------------------------------------------------------//
  //##GRAFICA##//
  //-------------------------------------------------------------//

  tex = new Textura[cuantos];
  for(int i=0; i< tex.length; i++) {
  tex[i] = new Textura();
  }
  
  // --------------------------------------------------------------//
  // SONIDO //
  //----------------------------------------------------------------//
  minim = new Minim(this);
  player1 = minim.loadFile("esfera1.wav");
  player2 = minim.loadFile("esfera2.wav");
  player3 = minim.loadFile("esfera3.wav");
  player4 = minim.loadFile("esfera4.wav");
  player5 = minim.loadFile("esfera5.wav");
  player6 = minim.loadFile("esfera6.wav");
  player7 = minim.loadFile("esfera7.wav");
  player8 = minim.loadFile("esfera8.wav");
  player9 = minim.loadFile("esfera9.wav");
  player10 = minim.loadFile("esfera10.wav");
  input = minim.getLineIn();
  
  player1.setGain(-5.0f);
  player2.setGain(-5.0f);
  player3.setGain(-5.0f);
  player4.setGain(-5.0f);
  player5.setGain(-5.0f);
  player6.setGain(-5.0f);
  player7.setGain(-5.0f);
  player8.setGain(-5.0f);
  player9.setGain(-5.0f);
  player10.setGain(-5.0f);
  
  
  //file = new SoundFile[10];
  
  /*for (int i = 0; i < 1; i++){
    file[i] = new SoundFile(this, "esfera" + (i+1) + ".wav");
  }*/
  //file[1] = new SoundFile(this,"1.mp3");
  
  
  /*background(0);
  fill(0,0,0,30);
  for(int i = 0; i < p.length * p.length; i++) {
    p[i/p.length][i%p.length] = new Vol(i/p.length * 4, i%p.length * 4);*/
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
  } else if (port == PuertoRemoto6) {
     val6 = int(message); 
  } /*else if (port == PuertoRemoto7) {
     val7 = int(message);
  }*/

}
//-------------------------------------------------------------//


void draw() {
  
  //-------------------------------------------------------------//
  //## GENERACION DE GRAFICOS ##//
  //-------------------------------------------------------------//
/*if (val4 < 0 ){
  val4 = 0;
}
if (val4 > MAX_DISTANCE_LEAPY){
   val4 = MAX_DISTANCE_LEAPY;
}*/

  //se convierte a tamaño de pantalla
  movimientoX = (int)map(float(val3), 0.0, float(MAX_DISTANCE_LEAPX), 0.0, 1920);
  movimientoY = (int)map(float(val4), 0.0, float(MAX_DISTANCE_LEAPY), 0.0, 530);
  movimientoZ = (int)map(float(val5), 0.0, float(MAX_DISTANCE_LEAPZ), 0.0, 530);


  background(0);
  //control movimiento esfera
  float rx = (movimientoX-(width/2))*0.005;
  float ry = (movimientoY-(height/2))*0.005;
  rx = rx*0.9;
  ry = ry*-0.9;
  //posición esfera
  translate(width/2, height/2);
 
 //descontrol cuando no aparece manos
 
  
  // boolean true cuando una de las manos está fuera de su rango
  
    /*if (movimientoY > 0 && movimientoY < 600){
      //LA MANO ESTA DENTRO DEL RANGO DE DETECCION DEL LEAP
      fueraManoY = false;
    } else {
      //LA MANO ESTA FUERA DEL RANGO DE DETECCION DEL LEAP
      fueraManoY = true;
    }
  
    if (movimientoX > -500 && movimientoX < 2000){
      //LA MANO ESTA DENTRO DEL RANGO DE DETECCION DEL LEAP
      fueraManoX = false;
    } else {
      //LA MANO ESTA FUERA DEL RANGO DE DETECCION DEL LEAP
      fueraManoX = true;
    }*/
      
      // LEAP NO DETECTA NINGUNA MANO
      if (val6 == 0){
        //println("NO hay MANO " + val6);
        val3 = 0;
        val4 = 0;
        val5 = 0;
        rotateY(random(-100,100));
        rotateX(random(-100,100));
        sphereDetail(1);
        //nota = 0;
        // LEAP DETECTA ALGUNA MANO
      }else {
        //println("SI hay MANO " + val6);

        rotateY(rx);
        rotateX(ry);
      }
      
      
       //LEAP MOTION
  int val3Mod = val3;
  int val4Mod = val4;
  int val5Mod = val5;
  
   if (val3Mod < 0){
    val3Mod = 0;
  }
  if (val3Mod > MAX_DISTANCE_LEAPX){
    val3Mod = MAX_DISTANCE_LEAPX;
  }
  
  if (val4Mod < 0){
    val4Mod = 0;
  }
  if (val4Mod > MAX_DISTANCE_LEAPY){
    val4Mod = MAX_DISTANCE_LEAPY;
  }
  if (val5Mod < 0){
    val5Mod = 0;
  }
  if (val5Mod > MAX_DISTANCE_LEAPZ){
    val5Mod = MAX_DISTANCE_LEAPZ;
  }

      
  /*
  if (movimientoX < 1) {
  rotateY(random(-100, 100));
  rotateX(random(-100, 100));
  }
  else {
  rotateY(rx);
  rotateX(ry);
  }*/
  
  //Funcion generación de particulas con el movimiento manos
  /*rect(0,0,width,height);
    stroke(255);
    for(Vol[] d:p)for(Vol q:d)
      q.update(val3*10,val4*10);
      t += 0.01;*/
 
  //caracteristicas esfera
   /* if (movimientoY < 540 && movimientoY >= 0){
      fill(movimientoY/2);
    }else{
      fill(0);  
    }
    */
    fill(0);  
    stroke(255);
    //sphereDetail(1);
    sphere(100);
  
    for (int i = 0; i < tex.length; i++) {
      tex[i].dibujar();
   
  }
  //-------------------------------------------------------------//
     
  // NOTAS MUSICALES
 
//println(movimientoY);

    if (nota != 1 && movimientoY <= 106){
      nota = 1;
      /*if (!player1.isPlaying()){
        player1 = minim.loadFile("esfera1.wav");
        player1.play();
      }*/
      player1.rewind();
      player1.play();
      //file[0].play();
      sphereDetail(1);
      //println("1");
     }
   if (movimientoY > 106 && movimientoY <= 159) {
      if (nota != 2){
      nota = 2;
       /*if (!player2.isPlaying()){
        player2 = minim.loadFile("esfera2.wav");
        player2.play();
       }*/
       player2.rewind();
       player2.play();
      // file[1].play();
      sphereDetail(2);
      //println("2");
     }

} if (movimientoY > 159 && movimientoY <= 212) {
    if (nota != 3){
        nota = 3;
       /* if (!player3.isPlaying()){
          player3 = minim.loadFile("esfera3.wav");
          player3.play();
        }*/
      //  file[2].play();
      player3.rewind();
      player3.play();
        sphereDetail(3);
       // println("3");
       }

} if (movimientoY > 212 && movimientoY <= 265) {
  
      if (nota != 4){
      nota = 4;
      
     /* if (!player4.isPlaying()){
        player4 = minim.loadFile("esfera4.wav");
        player4.play();
      }*/
    //  file[3].play();
    player4.rewind();
    player4.play();
      sphereDetail(4);
      //println("4");
     }

} if (movimientoY > 265 && movimientoY <= 318) {
    if (nota != 5){
      nota = 5;
      
      /*if (!player5.isPlaying()){
        player5 = minim.loadFile("esfera5.wav");
        player5.play();
      }*/
    //  file[4].play();
    player5.rewind();
    player5.play();
      sphereDetail(5);
      //println("5");
     }

} if (movimientoY > 318 && movimientoY <= 371) {
   if (nota != 6){
      nota = 6;
      
     /* if (!player6.isPlaying()){
        player6 = minim.loadFile("esfera6.wav");
        player6.play();
      }*/
    //  file[5].play();
    player6.rewind();
    player6.play();
      sphereDetail(6);
      //println("6");
     }

} if (movimientoY > 371 && movimientoY <= 424) {
   if (nota != 7){
      nota = 7;
      /*if (!player7.isPlaying()){
        player7 = minim.loadFile("esfera7.wav");
        player7.play();
      }*/
    //  file[6].play();
    player7.rewind();
    player7.play();
      sphereDetail(7);
      //println("7");
     }

} if (movimientoY > 424 && movimientoY <= 477) {
   if (nota != 8){
      nota = 8;
      
      /*if (!player8.isPlaying()){
        player8 = minim.loadFile("esfera8.wav");
        player8.play();
      }*/
    //  file[7].play();
    player8.rewind();
    player8.play();
      sphereDetail(10);
      //println("8");
     }

} if (movimientoY > 477 && movimientoY <= 500 && nota != 9) {
   if (nota != 9){
      nota = 9;
      /*if (!player9.isPlaying()){
        player9 = minim.loadFile("esfera9.wav");
        player9.play();
      }*/
    //  file[8].play();
    player9.rewind();
    player9.play();
      sphereDetail(15);
      //println("9 = "  + nota);
     }

} if (movimientoY > 500 && nota != 10) {
   if (nota != 10){
      nota = 10;
      /*if (!player10.isPlaying()){
        player10 = minim.loadFile("esfera10.wav");
        player10.play();
      }*/
   //   file[9].play();
       player10.rewind();
       player10.play();
      sphereDetail(30);
      //println("10 = " + nota);
     }
}
  
  
  //envio pantalla a Resolume   
  //server.sendScreen();
  spout.sendTexture();
  //-------------------------------------------------------------//
  
  
  
  //-------------------------------------------------------------//
  //## ENVIO DE ORDENES A RESOLUME CON OSC ##//
  //-------------------------------------------------------------//
  //Ejemplos de mensajes
  // "/layer1/clip1/connect" --> selecciona clip1 de layer1
  // "/layer1/clip1/video/effect1/param1/values" --> modifica parametro1 de efecto1 de video de clip1 en capa1
  //-------------------------------------------------------------//
  ///activeclip/video/effect1/param1/values
  

  //Se escriben mensajes para Resolume
  
  
   //ARDUINO 1
  myMessage.setAddrPattern("/layer3/clip1/video/effect1/opacity/values");
  myMessage.add(map(float(MAX_DISTANCE_ARDUINO - val1), 0.0, float(MAX_DISTANCE_ARDUINO - 5), 0.0, 1.0)); // el -5 es porque no llegaba a tope
  myBundle.add(myMessage);
  myMessage.clear();
  
  myMessage.setAddrPattern("/layer4/clip1/audio/volume/values");
  myMessage.add(map(float(MAX_DISTANCE_ARDUINO - val1), 0.0, float(MAX_DISTANCE_ARDUINO - 5), 0.7, 0.83));  //Sonido logaritmico
  myBundle.add(myMessage);
  myMessage.clear();
  
  myMessage.setAddrPattern("/layer9/clip1/video/opacity/values");
  myMessage.add(map(float(MAX_DISTANCE_ARDUINO - val1), 0.0, float(MAX_DISTANCE_ARDUINO - 5), 0.0, 1.0)); // el -5 es porque no llegaba a tope
  myBundle.add(myMessage);
  myMessage.clear();
  
  myMessage.setAddrPattern("/layer5/clip1/video/effect2/param2/values");
  myMessage.add(map(float(MAX_DISTANCE_ARDUINO - val1), 0.0, float(MAX_DISTANCE_ARDUINO - 5), 0.2, 1.0)); // el -5 es porque no llegaba a tope
  myBundle.add(myMessage);
  myMessage.clear();


  
  //ARDUINO 2
  myMessage.setAddrPattern("/layer6/clip1/audio/pitch/values");
  myMessage.add(map(float(val2), 0.0 + 5.0, float(MAX_DISTANCE_ARDUINO), 0.1, 1.0));
  myBundle.add(myMessage);
  myMessage.clear();

  myMessage.setAddrPattern("/layer5/clip1/video/effect1/param1/values");
  myMessage.add(map(float(val2), 0.0 + 5.0, float(MAX_DISTANCE_ARDUINO), 0.0, 1.0));
  myBundle.add(myMessage);
  myMessage.clear();
  
  myMessage.setAddrPattern("/layer3/clip1/video/effect2/param1/values");
  myMessage.add(map(float(val2), 0.0 + 5.0, float(MAX_DISTANCE_ARDUINO), 0.3, 0.5));
  myBundle.add(myMessage);
  myMessage.clear();
  
  myMessage.setAddrPattern("/layer8/clip1/audio/volume/values");
  myMessage.add(map(float(val2), 0.0 + 5.0, float(MAX_DISTANCE_ARDUINO), 0.67, 0.85)); //Sonido logaritmico
  myBundle.add(myMessage);
  myMessage.clear();
  
  //Se va sonido central
   if (val2 < 20 && val1 < 20){
    if (sonidoCentral != 1){
      sonidoCentral = 1;
      myMessage.setAddrPattern("/layer1/clip2/connect");
      myMessage.add(1);
      myBundle.add(myMessage);
      myMessage.clear();
     } 
     }else if (sonidoCentral != 0) {
       
       sonidoCentral = 0;
        
        myMessage.setAddrPattern("/layer1/clip1/connect");
        myMessage.add(1);
        myBundle.add(myMessage);
        myMessage.clear();

      }

  
  /*
 //La Y de Leap Motion va al reves, por eso hago max distance - val4
  myMessage.setAddrPattern("/layer2/clip1/video/effect2/param1/values");
  myMessage.add(map(float(MAX_DISTANCE_LEAPY - val4Mod), 0.0, float(MAX_DISTANCE_LEAPY), 0.2, 0.8));
  myBundle.add(myMessage);
  myMessage.clear();*/
  
   //println(val6);
  
  if (val6 == 0){
    if (sonidoLeap != 1){
      sonidoLeap = 1;
      myMessage.setAddrPattern("/layer7/clip1/connect");
      myMessage.add(1);
      myBundle.add(myMessage);
      myMessage.clear();
     } 
     }else if (sonidoLeap != 0) {
       
       sonidoLeap = 0;
        
        myMessage.setAddrPattern("/layer7/clip2/connect");
        myMessage.add(1);
        myBundle.add(myMessage);
        myMessage.clear();

      }
  

  /*myMessage.setAddrPattern("/layer7/clip1/audio/volume/values");
  myMessage.add(map(float(val3Mod), 0.0 + 5.0, float(MAX_DISTANCE_LEAPX), 0.72, 1.0));
  myBundle.add(myMessage);
  myMessage.clear();*/
  
  
  
  /*if (val8 == 1){
      myMessage.setAddrPattern("/layer5/clip1/connect");
      myMessage.add(1);
      myBundle.add(myMessage);
      myMessage.clear();         
      val8 = 0;
  }
  if (val8 == 2){
    myMessage.setAddrPattern("/layer5/clip2/connect");
      myMessage.add(1);
      myBundle.add(myMessage);
      myMessage.clear();
      val8 = 0;
  }
  if (val7 != 0){
    if (val7 == 1){
      myMessage.setAddrPattern("/layer4/clip1/connect");
      myMessage.add(1);
      myBundle.add(myMessage);
      myMessage.clear();
      //println("HAS ENTRAT AL VAL == 1");
      val7 = 0;
    }else{
        if (val7 == 2){
          //println("HAS ENTRAT AL VAL == 2");
          myMessage.setAddrPattern("/layer4/clip2/connect");
          //myMessage.add(map(float(val2), 0.0, float(MAX_DISTANCE_ARDUINO), 0.0, 1.0));
          myMessage.add(1);
          myBundle.add(myMessage);
          myMessage.clear();
          val7 = 0;
        }
    }
  }*/
  
  
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

class Textura {
  float z = random(-100, 100);
  float phi = random(TWO_PI);
  float theta = asin(z/100);
  float largo = random(0.5, 1.6);

  Textura() {
    //contorno esfera
    z = random(-100, 100);
    phi = random (TWO_PI);
    theta = asin(z/100);
    //largo textura
    largo = random (0.5, 1.6);  
      if (nota == 1){
         largo = random (0.5, 1.6);
         theta = asin(z/100);
      }
      if (nota == 2){
        largo = random (0.5, 1.5);
        theta = asin(z/200);
      }
      if (nota == 3){
         largo = random (0.5, 1.4);
         theta = asin(z/300);
      }
      if (nota == 4){
        largo = random (0.5, 1.3); 
        theta = asin(z/400);
      }
      if (nota == 5){
         largo = random (0.5, 1.2);
         theta = asin(z/500);
      }
      if (nota == 6){
        largo = random (0.5, 1.1);
        theta = asin(z/700);
      }
      if (nota == 7){
         largo = random (0.5, 1);
         theta = asin(z/1000);
      }
      if (nota == 8){
        largo = random (0.5, 0.8);
        theta = asin(z/700);
      }
      if (nota == 9){
        largo = random (0.5, 0.6);
        theta = asin(z/700);
      }
      if (nota == 10){
        largo = random (0.5, 0.5);
        theta = asin(z/700);
      }
 
  }

  void dibujar() {
    //ruido esfera
    
    float off = (noise(millis() * 0.0005, sin(phi))-0.5) * 0.3;
    float offb = (noise(millis() * 0.0007, sin(z) * 0.01)-0.5) * 0.3;

    float thetaff = theta+off;
    float phff = phi+offb;
    float x = 100 * cos(theta) * cos(phi);
    float y = 100 * cos(theta) * sin(phi);
    float z = 100 * sin(theta);

//inicio de puntos de la esfera
    float xo = 100 * cos(thetaff) * cos(phff);
    float yo = 100 * cos(thetaff) * sin(phff);
    float zo = 100 * sin(thetaff);
    
//alcance de puntos de la esfera
    float xb = xo * largo;
    float yb = yo * largo;
    float zb = zo * largo;

//CUANDO NO HAY MANO LOS PUNTOS VAN A 0

if (val6 == 0) {
    strokeWeight(1);
    beginShape(POINTS);
    sphereDetail(1);
    stroke(53);
    vertex(x, y, z);
    stroke(200);
    vertex(xb, yb, zb);
    endShape();
} else {
      /*int strokeP = nota * 10;
      float strokePm = map(strokeP, 0, 1000, 0, 255);
      int strokeE = -nota * 10;
      float strokeEm = map(strokeE, 0, 1000, 0, 255);*/
      
      strokeWeight(1);
      beginShape(POINTS);
      stroke(53);
      vertex(x, y, z);
      stroke(200);
      vertex(xb, yb, zb);
      endShape();
    
}
  }
}