/**
 * Envío de información de processing a processing ordenadores remotos con UDP
 */

// Se importa librería UPD
import hypermedia.net.*;

//Se define objeto UDP
UDP udp;


int puertoLocal    = 6000;    // puerto local
int puertoRemoto    = 12345;    // puerto remoto
String ip       = "172.20.10.6";  // direccion IP remota



void setup() {

  // Se crea conexion
  udp = new UDP( this, puertoLocal );
  
   //se pasa a string para enviar la data
    //int val = 2;
    String message  = "xavier";

    // envia mensaje
    
    for (int i = 0; i < 6; i++)
    {
      udp.send( message, ip, puertoRemoto );
      delay(4000);
    }
    

}




/*void draw() {
  
    //se pasa a string para enviar la data
    //int val = 2;
    String message  = "HOLAHOLA";

    // envia mensaje
    udp.send( message, ip, puertoRemoto );

}*/