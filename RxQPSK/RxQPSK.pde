import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val = "";      // Data received from the serial port

//Variables
String cadenaRecibida;
boolean parar=false;
String decodificacionLineaNRZM;
String decodificacionCanal;
String mensajeOriginal;
int offsetCadena;


void setup() 
{
  size(200, 200);
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
}

void draw()
{
 
  if ( myPort.available() > 0) 
  {
    if(parar==false){
    val = myPort.readString(); 
    println(val);
    String particion [] = val.split("-");

    offsetCadena = Integer.parseInt(particion[1]);
    cadenaRecibida = particion[0];
    println(particion[0]+" "+particion[1]+"particiones"); 
    decodificacionLineaNRZM=bloqueDecodificacionLineaNRZM(cadenaRecibida);
    decodificacionCanal=bloqueDecodificacionCanal(invertirCadena(decodificacionLineaNRZM),offsetCadena);
    mensajeOriginal=bloqueFormateoInverso(decodificacionCanal);
    println("Mensaje Recibido:"+" "+cadenaRecibida);
    println("Dec. Linea: "+decodificacionLineaNRZM);
   println("Dec. Canal: "+decodificacionCanal);
   println("Mensaje Original: "+mensajeOriginal);
    boolean parar=true;
    }
  }
}

//Decode Line Code (NRZ-M)
String bloqueDecodificacionLineaNRZM(String bits)
{
char ultimoValor;
StringBuilder sb = new StringBuilder();
sb.append(bits.charAt(0));
ultimoValor = bits.charAt(0);

for(int i = 1; i < bits.length(); i++)
{
 char c = bits.charAt(i);
 
 if(ultimoValor == c)
 {
    sb.append('0'); 
 }
 else
 {
    sb.append('1'); 
 }
 
 ultimoValor = c;

}

return sb.toString();
}


//Channel decoder (Hamming algorithm)
String bloqueDecodificacionCanal(String bits, int parity_count)
  {
    // This is the receiver code. It receives a Hamming code in array 'a'.
    // We also require the number of parity bits added to the original data.
    // Now it must detect the error and correct it, if any.
    
    int [] a = new int[bits.length()];
    
    for(int i = 0; i < bits.length(); i ++)
    {
      char c = bits.charAt(i);
      a[i] = Integer.parseInt(String.valueOf(c));
    }

    int power;
    // We shall use the value stored in 'power' to find the correct bits to
    // check for parity.

    int parity[] = new int[parity_count];
    // 'parity' array will store the values of the parity checks.

    String syndrome = new String();
    // 'syndrome' string will be used to store the integer value of error
    // location.

    for (power = 0; power < parity_count; power++)
    {
      // We need to check the parities, the same number of times as the
      // number of parity bits added.

      for (int i = 0; i < a.length; i++)
      {
        // Extracting the bit from 2^(power):

        int k = i + 1;
        String s = Integer.toBinaryString(k);
        int bit = ((Integer.parseInt(s)) / ((int) Math.pow(10, power))) % 10;
        if (bit == 1)
        {
          if (a[i] == 1)
          {
            parity[power] = (parity[power] + 1) % 2;
          }
        }
      }
      syndrome = parity[power] + syndrome;
    }
    // This gives us the parity check equation values.
    // Using these values, we will now check if there is a single bit error
    // and then correct it.

    int error_location = Integer.parseInt(syndrome, 2);
    if (error_location != 0)
    {
      a[error_location - 1] = (a[error_location - 1] + 1) % 2;
    } 

    // Finally, we shall extract the original data from the received (and
    // corrected) code:
    StringBuilder sb = new StringBuilder();
    power = parity_count - 1;
    for (int i = a.length; i > 0; i--)
    {
      if (Math.pow(2, power) != i)
      {
        sb.append(a[i - 1]);
      } else
      {
        power--;
      }
    }
    
    return sb.toString();

  }



//Format block decoder (Bits to ASCII)
 String bloqueFormateoInverso(String bits)
  {
    StringBuilder sb = new StringBuilder();
    int nextChar;
    for (int i = 0; i <= bits.length() - 8; i += 8) 
    {
      nextChar = Integer.parseInt(bits.substring(i, i + 8), 2);
      String str = new Character((char)nextChar).toString();
      sb.append(str);
    }
    
    return sb.toString();

  }
  
//Invert string
String invertirCadena(String mensaje)
  {
    String retorno = "";
    for (int i = mensaje.length(); i > 0; i--)
    {
      retorno += mensaje.substring(i - 1, i);
    }
    return retorno;
  }



