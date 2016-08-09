// ================= OPENBCI RADIO CONFIGURATION UTILITY =================
// =               Used to configure OpenBCI radios simply
// =
// = AUTHORS: Colin Fausnaught (cjf1613@rit.edu)
// =
// = LAST REVISED: 8/9/16
// =======================================================================
import controlP5.*;
import processing.serial.*;

/** VARIABLES **/
ControlP5 cp5;
DropdownList chanlist,polllist, serlist;        //Dropdowns menus
PImage smallLogo;

//Buttons to change settings
Button get_channel;  
Button set_channel;  
Button set_channel_over;  
Button get_poll;  
Button set_poll;  
Button set_baud_default;  
Button set_baud_high;  
Button check_sys_up;  
Button refresh;
Button autoconnect;
Button scan_channels;

//Serial Connection
Serial board;

String last_message = "";
String serialPort;
String[] serialPorts = new String[Serial.list().length];
int channel_number = 0;
int poll_number;



//Initialization of variables and the sketch area
void setup() {
  size (440, 400);
  smooth();
  cp5 = new ControlP5(this);        //Used for dropdown menus
  
  smallLogo = loadImage("logo2.png");  
  serialPorts = Serial.list();
  
  //Fills Dropdown menu with appropriate channel numbers
  chanlist = cp5.addDropdownList("Channel Number").setPosition(170,75);
  for(int i = 1; i < 26; i++) {chanlist.addItem("" +i, i);}
  chanlist.close();
  
  //Fills Dropdown menu with appropriate poll numbers
  polllist = cp5.addDropdownList("Poll Number").setPosition(170,235);
  for(int i = 0; i < 256; i++) {polllist.addItem("" +i, i);}
  polllist.close();
  
  //Fills Dropdown menu with available serial ports
  serlist = cp5.addDropdownList("Serial List").setPosition(30, 275).setSize(200,100);
  for(int i = 0; i < serialPorts.length ; i++){ serlist.addItem(serialPorts[i],i); }
  serlist.close();
  
  
  //Create the button objects
  get_channel = new Button("Get Channel", 20, 20, 120, 50);
  set_channel = new Button("Set Channel", 160, 20, 120, 50);
  set_channel_over = new Button("Channel Override", 300, 20, 120, 50);
  get_poll = new Button("Get Poll", 20, 100, 120, 50);
  set_poll = new Button("Set Poll", 160, 180, 120, 50);
  set_baud_default = new Button("Set BAUD to Default", 300, 100, 120, 50);
  set_baud_high = new Button("Set BAUD to High", 300, 180, 120, 50);
  check_sys_up = new Button("System Status", 20, 180, 120, 50);
  refresh = new Button("Refresh", 50,240,60,25);
  autoconnect = new Button("Autoconnect", 300, 260, 120, 50);
  scan_channels = new Button("Autoscan",50,370,60,25);
  
  
}

void draw() {
  background(250);
  print_onscreen(last_message);
  get_channel.Draw();
  set_channel.Draw();
  set_channel_over.Draw();
  get_poll.Draw();
  set_poll.Draw();
  set_baud_default.Draw();
  set_baud_high.Draw();
  check_sys_up.Draw();
  refresh.Draw();
  autoconnect.Draw();
  scan_channels.Draw();
  image(smallLogo,182,95,75,75);
  if(confirm_openbci_draw()){
    drawConnected(true);
  }
  else{
    drawConnected(false);
  }
}


public void drawConnected(boolean isConnected){
  
  if(isConnected) fill(0,255,0);
  else fill(255,0,0);
  
  ellipse(250,290,10,10);
  
  
  fill(0,0,0);
  if(isConnected) text("Connected",250,300);
  else text("Not Connected",250,300);
}


/**** Action Listener for dropdown menus ****/
public void controlEvent(ControlEvent theEvent) {

  if(theEvent.getName().equals("Channel Number")){
    channel_number = (int)theEvent.getValue() + 1;
  }
  else if(theEvent.getName().equals("Poll Number")){
    poll_number = (int)theEvent.getValue();
  }
  else if(theEvent.getName().equals("Serial List")){
    try{
      serialPort = serialPorts[(int)theEvent.getValue()];
      board = new Serial(this,serialPort,115200);
      
      byte input = byte(board.read());
    
      while(input != -1){
        print(char(input));
        input = byte(board.read());
      }
      print("\n");
    }
    catch(Exception e){
      println("Couldn't open port");
    }
  }
  
  
  print_onscreen(last_message);
  
}


