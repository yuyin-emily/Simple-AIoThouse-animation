import processing.serial.*;
import cc.arduino.*;
Serial serial; 
Arduino arduino;

JSONObject houseState;
PImage house_dark,house_light,fan_on,fan_off,sun,shake,people,door,doorframe;
boolean lightSwitch,fanSwitch,highTemperatureSwitch,moveSwitch,peopleCome,openDoor,signal;
float translateAngle,doorAngle;
int temperature,humidity;
String readSentence;
int readWord;

void setup()
{
  print("run!\n");
  
  size(800,800,P3D);
  
  houseState = new JSONObject();
  houseState.setInt("temperature",5);
  print(houseState.getInt("temperature"),"\n");
  
  loadHouseImage();
  setSwitch();
  setNumber();
  

}

void draw()
{
  background(#CFECF7);
  
  drawButton();
  writeText();
  drawImage();
  
  if (openDoor)
  {
    doorRotate();
  }
  
  if (signal)
  {
    if (serial.available() > 0) 
    {
      print("available!\n");
      readWord = serial.read();
      if(char(readWord) == 'S')
      {
        getread();
      }
    }
  }
  else
  {
    try
    {
      serial = new Serial(this, Arduino.list()[4], 115200);
      serial.write(6);
      signal = true;
    }
    catch(Exception e)
    {
      
    }
  }
}

void setNumber()
{
  houseState.setInt("temperature",0);
  houseState.setInt("humidity",0);
  translateAngle=0.01;
  doorAngle=0;
  print("setNumber!\n");
}

void setSwitch()
{
  lightSwitch=false;
  fanSwitch=false;
  highTemperatureSwitch=false;
  moveSwitch=false;
  peopleCome=false;
  openDoor=false;
  signal=false;
  print("setSwitch!\n");
}

void loadHouseImage()
{
  house_dark = loadImage("house_dark.png");
  house_light = loadImage("house_light.png");
  fan_on = loadImage("fan_on.png");
  fan_off = loadImage("fan_off.png");
  sun = loadImage("sun.png");
  shake = loadImage("shake.png");
  people = loadImage("people.png");
  door = loadImage("door.png");
  doorframe = loadImage("doorframe.png");
  print("loadHouseImage!\n");
}

void drawButton()
{
  for(int i=0;i<3;i++)
  {
    rect(70+230*i,650,200,120,10);
  }
  fill(#0E1664);
  textSize(50);
  text("light",125,725);
  text("fan",365,730);
  text("door",580,730);
  fill(255,255,255);
  //print("drawButton!\n");
}

void drawImage()
{
  if (lightSwitch)
  {
    image(house_light,150,150,500,500);
  }
  else
  {
    image(house_dark,150,150,500,500);
  }
  
  if (fanSwitch)
  {
    image(fan_on,270,430,150,150);
  }
  else
  {
    image(fan_off,270,430,150,150);
  }
  
  if(highTemperatureSwitch)
  {
    image(sun,600,50,150,150);
  }
  
  if(moveSwitch)
  {
    image(shake,565,445,100,100);
    image(shake,130,445,100,100);
  }
  
  if(peopleCome)
  {
    image(people,630,400,150,200);
  }
  //print("drawImage!\n");
}

void writeText()
{
  textSize(30);
  fill(#0E1664);
  text("temperature : " + houseState.getInt("temperature") + "\nhumidity : " + houseState.getInt("humidity"),30,50);
  fill(255,255,255);
  //print("writeText!\n");
}

void mouseClicked() {
  if (mouseX>70 && mouseX<270 && mouseY>650 && mouseY<770)
  {
    lightSwitch = !lightSwitch;
  }
  else if (mouseX>300 && mouseX<500 && mouseY>650 && mouseY<770)
  {
    fanSwitch = !fanSwitch;
  }
  else if (mouseX>530 && mouseX<730 && mouseY>650 && mouseY<770)
  {
    openDoor = true;
    serial.write(5);
  }
}

void doorRotate()
{
  image(doorframe,415,419,120,170);
  translate(535,589);
  rotateY(doorAngle);
  image(door,-120,-170,120,170);
  doorAngle+=translateAngle;
  if(doorAngle>=PI/2)
  {
    translateAngle=-0.01;
  }
  else if(doorAngle<0)
  {
    translateAngle=0;
    translateAngle=0.01;
    openDoor=false;
  }
  rotateY(-doorAngle);
  translate(-535,-589);
}

void getread()
{
  readWord = serial.read();
  if(char(readWord) == 'T')
  {
    readSentence="";
    readWord = serial.read();
    while(char(readWord) != 'E')
    {
      readSentence += readWord;
      readWord = serial.read();
    }
    houseState.setInt("temperature",int(readSentence));
    print("temperature:",houseState.getInt("temperature"),"\n");
  }
  else if(char(readWord) == 'H')
  {
    readSentence="";
    readWord = serial.read();
    while(char(readWord) != 'E')
    {
      readSentence += readWord;
      readWord = serial.read();
    }
    houseState.setInt("humidity",int(readSentence));
    print("humidity:",houseState.getInt("humidity"),"\n");
  }
  else if(char(readWord) == 'L')
  {
    readWord = serial.read();
    if(readWord == 1)
    {
      lightSwitch =true;
    }
    else
    {
      lightSwitch =false;
    }
  }
  else if(char(readWord) == 'F')
  {
    readWord = serial.read();
    if(readWord == 1)
    {
      fanSwitch =true;
    }
    else
    {
      fanSwitch =false;
    }
  }
  else if(char(readWord) == 'W') //highTemperature
  {
    readWord = serial.read();
    if(readWord == 1)
    {
      highTemperatureSwitch =true;
    }
    else
    {
      highTemperatureSwitch =false;
    }
  }
  else if(char(readWord) == 'M')
  {
    moveSwitch = !moveSwitch;
    readWord = serial.read();
    if(readWord == 1)
    {
      moveSwitch =true;
    }
    else
    {
      moveSwitch =false;
    }
  }
  else if(char(readWord) == 'P')
  {
    readWord = serial.read();
    if(readWord == 1)
    {
      peopleCome =true;
    }
    else
    {
      peopleCome =false;
    }
  }
}
