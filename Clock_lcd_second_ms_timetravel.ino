/*
Atomic clock can be connected to this
*/// include the library code:
#include <LiquidCrystal.h>
// initialize the library by associating any needed LCD interface pin
// with the arduino pin number it is connected to
const int rs = 8, en = 9, d4 = 4, d5 = 5, d6 = 6, d7 = 7;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

const int buttonPin =A0; //pin unknown


// the setup routine runs once when you press reset:
void setup() {
  
  // initialize serial communication at 9600 bits per second:
    lcd.begin(16, 2);
  // Print a message to the LCD.
  randomSeed(analogRead(0));
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  int timemin=0;
  int timehour=0;
int timesecond=0;
int ms=0;
int buttonState = 0;
  while(1){
  // print out the value you read:
   buttonState = digitalRead(buttonPin);int z=0;
   z=10*(1-buttonState);
   lcd.setCursor(0, 0);
  lcd.print(timemin+z);
  lcd.print("  ");
  lcd.print(timesecond);

  lcd.print("  ");
  lcd.print(ms);
  lcd.setCursor(0, 1);
  lcd.print(timehour);
  delay(1); 
  ms+=1;
  if(ms>1000){
  ms=0;
  timesecond +=1;
  if(timesecond>=60){
    timemin+=1;
    timesecond=0;
    if(timemin>=60){
        timemin=0;
    timehour+=1;
    if(timehour>=24){
      timehour=0;
    }
    }
  }
  }
    }}
