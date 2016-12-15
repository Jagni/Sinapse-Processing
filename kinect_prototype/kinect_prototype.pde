import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import nervoussystem.obj.*;
import java.awt.image.BufferedImage;
import java.io.*;
import javax.imageio.ImageIO;
import jcifs.util.Base64;
import websockets.*;
import shapes3d.utils.*;
import shapes3d.*;

KinectTracker tracker;
Kinect kinect;

boolean kinectless = false;
PImage photo;
int threshold = 1000;
boolean record = false;


WebsocketServer ws;

float r, g, b;

//Kinect angle
float ang;
int skip = 6;
int factor = 1100;
ArrayList<PVector> points = new ArrayList<PVector>();

// Lookup table for all possible depth values (0 - 2047)
float[] depthLookUp = new float[2048];

PGraphics kinectLayer;

PApplet applet;
float centerX, centerY; 
void setup() {
  fullScreen(P3D);
  kinectLayer = createGraphics(800, 600, P3D);

  frameRate(60);
  applet = this;
    
  centerX = width/2.0;
  centerY = height/2; 
  
  if (kinectless){
    photo = loadImage("kinectless.png");
    photo.loadPixels();
  }
  
  ws = new WebsocketServer(this, 8080, "/");
  
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  ang = kinect.getTilt();
  //setupAudio();
  
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
 
  //fft = new FFT(in.bufferSize(), in.sampleRate());
}

void adjustCamera(){
  PVector v = depthToWorld(0, 0, threshold);
  
  float xFactor = map(mouseX - (width/2), 0, width, -1, 1);
  float yFactor = map(mouseY - (height/2), 0, height, -1, 1);
  float zFactor = map(abs(mouseX - (width/2)), 0, 400, 0, 1);

  kinectLayer.camera((2*(mouseX + xFactor*(width/4))), (2*(mouseY + yFactor*(height/4))), zFactor*((factor-v.z*factor)/2) + 1000, centerX, centerY, (factor-v.z*factor)/2, 0, 1, 0);
}

void mouseMoved(){
  adjustCamera();
}

void keyPressed(){
    if (key == 'w'){
      centerY+= 10;
    }
    else if (key == 's'){
      centerY-= 10;
    }
    if (key == 'a'){
      centerX+= 100;
    }
    else if (key == 'd'){
      centerX-= 100;
    }
    
    else if (key == 'z'){
      skip--;
      skip = (int) constrain(skip, 1, 20);
      points = new ArrayList<PVector>();
    }
    
    else if (key == 'x'){
      skip++;
      skip = (int) constrain(skip, 1, 20);
      points = new ArrayList<PVector>();
    }
    
    
    else if (key == 'c' || key == 'C'){
      factor-=25;
      points = new ArrayList<PVector>();
    }
    
    else if(key == 'v' || key == 'V') {
      factor+=25;
      points = new ArrayList<PVector>();
    }
    
    else if(key == 'q' || key == 'Q') {
      record = true;
    }
    
    if (key == CODED) {
      if (keyCode == UP) {
        threshold +=20;
        threshold = (int) constrain(threshold, 0, 1000);
        points = new ArrayList<PVector>();
      }
      else if (keyCode == DOWN) {
        threshold-=20;
        threshold = (int) constrain(threshold, 0, 1000);
        points = new ArrayList<PVector>();
      }
    }
    adjustCamera();
}

void draw() {
  //checkAudio();
  tracker.display();
  text("fps: " + frameRate, 10, 50);
  image(kinectLayer, (width/2) - kinectLayer.width/2, (height/2) - kinectLayer.height/2);
  
  BufferedImage buffimg = (BufferedImage) kinectLayer.get().getNative(); //new BufferedImage( width, height, BufferedImage.TYPE_INT_RGB);
  
  ByteArrayOutputStream baos = new ByteArrayOutputStream();
  try {
      ImageIO.write( buffimg, "jpg", baos );
    } catch( IOException ioe ) {
  }
  
  String b64image = Base64.encode( baos.toByteArray() );
  
  ws.sendMessage(b64image);
  
  kinectLayer.beginDraw();
  kinectLayer.clear();
  kinectLayer.endDraw();
}

float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

// Only needed to make sense of the ouput depth values from the kinect
PVector depthToWorld(int x, int y, int depthValue) {
  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;

// Drawing the result vector to give each point its three-dimensional space
  PVector result = new PVector();
  double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}

byte[] int2byte(int[]src) {
  int srcLength = src.length;
  byte[]dst = new byte[srcLength << 2];
    
  for (int i=0; i<srcLength; i++) {
    int x = src[i];
    int j = i << 2;
    dst[j++] = (byte) (( x >>> 0 ) & 0xff);           
    dst[j++] = (byte) (( x >>> 8 ) & 0xff);
    dst[j++] = (byte) (( x >>> 16 ) & 0xff);
    dst[j++] = (byte) (( x >>> 24 ) & 0xff);
  }
  return dst;
}