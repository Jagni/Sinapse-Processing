import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;

float r, g, b;

float ang;

// Angle for rotation
float a = 0;

// We'll use a lookup table so that we don't have to repeat the math over and over
float[] depthLookUp = new float[2048];

void setup() {
  size(800, 600, P3D);
  //smooth();
  strokeWeight(0);
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  ang = kinect.getTilt();
  setupAudio();
  
  // Lookup table for all possible depth values (0 - 2047)
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = tracker.rawDepthToMeters(i);
  }
 
  // an FFT needs to know how 
  // long the audio buffers it will be analyzing are
  // and also needs to know 
  // the sample rate of the audio it is analyzing
  fft = new FFT(in.bufferSize(), in.sampleRate());
}

void draw() {
  checkAudio();
  background(255);

  // Run the tracking analysis
   tracker.track();
 // Show the image
  tracker.display();

  // Display some info
  int t = tracker.getThreshold();
  fill(0);
  text("threshold: " + t + "    " +  "framerate: " + int(frameRate) + "    " + 
    "UP increase threshold, DOWN decrease threshold", 10, 500);
}

// Adjust the threshold with key presses
void keyPressed() {
  int t = tracker.getThreshold();
  println("get: %f", kinect.getTilt());
  if (key == CODED) {
    if (keyCode == UP) {
      t+=5;
      tracker.setThreshold(t);
    } else if (keyCode == DOWN) {
      t-=5;
      tracker.setThreshold(t);
    }
    else if (keyCode == LEFT) {
      ang--;
      ang = constrain(ang, -10, 30);
      println(ang);
      kinect.setTilt(ang);
    } else if (keyCode == RIGHT) {
      ang++;
      ang = constrain(ang, -10, 30);
      println(ang);
      kinect.setTilt(ang);
    }
  }
}