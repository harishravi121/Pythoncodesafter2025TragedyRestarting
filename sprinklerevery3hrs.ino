loop{
  delay(3 hrs or 3*3600*1000 milli seconds)
  delay(random(0,20)*60*1000 milli seconds) # a small naturalisation randomisation time
  pin2= 1 ( switch on relay to solenoid valve for 200 re with 20 re relay and 2 re transistor)
  delay(29 mins or 20*60*1000 ms)
  pin2=0 ( switch off sprinkler)
  }

keep looping in attiny or AVR or arduino prototype
