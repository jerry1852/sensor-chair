// This coding is based on the opening source project: RTC library in arduino library to get the real time.

// this clock is about 1 or 3s later than exact time, try to find the reason, maybe due to the speed of INTERNET or the connection of chips.
#include "RTClib.h"
#include <SPI.h>
#include <SD.h>
#include <DFRobot_MLX90614.h>
#include "DFRobot_BloodOxygen_S.h"
#include <LedFlasher.h>

#include "max30102.h"


RTC_DS3231 rtc;
String nowtime;
//  DFRobot_MLX90614_I2C sensor;
// #define I2C_COMMUNICATION  //use I2C for communication, but use the serial port for communication if the line of codes were masked
// #define I2C_ADDRESS 0x57
// DFRobot_BloodOxygen_S_I2C MAX30102(&Wire, I2C_ADDRESS);

const int bufferSize = 10;
String buffer[bufferSize];
int bufferIndex = 0;

File sensorsfile;

//forced sensor
// we do not need pressure sensor 1 and 3, but I don;t want to decline them.
const int sensorPin1 = A0;
int value1;

const int sensorPin2 = A2;
int value2;

const int sensorPin3 = A4;
int value3;

const int sensorPin4 = A6;
int value4;



// GSR
const int GSR = A8;
const int GSR2 = A12;

int sensorValue = 0;
int gsr_average = 0;
int gsr_average2 = 0;

// heart rate
const int heartPin = A1;

//sd card
const int chipSelect = 4;

// microphone, we also don;t need it
const int micropin = A10;

// led setting
int LED=9;
int LED2=6;


// switch
const int switchPin = 2; 
int switchState = 0;     



// Constants and Variables(oximeter)
const int BUFFER_SIZE = 1; // Adjust this as per your requirement
const byte oxiInt = 10; // Pin connected to MAX30102 INT
uint32_t aun_ir_buffer[BUFFER_SIZE]; // Infrared LED sensor data
uint32_t aun_red_buffer[BUFFER_SIZE]; // Red LED sensor data


// test button, we do not need it
int testswitch = 5;

// synchronized signl
 const int Syn=A14;
 int synstate;

void setup() {
  Serial.begin(500000);
  //rtc.adjust(DateTime(2024, 5, 23, 17, 30, 55));
  // time clock
  if (!rtc.begin()) {
    Serial.println("Couldn't find RTC");
    Serial.flush();
  }

  if (rtc.lostPower()) {
    Serial.println("RTC lost power, let's set the time!");
    // When time needs to be set on a new device, or after a power loss, the
    // following line sets the RTC to the date & time this sketch was compiled
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
    // This line sets the RTC with an explicit date & time, for example to set
    // January 21, 2014 at 3am you would call:
    // rtc.adjust(DateTime(2014, 1, 21, 3, 0, 0));
  }

  //initial sd card, nessecary!!!!!!!
  if (!SD.begin(chipSelect)) {
    Serial.println("Initialization failed!");
    return;
  }

  // open file once and keep it open for the duration of the program
  sensorsfile = SD.open("2t1017.csv", FILE_WRITE);
  if (!sensorsfile) {
    Serial.println("Couldn't open sensors file");
    while (1); // halt if file can't be opened
  }


  //initial temperature
  // while (NO_ERR != sensor.begin()) {
  //   Serial.println("Communication with device failed, please check connection");
  //   delay(1000);
  // }
  // sensor.enterSleepMode(false);
  // delay(200);

  //initial oximeter sensor
  // while (false == MAX30102.begin()) {
  //   Serial.println("init fail!");
  //   delay(1000);
  // }
  Serial.println("init success!");
  Serial.println("start measuring...");
  //MAX30102.sensorStartCollect();
  
  


  Serial.println("Initialization done.");

  pinMode(switchPin, INPUT_PULLUP);


  pinMode(oxiInt, INPUT); // Pin D10 connects to the interrupt output pin of the MAX30102

  maxim_max30102_init(); // Initialize the MAX30102

  pinMode(testswitch, INPUT_PULLUP);


  pinMode(LED, OUTPUT);

}

void loop() {
   
  switchState = digitalRead(switchPin);

  int testswitchState = digitalRead(testswitch);
  if (switchState == LOW) {
    // time sensors
  DateTime now = rtc.now();
  nowtime = String(now.month()) + '/' + String(now.day()) + ' ' + String(now.hour()) + ':' + String(now.minute()) + ':' + String(now.second());

  //syn
  synstate=analogRead(Syn);
  
  if (synstate>=500){
    digitalWrite(LED, HIGH);
    digitalWrite(LED2, HIGH);
  }else{
    digitalWrite(LED, LOW);
    digitalWrite(LED2, LOW);
  }
  
  // force sensors
  value1 = analogRead(sensorPin1);
  value2 = analogRead(sensorPin2);
  value3 = analogRead(sensorPin3);
  value4 = analogRead(sensorPin4);  //Read and save analog value from potentiometer
  
  // GSR sensor1
  gsr_average = analogRead(GSR);


  // GSR sensor2
  gsr_average2 = analogRead(GSR2);

  // heart rate sensor
  //int heartValue = analogRead(heartPin);

  // microphone response
  float wavevalue = analogRead(micropin);

  // temperature
  //float objectTemp = sensor.getObjectTempCelsius();

  // //  oximeter and PPG heartrate
  // MAX30102.getHeartbeatSPO2();
  // int oximeter = MAX30102._sHeartbeatSPO2.SPO2;
  // float heartrate = MAX30102._sHeartbeatSPO2.Heartbeat;



  int state=digitalRead(LED);



  int32_t i;

  // Buffer length of BUFFER_SIZE stores ST seconds of samples running at FS sps
  // Read BUFFER_SIZE samples, and determine the signal range
  for (i = 0; i < BUFFER_SIZE; i++) {
    while (digitalRead(oxiInt) == 1); // Wait until the interrupt pin asserts
    maxim_max30102_read_fifo((aun_red_buffer + i), (aun_ir_buffer + i)); // Read from MAX30102 FIFO
 }

  // Save samples to SD card or print to Serial

    unsigned long red=aun_red_buffer[0];
    unsigned long ir=aun_ir_buffer[0];



  String data = String(nowtime) + ',' + String(value1) + ',' + String(value2) + ',' + String(value3) + ',' + String(value4) + ',' \
   + String(gsr_average) + ',' + String(gsr_average2) + ',' + String(wavevalue) + ',' + String(red) + ',' + String(ir)\
   +","+String(state)+","+String(synstate);
   //testswitchstate改为synstate



  
  

  buffer[bufferIndex] = data;
  bufferIndex++;

  // if buffer is full, write to file
  if (bufferIndex >= bufferSize) {
    for (int i = 0; i < bufferSize; i++) {
      sensorsfile.println(buffer[i]);
    }
    sensorsfile.flush(); // ensure data is written to SD card
    bufferIndex = 0;
  }

  // print data to serial
  Serial.println(data);
  delay(10);
 
  }
  
  
}