/**** Action Listener for buttons ****/
void mousePressed()
{
  if(board != null){
    if (get_channel.MouseIsOver()) get_channel();
    else if (set_channel.MouseIsOver()) set_channel();    
    else if (set_channel_over.MouseIsOver()) set_channel_over();
    else if (get_poll.MouseIsOver()) get_poll();
    else if (set_poll.MouseIsOver()) set_poll();
    else if (set_baud_default.MouseIsOver()) set_baud_default();
    else if (set_baud_high.MouseIsOver()) set_baud_high();
    else if (check_sys_up.MouseIsOver()) system_status();
    else if(autoconnect.MouseIsOver()) autoconnect();
    else if(refresh.MouseIsOver()) refresh();
    else if(scan_channels.MouseIsOver()) scan_channels();
  }
  
  else if(refresh.MouseIsOver()) refresh();
  else if(autoconnect.MouseIsOver()) autoconnect();
}


/**** Prints information to the GUI ****/
void print_onscreen(String localstring){

  textAlign(LEFT);
  fill(0);
  rect(160, 325, 270, 60);
  fill(255);
  text(localstring, 180, 340, 240, 60);
  last_message = localstring;
}

//============== GET CHANNEL ===============
//= Gets channel information from the radio.
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x00).
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void get_channel(){
    board.write(0xF0);
    board.write(0x00);
    delay(100);
    print_bytes();
}

//============== SET CHANNEL ===============
//= Sets the radio and board channel.
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x01) followed by the number to
//= set the board and radio to. Channels can
//= only be 1-25.
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void set_channel(){
    if(channel_number > 0){
      board.write(0xF0);
      board.write(0x01);
      board.write(byte(channel_number));
      delay(1000);
      print_bytes();
    }
    else print_onscreen("Please Select a Channel");
}

//========== SET CHANNEL OVERRIDE ===========
//= Sets the radio channel only
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x02) followed by the number to
//= set the board and radio to. Channels can
//= only be 1-25.
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void set_channel_over(){
    if(channel_number > 0){
      board.write(0xF0);
      board.write(0x02);
      board.write(byte(channel_number));
      delay(100);
      print_bytes();
    }
      
    else print_onscreen("Please Select a Channel");
}

//================ GET POLL =================
//= Gets the poll time
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x03).
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void get_poll(){
      board.write(0xF0);
      board.write(0x03);
      delay(100);
      
      byte input = byte(board.read());
      boolean space_found = false;
      int hex_to_int = 0;
     
      StringBuilder sb = new StringBuilder();
      
      //special case for error messages
      if(char(input) == 'S'){
        while(input != -1){
          print(char(input));
          if(char(input) != '$' && !space_found) sb.append(char(input));
          else if(space_found && char(input) != '$')hex_to_int = Integer.parseInt(String.format("%02X",input),16);
          
          if(char(input) == ' ')space_found = true;
          
          input = byte(board.read());
        }
        
        sb.append(hex_to_int);
        print_onscreen(sb.toString());
        print(" " + hex_to_int + "\n");
      }
      else{
        while(input != -1){
            print(char(input));
            if(char(input) != '$') sb.append(char(input));            
            input = byte(board.read());
          }
          
          sb.append(hex_to_int);
          print_onscreen(sb.toString());
          print(" " + hex_to_int + "\n");
      }
}

//=========== SET POLL OVERRIDE ============
//= Sets the poll time
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x04) followed by the number to
//= set as the poll value. Channels can only 
//= be 0-255.
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void set_poll(){

    board.write(0xF0);
    board.write(0x04);
    board.write(byte(poll_number));
    delay(1000);
    print_bytes();
}

//========== SET BAUD TO DEFAULT ===========
//= Sets BAUD to it's default value (115200)
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x05). 
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void set_baud_default(){
    
    board.write(0xF0);
    board.write(0x05);
    delay(100);
    print_bytes();
    
    try{
      board.stop();
      board = new Serial(this,serialPort,115200);
      println(serialPorts[serialPorts.length -1]);
      byte input = byte(board.read());
      
      while(input != -1){
        print(char(input));
        input = byte(board.read());
      }
      print("\n");
    }
    catch (Exception e){
      println("error opening serial with BAUD 115200");
    }
}

//====== SET BAUD TO HIGH-SPEED MODE =======
//= Sets BAUD to a higher rate (230400)
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x06). 
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void set_baud_high(){

    board.write(0xF0);
    board.write(0x06);
    delay(100);
    print_bytes();
    
    try{
      board.stop();
      board = new Serial(this,serialPort,230400);
      println(serialPorts[serialPorts.length -1]);
      byte input = byte(board.read());
      
      while(input != -1){
        print(char(input));
        input = byte(board.read());
      }
      print("\n");
    }
    catch (Exception e){
      println("error opening serial with BAUD 230400");
    }
      
}

