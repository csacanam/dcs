#Digital Communication System


This is a simulation of a digital communication system (DCS). We use Processing and Arduino as platforms to program it. The blocks used in the transmitter (Tx) are: Format, Channel encoder and Line Code. The blocks used in the receiver (Rx) are: Line Code decoder, Channel decoder and Format decoder. We give a string as a parameter to the transmitter and after the processing of the DCS, the receiver will receive the string correctly.

###Configuration
- Tx: Connect the XBee module to the USB port of the computer and run TxQPSK.pde
- Rx: Connect the XBee module to the Arduino or Romeo v2.1 board and connect it to oher computer. Then you have to run RxDummie.ino and then run RxQPSK.pde

###Collaborators
* Juan Camilo Sacanamboy - Student of Telematic Engineering and Systems Engineering at Icesi University
* Gerardo Andrés Suárez - Student of Telematic Engineering and Industrial Engineering at Icesi University
* Tutor: Gonzalo Llano PhD - Professor at Icesi University - Cali, Colombia
