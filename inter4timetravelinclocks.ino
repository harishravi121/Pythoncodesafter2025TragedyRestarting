/*
  Arduino Interrupt Counter

  This sketch demonstrates how to use an external interrupt to increment a number.
  It's useful for tasks like counting button presses or reading signals from sensors.

  Hardware setup:
  - Connect a momentary push button between digital pin 2 and ground.
  - The internal pull-up resistor will be enabled to hold the pin HIGH.
  - Pressing the button will change the state to LOW, triggering the interrupt.
*/

// Use the 'volatile' keyword for any variable that can be changed by an interrupt.
// This tells the compiler that the variable's value can change at any time,
// preventing optimization issues.
volatile int numberToIncrement = 0;

// The pin connected to the interrupt-triggering button.
// Pin 2 is one of the external interrupt pins on the Arduino Uno.
const int interruptPin = 2;

// A variable to store the last printed value, to only print when a change occurs.
int lastPrintedValue = 0;

// The Interrupt Service Routine (ISR).
// This function is called automatically by the microcontroller when the interrupt is triggered.
// It should be as fast and simple as possible.
void incrementISR() {
  numberToIncrement += 10;
}

void setup() {
  // Start serial communication at 9600 baud.
  Serial.begin(9600);

  // Set the interrupt pin as an input.
  pinMode(interruptPin, INPUT_PULLUP);

  // Attach the interrupt to the pin.
  // The first argument is the pin number (which can be mapped to a specific interrupt number).
  // The second is the name of the function to call (the ISR).
  // The third is the mode:
  // - LOW: Triggers when the pin is LOW.
  // - HIGH: Triggers when the pin is HIGH.
  // - CHANGE: Triggers whenever the pin changes value (LOW to HIGH or HIGH to LOW).
  // - RISING: Triggers when the pin goes from LOW to HIGH.
  // - FALLING: Triggers when the pin goes from HIGH to LOW.
  // We use FALLING because the button connects the pin to ground.
  attachInterrupt(digitalPinToInterrupt(interruptPin), incrementISR, FALLING);

  Serial.println("Interrupt counter started. Press the button!");
}

void loop() {
  // Check if the value has changed since the last time it was printed.
  // This prevents the Serial Monitor from being spammed with the same value.
  if (numberToIncrement != lastPrintedValue) {
    Serial.print("Current number: ");
    Serial.println(numberToIncrement);
    lastPrintedValue = numberToIncrement;
  }
}
