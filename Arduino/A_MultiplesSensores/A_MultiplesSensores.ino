// ---------------------------------------------------------------------------
// This example code was used to successfully communicate with 15 ultrasonic sensors. You can adjust
// the number of sensors in your project by changing SONAR_NUM and the number of NewPing objects in the
// "sonar" array. You also need to change the pins for each sensor for the NewPing objects. Each sensor
// is pinged at 33ms intervals. So, one cycle of all sensors takes 495ms (33 * 15 = 495ms). The results
// are sent to the "oneSensorCycle" function which currently just displays the distance data. Your project
// would normally process the sensor results in this function (for example, decide if a robot needs to
// turn and call the turn function). Keep in mind this example is event-driven. Your complete sketch needs
// to be written so there's no "delay" commands and the loop() cycles at faster than a 33ms rate. If other
// processes take longer than 33ms, you'll need to increase PING_INTERVAL so it doesn't get behind.
// ---------------------------------------------------------------------------
#include <NewPing.h>

#define SONAR_NUM     2 // Number of sensors.
#define MAX_DISTANCE 50 // Maximum distance (in cm) to ping. //CAMBIAR TAMBIEN EN CODIGO PROCESSING
#define PING_INTERVAL 10 // Milliseconds between sensor pings (29ms is about the min to avoid cross-sensor echo).

unsigned long pingTimer[SONAR_NUM]; // Holds the times when the next ping should happen for each sensor.
unsigned int cm[SONAR_NUM];         // Where the ping distances are stored.
uint8_t currentSensor = 0;          // Keeps track of which sensor is active.

NewPing sonar[SONAR_NUM] = {
  NewPing(8, 9, MAX_DISTANCE),
  NewPing(6, 7, MAX_DISTANCE)
  
};


//Array que almacena los valores pasados para hacer un promedio de lo que mide el sensor
//Se hace promedio de los valores pasados para que no haya cambios bruzcos si fallan un par de valores
//Para cambios más bruzcos, bajar el numero, para cambios más lentos, subirlo.
int cantidadValoresPasados = 10; //Si se cambia el valor, cambiarlo también en el array de abajo.
int valoresPasados[10];

void setup() {
  Serial.begin(9600); 

  //Se inicializa con valores "fuera de rango"
  for (int i = 1; i < cantidadValoresPasados; i++) {// Set the starting time for each sensor.
    valoresPasados[i] = MAX_DISTANCE;
  }

  pingTimer[0] = millis() + 75;           // First ping starts at 75ms, gives time for the Arduino to chill before starting.
  for (uint8_t i = 1; i < SONAR_NUM; i++) {// Set the starting time for each sensor.
    pingTimer[i] = pingTimer[i - 1] + PING_INTERVAL;
  }

}

void loop() {
  for (uint8_t i = 0; i < SONAR_NUM; i++) { // Loop through all the sensors.
    if (millis() >= pingTimer[i]) {         // Is it this sensor's time to ping?
      pingTimer[i] += PING_INTERVAL * SONAR_NUM;  // Set next time this sensor will be pinged.
      if (i == 0 && currentSensor == SONAR_NUM - 1) oneSensorCycle(); // Sensor ping cycle complete, do something with the results.
      sonar[currentSensor].timer_stop();          // Make sure previous timer is canceled before starting a new ping (insurance).
      currentSensor = i;                          // Sensor being accessed.
      cm[currentSensor] = MAX_DISTANCE;           // Make distance zero in case there's no ping echo for this sensor.
      sonar[currentSensor].ping_timer(echoCheck); // Do the ping (processing continues, interrupt will call echoCheck to look for echo).
    }
  }
  // Other code that *DOESN'T* analyze ping results can go here.
}

void echoCheck() { // If ping received, set the sensor distance to array.
  if (sonar[currentSensor].check_timer())
    cm[currentSensor] = sonar[currentSensor].ping_result / US_ROUNDTRIP_CM;
}

void oneSensorCycle() { // Sensor ping cycle complete, do something with the results.

  //Para eliminar errores, descartamos los sensores que dan valor fuera de rango.
  //Se selecciona el valor más pequeño de todas las mediciones de los sensores.
  //(en vez de promediar, por si se está detectando un cuerpo y una mano, por ejemplo)
  int minimo = MAX_DISTANCE;
  for (uint8_t i = 0; i < SONAR_NUM; i++) {
    minimo = min(minimo, cm[i]);
  }

  //se guarda valor en array de valores pasados
  for (int i = 0; i < cantidadValoresPasados; i++) {
    if (i == cantidadValoresPasados - 1)
      valoresPasados[i] = minimo;
    else
      valoresPasados[i] = valoresPasados[i + 1];
  }
  

  //Se hace promedio de los valores pasados para que no haya cambios bruzcos si fallan un par de valores
  int promedio = 0;

  for (int i = 0; i < cantidadValoresPasados; i++) {
    promedio += valoresPasados[i];
  }

  promedio = promedio / cantidadValoresPasados;

  //Envío a processing
  Serial.write(promedio);
  
  //DEBUG
  //Serial.println(promedio);

}











