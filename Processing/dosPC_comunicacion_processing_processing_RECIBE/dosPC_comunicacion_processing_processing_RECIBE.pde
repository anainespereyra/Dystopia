/**
 * Recepción información processing-processing ordenadores remotos con UDP
 */

// Se importa librería UPD
import hypermedia.net.*;

//Se define objeto UDP
UDP udp;

int puertoLocal    = 6100;    // puerto local



void setup() {

  // Se crea conexion
  udp = new UDP( this, puertoLocal );
  udp.listen( true );
}

//process events
void draw() {;}


//se recibe mensaje
void receive( byte[] data, String ip, int port ) {	// <-- extended handler
  
  int val = 0;
  String message = new String( data );
  
  val = int(message);
  
  // se imprime mensaje
  println( "receive: \""+val+"\" from "+ip+" on port "+port );
}