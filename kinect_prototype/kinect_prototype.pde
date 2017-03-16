import java.awt.image.BufferedImage;
import java.io.*;
import javax.imageio.ImageIO;
import java.util.Arrays;

WB_Render render;

KinectTracker tracker;
Kinect kinect;

boolean kinectless = false;
boolean lines = true;
boolean triangles = true;
PImage photo;
int threshold = 960;
boolean record = false;
PShader blur;
float cameraX, cameraY;
boolean cameraIsLocked = true;
ArrayList<String> avatars = new ArrayList<String>();
int avatarIndex = 0;
WebsocketServer ws;

float r, g, b;

//Kinect angle
float ang;
int skip = 16;
int factor = 725;

ArrayList<PVector> sentPoints = new ArrayList<PVector>();
ArrayList<PVector> receivedPoints = new ArrayList<PVector>();
ArrayList<PVector> drawnPoints = new ArrayList<PVector>();

// Lookup table for all possible depth values (0 - 2047)
float[] depthLookUp = new float[2048];
float[][] gridMatrix;

PGraphics kinectLayer;
PGraphics interfaceLayer;

PostFX fx;

PApplet applet;
float centerX, centerY; 
void setup() {
  noCursor();
  render=new WB_Render(this);
  fullScreen(P3D);
  //size(800, 600, P3D);
  if (kinectless){
    cameraX = 0.5*width;
    cameraY = 0.5*height;
  }
  else{
    cameraX = 0.509375* width;
    cameraY = 0.27314815*height;
  }
  
  fx = new PostFX(width, height);
  kinectLayer = createGraphics(width, height, P3D);
  interfaceLayer = createGraphics(width, height, P2D);
  blur = loadShader("blur.glsl"); 
  setupAudio();
  frameRate(60);
  applet = this;
  
  avatars.add("faraó");
  avatars.add("bolinhas");
  avatars.add("quadrados");
  avatars.add("linhas");
  avatars.add("hemesh");

  centerX = width/2.0 - 200;
  centerY = -150 + height/2; 

  if (kinectless) {
    photo = loadImage("kinectless.png");
    photo.loadPixels();
    threshold = 500;
  }

  ws = new WebsocketServer(this, 7890, "/");
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  ang = kinect.getTilt();

  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }

  fft = new FFT(in.bufferSize(), in.sampleRate());
  adjustCamera();
}

void adjustCamera() {
  PVector v = depthToWorld(0, 0, threshold);
  float xFactor = map(cameraX - (width/2), 0, width, -1, 1);
  float yFactor = map(cameraY - (height/2), 0, height, -1, 1);
  float zFactor = map(abs(cameraX - (width/2)), 0, 400, 0, 1);
  kinectLayer.camera((2*(cameraX + xFactor*(width/4))), (2*(cameraY + yFactor*(height/4))), zFactor*((factor-v.z*factor)/2) + 1000, centerX, centerY, (factor-v.z*factor)/2, 0, 1, 0);
}

void mouseMoved() {
  if (!cameraIsLocked){
    cameraX = mouseX;
    cameraY = mouseY;
  }
  adjustCamera();
}

void mouseClicked(){
  cameraIsLocked = !cameraIsLocked;
  println("camera x: " + cameraX + "   camera y:" + cameraY);
  println("proporcao x: " + cameraX/width + "   proporcao y:" + cameraY/height);
}

