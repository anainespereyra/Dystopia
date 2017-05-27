import com.neurogami.leaphacking.*;

import oscP5.*;
import netP5.*;

OscP5 clientOscP5;

NetAddress oscServerAddress;
NetAddress oscClientAddress;



NgListener listener = new NgListener();
Controller controller;

void setup(){
  controller = new Controller(listener);
  size(640, 480);

  float m = map( -123, -500, 500, 0, width);
println("-123 has been mapped to " + m );
// -123 has been mapped to 241.28
}

void draw(){

}

