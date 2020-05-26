const byte vsyncPin1 = 2;
const byte vsyncPin2 = 3;
const byte tokenPin = 4;
const int  analogIn = A0;
bool status = 0;

int potentiometer = 0;
unsigned int waitTime = 0; //constant delay time in microseconds
// !!! accurate between 3 and 16383 microseconds

//declare functions
void setLeftFlag();
void setRightFlag();
void sendLeftToken();
void sendRightToken();

void setup() {
  // setup digital output for sending token
  pinMode(tokenPin, OUTPUT);
  digitalWrite(tokenPin, LOW);
  // setup rising edge interrupt to trigger left token
  pinMode(vsyncPin1, INPUT);
  attachInterrupt(digitalPinToInterrupt(vsyncPin1), go, RISING);
  // setup falling edge interrupt to trigger right token
  //pinMode(vsyncPin2, INPUT);
  //attachInterrupt(digitalPinToInterrupt(vsyncPin2), sendRightToken, FALLING);
}

void loop() {
    //do something
    //status = !status;
  }

void go(){
  if (status){
    sendLeftToken();
    }else{
      sendRightToken();
      }
  status = !status;
  }

//Open left eye, close right eye
void sendLeftToken(){
  potentiometer = analogRead(analogIn);
  waitTime = int(potentiometer * 8);
  if (waitTime>0){delayMicroseconds(waitTime);}
  digitalWrite(tokenPin, HIGH);
  delayMicroseconds(18);
  digitalWrite(tokenPin, LOW);
  delayMicroseconds(60);
  digitalWrite(tokenPin, HIGH);
  delayMicroseconds(18);
  digitalWrite(tokenPin, LOW);
  }

//Open right eye, close left eye
void sendRightToken(){
  potentiometer = analogRead(analogIn);
  waitTime = int(potentiometer * 8);
  if (waitTime>0){delayMicroseconds(waitTime);}
  digitalWrite(tokenPin, HIGH);
  delayMicroseconds(18);
  digitalWrite(tokenPin, LOW);
  delayMicroseconds(20);
  digitalWrite(tokenPin, HIGH);
  delayMicroseconds(18);
  digitalWrite(tokenPin, LOW);
  delayMicroseconds(20);
  digitalWrite(tokenPin, HIGH);
  delayMicroseconds(18);
  digitalWrite(tokenPin, LOW);
  }
