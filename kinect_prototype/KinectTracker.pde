class KinectTracker {

  // Depth threshold
  int threshold = 745;

  // Raw location
  PVector loc;

  // Interpolated location
  // Depth data
  int[] depth;
  
  // What we'll show the user
  PImage display;
   
  KinectTracker() {
    // This is an awkard use of a global variable here
    // But doing it this way for simplicity
    kinect.initDepth();
    kinect.enableMirror(true);
    // Make a blank image
    display = createImage(kinect.width, kinect.height, RGB);
    // Set up the vectors
    loc = new PVector(0, 0);
  }

  void track() {
    // Get the raw depth as array of integers
    depth = kinect.getRawDepth();

    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    float sumY = 0;
    float count = 0;

    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {
        
        int offset =  x + y*kinect.width;
        // Grabbing the raw depth
        int rawDepth = depth[offset];

        // Testing against threshold
        if (rawDepth < threshold) {
          sumX += x;
          sumY += y;
          count++;
        }
      }
    }
    // As long as we found something
    if (count != 0) {
      loc = new PVector(sumX/count, sumY/count);
    }

  }

  void display() {
    //PImage img = kinect.getDepthImage();

    //// Being overly cautious here
    //if (depth == null || img == null) return;

    //// Going to rewrite the depth image to show which pixels are in threshold
    //// A lot of this is redundant, but this is just for demonstration purposes
    //display.loadPixels();
    //for (int x = 0; x < kinect.width; x++) {
    //  for (int y = 0; y < kinect.height; y++) {

    //    int offset = x + y * kinect.width;
    //    // Raw depth
    //    int rawDepth = depth[offset];
    //    int pix = x + y * display.width;
    //    if (rawDepth < threshold) {
    //      // A red color instead
    //      display.pixels[pix] = color(r, g, b);
    //    } else {
    //      display.pixels[pix] = color(0, 0, 0);
    //    }
    //  }
    //}
    //display.updatePixels();

    //// Draw the image
    //display.filter(DILATE);
    //image(display, 0, 0);
    
    
    // Get the raw depth as array of integers
  int[] depth = kinect.getRawDepth();

  // We're just going to calculate and draw every 4th pixel (equivalent of 160x120)
  int skip = 4;

  // Translate and rotate
  translate(width/2, height/2, -50);
  rotateY(a);
  
  background(0);
  
  // Nested for loop that initializes x and y pixels and, for those less than the
  // maximum threshold and at every skiping point, the offset is caculated to map
  // them on a plane instead of just a line
  for (int x = 0; x < kinect.width; x += skip) {
    for (int y = 0; y < kinect.height; y += skip) {
      
    int offset = x + y * kinect.width;
      
      // Convert kinect data to world xyz coordinate
      int rawDepth = depth[offset];
      
      if (rawDepth < threshold) {

      PVector v = depthToWorld(x, y, rawDepth);

      fill(r, g, b);
      pushMatrix();
      // Scale up by 200
      float factor = 1000;
      translate(v.x*factor, v.y*factor, factor-v.z*factor);
      // Draw a point
      
      ellipse(0,0,3,3);
      
      //point(0, 0);
      popMatrix();
      }
    }
  }
  }

  int getThreshold() {
    return threshold;
  }

  void setThreshold(int t) {
    threshold =  t;
  }
  
  // These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
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
  result.z = (float)(depth*1.1);
  return result;
}
}