#include <Adafruit_BLE.h>
#include <Adafruit_BluefruitLE_SPI.h>
#include <Adafruit_BluefruitLE_UART.h>
#include <math.h> 

#define BLE_REQ   8
#define BLE_RDY   7
#define BLE_RST   -1

#define dirPinMotor1 5
#define stepPinMotor1 6

#define dirPinMotor2 13
#define stepPinMotor2 12                                                                                                                                                                                                                     


int switchDirection = LOW;
int tempSteps, tempDirection;
String inputString = "";
int inputAngle = 90;
int inputSpeed = 0;
int presInputAngle = 90;
const unsigned int input_MAX = 7; //change for large input string
#define angleToSteps(x)  round(9.444*(x-90))

Adafruit_BluefruitLE_SPI ble(BLE_REQ, BLE_RDY, BLE_RST);

class stepMotor{
  private:
  unsigned long delayTime;
  unsigned long currentTime;
  unsigned long presTime;
  unsigned long pulseCount = 0;
  unsigned long stepCount = 0;
  int stepPin;
  int dirPin;
  bool direct = HIGH;
  bool beginMotor = false;
  int togglePulse;

  public:
  void init(int _stepPin, int _dirPin){
    stepPin = _stepPin;
    dirPin = _dirPin;
    togglePulse   = LOW;
    pinMode(stepPin, OUTPUT);
    pinMode(dirPin, OUTPUT);
  }

  void stopMotor(){
    beginMotor = false;
  }

  void startMotor(){
    beginMotor = true;
  }

  void motorDirection(bool _direct){
    direct = _direct;
  }
  void resetSteps(){
    stepCount = 0;
  }
  void motorSpeed(unsigned long _speed){
    delayTime = _speed; 
  }

   unsigned long steps(void){
    return stepCount;
  }

  void rotate(){
    currentTime = micros(); 
    digitalWrite(dirPin, direct);
    if(beginMotor){
       if( (currentTime - presTime) > delayTime ){
        pulseCount++;
        if(pulseCount % 2 == 0){ //completed a step
          stepCount++;
        }
        togglePulse = togglePulse == LOW ? HIGH : LOW;
        digitalWrite(stepPin, togglePulse);
        presTime = currentTime;
      }
    }
    
  }
};

  


stepMotor stepMotor1, stepMotor2;

void setup() {
  delay(500);
  
  //For bluetooth input
  Serial.begin(115200);
  ble.verbose(false);
  if(ble.begin()){
    
  }
  ble.sendCommandCheckOK(F("AT+GAPDEVNAME=MyFeather"));
  ble.sendCommandCheckOK(F("AT+BLEUARTTX"));
  ble.setMode(BLUEFRUIT_MODE_DATA);
  
  // For user input
  Serial.begin(9600);
//  while(!Serial);
//  Serial.println("Type 'stop' 'reset' '(speed)|(angle)'");


  stepMotor1.init(stepPinMotor1,dirPinMotor1);
  stepMotor2.init(stepPinMotor2,dirPinMotor2);
  stepMotor2.startMotor();
}

void loop() {
  stepperMotorOne();
  stepperMotorTwo();
//Bluetooth communication 
  while ( ble.available() )
    {
      inputProcess((char) ble.read());
    }

//Monitor communication 

//if( Serial.available() > 0){
//  inputProcess (Serial.read());
//}

}



void stepperMotorOne(){
  if (inputSpeed > 0){
    stepMotor1.startMotor();
  } else {
    stepMotor1.stopMotor();
  }

  stepMotor1.motorSpeed(8000/inputSpeed);
if(stepMotor1.steps() >= 1700){
    if(inputString != "reset"){
    stepMotor1.motorDirection(switchDirection);
    switchDirection = switchDirection == LOW ? HIGH : LOW;
    stepMotor1.resetSteps();
    } else {
      inputSpeed = 0;
    }
  }
  stepMotor1.rotate();
}

void stepperMotorTwo(){
  if (inputAngle != presInputAngle){
  tempSteps = angleToSteps(inputAngle) - angleToSteps(presInputAngle);
  stepMotor2.resetSteps();
  tempDirection = tempSteps < 0 ? HIGH : LOW;
  presInputAngle = inputAngle;
}
  if(stepMotor2.steps() < abs(tempSteps)){
    stepMotor2.motorDirection(tempDirection);
    stepMotor2.motorSpeed(3500);
    stepMotor2.rotate();
  }
}

void inputProcess(const byte byteRecived){ //cycle through the read bytes

  static char input[input_MAX];
  static int inputPos = 0;

  if (byteRecived == '\n'){
    input[inputPos] = 0;
    inputPos = 0;
    processData(input);
  } else {
    if (inputPos < (input_MAX - 1)){
       input [inputPos++] = byteRecived;
    }
  }
}

void processData(const char * inputData){
//  Serial.print("[Recived]: ");
//  Serial.println(inputData);
  String tempIntString = "";

  if(isdigit(inputData[0])){
    for(int i = 0; i < strlen(inputData); i++){
      if(!isdigit(inputData[i])){
        inputSpeed = tempIntString.toInt();
        tempIntString = "";
        continue;
      }
      tempIntString = tempIntString + inputData[i];
    }
    inputString = "";
     inputAngle = tempIntString.toInt();
    } else {
      inputString = "reset";
      inputAngle = 90;
    }
}
  
