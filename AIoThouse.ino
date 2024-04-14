#include <Servo.h> //Motor
#include <LiquidCrystal_I2C.h>  //screen
LiquidCrystal_I2C lcd_i2c(0x3F);   //screen
#include <Adafruit_NeoPixel.h> //light
#include <SPI.h> //RFID
#include <MFRC522.h> //RFID
#include <DHT.h> //溫溼度感測器

int P; //different
int R_D; //different
String rfid_id;  //RFID
int L; //different
int T; //different
int H; //different
int S; //different
int oldT; //different
int oldH; //different

Servo __myservo3;  //Motor 3
Adafruit_NeoPixel pixels = Adafruit_NeoPixel(12,7,NEO_GRB + NEO_KHZ800);//New

MFRC522 rfid(/*SS_PIN*/ 10, /*RST_PIN*/ UINT8_MAX); //RFID

String mfrc522_readID() //RFID
{
  String ret;
  if (rfid.PICC_IsNewCardPresent() && rfid.PICC_ReadCardSerial())
  {
    MFRC522::PICC_Type piccType = rfid.PICC_GetType(rfid.uid.sak);

    for (byte i = 0; i < rfid.uid.size; i++) {
      ret += (rfid.uid.uidByte[i] < 0x10 ? "0" : "");
      ret += String(rfid.uid.uidByte[i], HEX);
    }
  }

  // Halt PICC
  rfid.PICC_HaltA();

  // Stop encryption on PCD
  rfid.PCD_StopCrypto1();
  return ret;
}

DHT dht11_p2(2, DHT11);//New


void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);

  __myservo3.attach(3); //Motor
  pinMode(5, OUTPUT); //LED

  lcd_i2c.begin(16, 2);

  lcd_i2c.setCursor(0,0);
  lcd_i2c.print("Emily's IoTHouse");
  lcd_i2c.setCursor(0,1);
  lcd_i2c.print("Start Work.......");
  delay(3000);
  lcd_i2c.clear();
  pinMode(4, INPUT);  //紅外線感測器
  SPI.begin();
  rfid.PCD_Init();

  dht11_p2.begin();

  digitalWrite(5, LOW); //LED

  oldT = 0;
  oldH = 0;
}

void loop() {
  // put your main code here, to run repeatedly:
  P = digitalRead(4);  //紅外線感測器
  rfid_id = mfrc522_readID();
  T = dht11_p2.readTemperature();
  H = dht11_p2.readHumidity();
  L = (map(analogRead(A0),0,4095,0,100));//光感測器

  if (Serial.read()==6){
    oldT = 0;
    oldH = 0;
  } 

  if (rfid_id == "278f383a" || Serial.read()==5) {
    //Serial.print("偵測到對應的RFID:");
    //Serial.println(rfid_id);
    __myservo3.write(90); //Motor
    delay(1000);
    __myservo3.write(0); //Motor

  }
  if (P == 1) {
    digitalWrite(5, HIGH);

  } else {
    digitalWrite(5, LOW);

  }

  lcd_i2c.setCursor(0,0);
  lcd_i2c.print(String() + "TEMP:" + T + "  HUMI:" + H);
  lcd_i2c.setCursor(0,1);
  lcd_i2c.print(String() + "S:" + S + "  PIR:" + P+ "  L:" + L);
  
  if (oldT != T){
    Serial.write("S");
    Serial.write("T");
    Serial.write(T/10);
    Serial.write(T%10);
    Serial.write("E");
    oldT = T;
  }
  if (oldH != H){
    Serial.write("S");
    Serial.write("H");
    Serial.write(H/10);
    Serial.write(H%10);
    Serial.write("E");
    oldH = H;
  }
  

}
