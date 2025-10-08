
//watering plants
void setup() {
  
  // initialize serial communication at 9600 bits per second:
    
  // Print a message to the LCD.
 
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
