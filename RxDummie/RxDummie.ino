
String resultado="";
int val;
boolean parar = false;
void setup() 
{

  Serial.begin(9600);                    // Start serial communication at 9600 bps
  Serial1.begin(9600);
}

void loop() 
{
  if(parar == false)
  {
    //Read from Tx
    val = Serial1.read();
    if(val!=-1)
    {
      if(val!= 120)
      {
          resultado+=(char)val;
      }else
      {
        //Send to processing
        Serial.print(resultado);
        parar = true;
      }
    }
    delay(100);                            // Wait 100 milliseconds
  }
}
