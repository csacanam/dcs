import processing.serial.*;

String mensaje;
String mensajeFormateado;
String cadenaCodificada;
String cadenaCodigoLinea;

//Serial port
Serial myPort; 


void setup()
{
  size(1200, 800);
  String portName = Serial.list()[2];
  myPort = new Serial(this, portName, 9600);
  println(portName);

  //Message------
  mensaje= "aaaaaa"; 
  
  //Format Block ----
  mensajeFormateado = bloqueFormateo(mensaje);
  println("TRANSMISOR");
  print("Formateado: ");
  for(int i = 0; i < mensajeFormateado.length();i++)
  {
   print(mensajeFormateado.charAt(i)); 
  }
  
  println();
  
  //Channel Encoder Block -----
  cadenaCodificada = bloqueCodificacionCanal(mensajeFormateado);
    
  print("Cod. Canal: ");
  for (int i = 0; i < cadenaCodificada.length(); i++)
  {
    print(cadenaCodificada.charAt(cadenaCodificada.length() - i - 1));
  }
  
  println();
  
  //Line Code Block
  cadenaCodigoLinea = bloqueCodificacionLineaNRZM(invertirCadena(cadenaCodificada));
  
  print("Cod. Linea: ");
  for (int i = 0; i < cadenaCodigoLinea.length(); i++)
  {
    print(cadenaCodigoLinea.charAt(i));
  }
  
  //Send bits
  for(int i=0; i < cadenaCodigoLinea.length();i++)
  {
    myPort.write(cadenaCodigoLinea.charAt(i));
    myPort.clear();
  }
  
  //Add offset and end character('x')
  int offsetCadena = cadenaCodificada.length()-mensajeFormateado.length();
  String offsetCadenaString = String.valueOf(offsetCadena);
  myPort.write("-"+offsetCadenaString+"x");

  

}

void draw()
{
  pintarCadenaBits(cadenaCodigoLinea);
}

//Paint bits string
void pintarCadenaBits(String bits)
{
  background(0, 0, 255);
  noFill();
  stroke(255, 255, 255);
  beginShape();

  for (int i = 0; i < bits.length(); i ++)
  {
    char c = bits.charAt(i);

    if (c == '0')
    {
      vertex(i*10, 500 );
      vertex(i*10 + 10, 500 );
    }
    else
    {
      vertex(i*10, 400 );
      vertex(i*10 + 10, 400 );
    }
  }
  vertex(width, 500 );
  endShape();
}


//Format Block
String bloqueFormateo(String mensaje)
{
  StringBuilder strb = new StringBuilder();

  for (int i = 0; i < mensaje.length(); i ++) 
  {
    int x=mensaje.charAt(i);
    strb.append(binary(x, 8));
  }

  return strb.toString();
}


//Channel Encoder Block (Hamming algorithm)
String bloqueCodificacionCanal(String cadenaFormateada)
  {
    int n = cadenaFormateada.length();
    int a[] = new int[n];
    
    for (int i = 0; i < n; i++)
    {
      char c = cadenaFormateada.charAt(i);
      int num = Integer.parseInt(String.valueOf(c));
      a[n - i - 1] = num;
    }

    int b[];

    // We find the number of parity bits required:
    int i = 0, parity_count = 0, j = 0, k = 0;
    while (i < a.length)
    {
      // 2^(parity bits) must equal the current position
      // Current position is (number of bits traversed + number of parity
      // bits + 1).
      // +1 is needed since array indices start from 0 whereas we need to
      // start from 1.

      if (Math.pow(2, parity_count) == i + parity_count + 1)
      {
        parity_count++;
      } else
      {
        i++;
      }
    }

    // Length of 'b' is length of original data (a) + number of parity bits.
    b = new int[a.length + parity_count];

    // Initialize this array with '2' to indicate an 'unset' value in parity
    // bit locations:

    for (i = 1; i <= b.length; i++)
    {
      if (Math.pow(2, j) == i)
      {
        // Found a parity bit location.
        // Adjusting with (-1) to account for array indices starting
        // from 0 instead of 1.

        b[i - 1] = 2;
        j++;
      } else
      {
        b[k + j] = a[k++];
      }
    }
    for (i = 0; i < parity_count; i++)
    {
      // Setting even parity bits at parity bit locations:

      b[((int) Math.pow(2, i)) - 1] = getParity(b, i);
    }
    
    //Convert to String
    StringBuilder sb = new StringBuilder();
    for( int g = 0; g < b.length; g++)
    {
      sb.append(String.valueOf(b[g]));
    }
    return sb.toString();
  }

//Line Code Block (NRZ-M)
public String bloqueCodificacionLineaNRZM(String bits)
{
  
  //Sentido del 1: True - arriba, False abajo
  boolean sentido = false;
 
  StringBuilder strb = new StringBuilder();

  for(int i = 0; i < bits.length(); i++)
 {
    char bit = bits.charAt(i);
    
    if(bit == '1')
    {
       sentido = !sentido;
       
       if(sentido)
       {
          strb.append('1'); 
       }
       else
       {
         strb.append('0');
       }
    }
    else
    {
      if(sentido)
      {
       strb.append('1'); 
      }
      else
      {
        strb.append('0');
      }
    }
    
    
 } 
 return strb.toString();
 
}

  
//Get parity of a bits string
int getParity(int b[], int power)
  {
    int parity = 0;
    for (int i = 0; i < b.length; i++)
    {
      if (b[i] != 2)
      {
        // If 'i' doesn't contain an unset value,
        // We will save that index value in k, increase it by 1,
        // Then we convert it into binary:

        int k = i + 1;
        String s = Integer.toBinaryString(k);

        // Now if the bit at the 2^(power) location of the binary value
        // of index is 1,
        // Then we need to check the value stored at that location.
        // Checking if that value is 1 or 0, we will calculate the
        // parity value.

        int x = ((Integer.parseInt(s)) / ((int) Math.pow(10, power))) % 10;
        if (x == 1)
        {
          if (b[i] == 1)
          {
            parity = (parity + 1) % 2;
          }
        }
      }
    }
    return parity;
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
  
  