void keyPressed() {
  if (key == 'l') {
    lines = !lines;
  } else if (key == 't') {
    triangles = !triangles;
  } else if (key == 'w') {
    centerY+= 10;
    adjustCamera();
  } else if (key == 's') {
    centerY-= 10;
    adjustCamera();
  }
  if (key == 'a') {
    centerX+= 100;
    adjustCamera();
  } else if (key == 'd') {
    centerX-= 100;
    adjustCamera();
  } else if (key == 'z') {
    skip--;
    skip = (int) constrain(skip, 1, 50);
    sentPoints = new ArrayList<PVector>();
  } else if (key == 'x') {
    skip++;
    skip = (int) constrain(skip, 1, 50);
    sentPoints = new ArrayList<PVector>();
  } else if (key == 'c' || key == 'C') {
    factor-=25;
    sentPoints = new ArrayList<PVector>();
  } else if (key == 'v' || key == 'V') {
    factor+=25;
    sentPoints = new ArrayList<PVector>();
  } else if (key == 'q' || key == 'Q') {
    record = true;
  }

  if (key == CODED) {
    if (keyCode == UP) {
      threshold +=20;
      threshold = (int) constrain(threshold, 0, 1000);
      sentPoints = new ArrayList<PVector>();
    } else if (keyCode == DOWN) {
      threshold-=20;
      threshold = (int) constrain(threshold, 0, 1000);
      sentPoints = new ArrayList<PVector>();
    }
     else if (keyCode == LEFT) {
      avatarIndex--;
      if (avatarIndex < 0){
        avatarIndex = avatars.size()-1;
      }
      avatarIndex = avatarIndex % avatars.size();
    }
     else if (keyCode == RIGHT) {
      avatarIndex++;
      avatarIndex = avatarIndex % avatars.size();
    }
  }
}

void webSocketServerEvent(String msg){
  if (msg.length() > 4){
  msg = msg.substring(0, msg.length()-1);
  msg = msg.substring(0, msg.length()-1);
  msg = msg.substring(1, msg.length());
  ArrayList<String> pointStringList = new ArrayList<String>(Arrays.asList(msg.split("], ")));
  receivedPoints = new ArrayList<PVector>();
  for (String string : pointStringList){
    string = string.substring(1, string.length());
    ArrayList<String> pointStrings = new ArrayList<String>(Arrays.asList(string.split(",")));
    float x = Float.parseFloat(pointStrings.get(0));
    float y = Float.parseFloat(pointStrings.get(1));
    float z = Float.parseFloat(pointStrings.get(2));
    receivedPoints.add(new PVector(x, y, z));
  }
  }
}


void draw() {
  checkAudio();

  tracker.display();
  drawInterface(interfaceLayer);

  PGraphics result = fx.filter(kinectLayer)
    .brightPass(0)
    .blur(int(skip*4 + int(maxAmplitude*skip*10)), skip*4, false)
    .blur(int(skip*4 + int(maxAmplitude*skip*10)), skip*4, true)
    .close();

  blendMode(BLEND);
  image(kinectLayer, (width/2) - kinectLayer.width/2, (height/2) - kinectLayer.height/2);
  blendMode(SCREEN);
  image(result, (width/2) - kinectLayer.width/2, (height/2) - kinectLayer.height/2);

  result = fx.filter(interfaceLayer)
    .brightPass(0.1)
    .blur(5, 5, false)
    .blur(5, 5, true)
    .close();

  blendMode(BLEND);
  image(interfaceLayer, 0, 0);
  blendMode(SCREEN);
  image(result, 0, 0);

  //image(interfaceLayer, 0, 0);
  text("fps: " + frameRate, 10, 50);

  //BufferedImage buffimg = (BufferedImage) kinectLayer.get().getNative(); //new BufferedImage( width, height, BufferedImage.TYPE_INT_RGB);
  //ByteArrayOutputStream baos = new ByteArrayOutputStream();
  //try {
  //  ImageIO.write( buffimg, "jpg", baos );
  //} 
  //catch( IOException ioe ) {
  //}

  //String b64image = Base64.encode( baos.toByteArray() );

  //ByteArrayOutputStream bao = new ByteArrayOutputStream();
  //ObjectOutputStream oos = new ObjectOutputStream(bao);
  //oos.writeObject(points);
  //oos.close();

  ws.sendMessage(sentPoints.toString());
  // transfer
  //ws.sendMessage(b64image);

  kinectLayer.beginDraw();
  kinectLayer.clear();
  kinectLayer.endDraw();

  interfaceLayer.beginDraw();
  interfaceLayer.clear();
  interfaceLayer.endDraw();
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