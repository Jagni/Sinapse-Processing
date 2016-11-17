import org.openkinect.freenect.*;
import org.openkinect.processing.*;

boolean kinectless = true;
PImage photo;
int threshold = 50;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import javax.imageio.ImageIO;
import jcifs.util.Base64;
import websockets.*;

// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;

WebsocketServer ws;

float r, g, b;

//Kinect angle
float ang;

// Angle for rotation
float a = 0;

//Pixel skipping
int skip = 10;
//Resizing ratio
int factor = 1000;

// Lookup table for all possible depth values (0 - 2047)
float[] depthLookUp = new float[2048];

void setup() {
  size(800, 600, P3D);
  sphereDetail(10);
  
  if (kinectless){
    photo = loadImage("kinectless.jpg");
    photo.loadPixels();
    factor = 600;
    skip = 4;
  }
  
  ws = new WebsocketServer(this, 8080, "/");
  
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  ang = kinect.getTilt();
  setupAudio();
  
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
 
  fft = new FFT(in.bufferSize(), in.sampleRate());
}

void draw() {
  if (keyPressed) {
    if (key == CODED) {
      if (keyCode == UP) {
        threshold +=5;
      }
      else if (keyCode == DOWN) {
        threshold-=5;
      }
      else if (keyCode == LEFT) {
        a-=0.1;
        ang = constrain(ang, -10, 30);
        println(ang);
        kinect.setTilt(ang);
      }
      else if (keyCode == RIGHT) {
        a += 0.1;
        ang = constrain(ang, -10, 30);
        println(ang);
        kinect.setTilt(ang);
      }
    }
  }
  checkAudio();
  tracker.display();
    
  loadPixels();
  BufferedImage buffimg = new BufferedImage( width, height, BufferedImage.TYPE_INT_RGB);
  buffimg.setRGB( 0, 0, width, height, pixels, 0, width );
  
  ByteArrayOutputStream baos = new ByteArrayOutputStream();
  try {
      ImageIO.write( buffimg, "jpg", baos );
    } catch( IOException ioe ) {
  }
  
  String b64image = Base64.encode( baos.toByteArray() );
  
  ws.sendMessage(b64image);
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
