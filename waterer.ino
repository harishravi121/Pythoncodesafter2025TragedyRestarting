
//watering plants
void setup() {
  
  //LED should be connected to transistor and relay and a for loop for 1000 should be written around delay as its in milliseconds
  pinMode(LED_BUILTIN, OUTPUT);
}

// the loop routine runs over and over again forever:
void loop() {
  long delayoff=3*60*3600;
  long delayon=20;

  delay(delayoff);
  digitalWrite(LED_BUILTIN, HIGH);
  delay(delayon);
  digitalWrite(LED_BUILTIN, LOW);
  }