//=========== GET SYSTEM STATUS ============
//= Get's the current status of the system
//=
//= First writes 0xF0 to let the board know
//= a command is coming, then writes the 
//= command (0x07). 
//=
//= After a short delay it then prints bytes
//= from the board.
//==========================================

void system_status(){
    board.write(0xF0);
    board.write(0x07);
    delay(100);
    print_bytes();
}

//Automatically connects to your OpenBCI board!

void autoconnect(){

    String[] serialPorts = new String[Serial.list().length];
    serialPorts = Serial.list();
    
    if(board != null) board.stop();
    
    
    for(int i = 0; i < serialPorts.length; i++){
      try{
          serialPort = serialPorts[i];
          board = new Serial(this,serialPort,115200);
          println(serialPort);
          
          delay(100);
          
          board.write(0xF0);
          board.write(0x07);
          delay(100);
          if(confirm_openbci()) {print_onscreen("Board connected on port " +serialPorts[i] + " with BAUD 115200");return;}
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 115200");
        }
      try{
          board = new Serial(this,serialPort,230400);
          println(serialPort);
          
          delay(100);
          
          board.write(0xF0);
          board.write(0x07);
          delay(100);
          if(confirm_openbci()) {print_onscreen("Board connected on port " +serialPorts[i] + " with BAUD 230400");return;}
          
        }
        catch (Exception e){
          println("Board not on port " + serialPorts[i] +" with BAUD 230400");
        }
    }
}

/**** Helper function to confirm connected serial is an OpenBCI board ****/
boolean confirm_openbci(){
  byte input = byte(board.read());
  if(char(input) == 'F' || char(input) == 'S'){trash_bytes(); return true;}
  else return false;
}
boolean confirm_openbci_draw(){
  if(board != null){
    board.write(0xF0);
    board.write(0x07);
    delay(500);
    byte input = byte(board.read());
    if(char(input) == 'S'){trash_bytes(); return true;}
    else if(char(input) == 'F'){trash_bytes(); return false;}
    else return false;
  }
  else return false;
}

/**** Helper function to read from the serial easily ****/
void print_bytes(){
  byte input = byte(board.read());
  StringBuilder sb = new StringBuilder();
    
  while(input != -1){
    print(char(input));
    if(char(input) != '$') sb.append(char(input));
    input = byte(board.read());
  }
  print_onscreen(sb.toString());
  
  print("\n");
}

/**** Helper function to throw away all bytes coming in from board ****/
void trash_bytes(){
  byte input = byte(board.read());
  
  while(input != -1){
    input = byte(board.read());
  }
}

//Scans through channels until a success message has been found
void scan_channels(){
  
  byte input = byte(board.read());
  StringBuilder sb = new StringBuilder();
  String the_string = "Success: System is Up$$$";
  
  while(input != -1){
    if(char(input) != '$') sb.append(char(input));
    input = byte(board.read());
  }
  
  
  for(int i = 1; i < 26; i++){
    channel_number = i;
    //Channel override
    board.write(0xF0);
    board.write(0x02);
    board.write(byte(channel_number));
    delay(100);
    
    input = byte(board.read());
    //throw out data from override
    while(input != -1){
      input = byte(board.read());
    }
    
    //Channel Status
    board.write(0xF0);
    board.write(0x07);
    delay(100);
    
    input = byte(board.read());
    sb = new StringBuilder();
    
    while(input != -1){
      sb.append(char(input));
      input = byte(board.read());
    }
    
    println(the_string);
    println(sb.toString());
    
    if(sb.toString().equals(the_string)) {
      print_onscreen("Successfully connected to channel: " + i);
      println("Successfully connected to channel: " + i); 
      return;
    }
    
    
    
  }
  
  print_onscreen("Could not connect, is your board powered on?");
  println("Could not connect, is your board powered on?");

      
}

//Refreshes the serial dropdown list

void refresh(){
    serialPorts = new String[Serial.list().length];
    serialPorts = Serial.list();

    serlist = cp5.addDropdownList("Serial List").setPosition(30, 275).setSize(200,100);
  
    for(int i = 0; i < serialPorts.length; i++){ serlist.addItem(serialPorts[i],i); }
    serlist.close();
}


//Class for the buttons
class Button {
  String label;
  float x;    // top left corner x position
  float y;    // top left corner y position
  float w;    // width of button
  float h;    // height of button
  
  Button(String labelB, float xpos, float ypos, float widthB, float heightB) {
    label = labelB;
    x = xpos;
    y = ypos;
    w = widthB;
    h = heightB;
  }
  
  void Draw() {
    fill(218);
    stroke(141);
    rect(x, y, w, h, 10);
    textAlign(CENTER, CENTER);
    fill(0);
    text(label, x + (w / 2), y + (h / 2));
  }
  
  boolean MouseIsOver() {
    if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) {
      return true;
    }
    return false;
  }
}