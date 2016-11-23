class KinectTracker {
  // Depth data
  int[] depth;
  
  KinectTracker() {
    // This is an awkard use of a global variable here
    // But doing it this way for simplicity
    kinect.initDepth();
    kinect.enableMirror(true);
  }

  void display() {
    // Get the raw depth as array of integers
    int[] depth = kinect.getRawDepth();
    PVector v;
    
    if (kinectless){
      v = depthToWorld(width/2, height/2, threshold);
      translate(width/2, height/2, v.z*factor);
      rotateY(a);
      translate(0, 0, -v.z*factor);
    }
    else{
      v = depthToWorld(width/2, height/2, threshold/2);
      translate(width/2, height/2, -v.z*factor);
      rotateY(a);
      translate(0, 0, v.z*factor);
    }
    
    background(0);
    //Color of the spheres
    ambientLight(r,g,b);
    //Lighting
    directionalLight(255, 0, 255, -1, 0.25, 0);
    
    //Determines the closest point
    float minimumDepth = threshold;  
    //skeleton.clear();
    ArrayList<PVector> points = new ArrayList<PVector>();
    for (int x = 0; x < kinect.width; x += skip) {
      for (int y = 0; y < kinect.height; y += skip) {
        int offset = x + y * kinect.width;
        
        // Convert kinect data to world xyz coordinate
        int rawDepth = depth[offset];
        
        if (kinectless){
          rawDepth = 540 - (int) map(brightness(photo.pixels[offset]), 0, 255, 40, 500);
        }
        
        if (rawDepth < threshold) {
          
          if (rawDepth < minimumDepth){
            minimumDepth = rawDepth;
          }
  
          v = depthToWorld(x, y, rawDepth);
    
          noStroke();
          pushMatrix();
          translate(v.x*factor, v.y*factor, factor-v.z*factor);
       
          if (kinectless){
            sphere(skip * map(rawDepth, minimumDepth, threshold, 0.25, 0.05));
            points.add( new PVector(v.x*factor, v.y*factor, factor-v.z*factor ) );
          }
          else{
            //sphere(skip * map(rawDepth, minimumDepth, threshold, 0.15, 0.05));
            box(skip * map(rawDepth, minimumDepth, threshold, 0.3, 0.15));
            points.add( new PVector(v.x*factor, v.y*factor, factor-v.z*factor ) );
          }
        
          popMatrix();
        }
      }
    }
    
    for (int i = 0; i < points.size(); i++) {
      int edgeCount = 0;
      PVector point1 = points.get(i);
      for (int j = i+1; j < points.size(); j++) {
        PVector point2 = points.get(j);
        //if (dist(point1.x, point1.y, point2.x, point2.y) <= edgeDistance && point1.z != point2.z) {
        if (point1.dist(point2) <= edgeDistance) {
          edgeCount++;
          strokeWeight(5);
          stroke(255);
          line(point1.x, point1.y, point1.z, point2.x, point2.y, point2.z);
        }
        
        if (edgeCount >= 3){
          break;
        }
      }
    }
    //skeleton.plot(0.15, 0.1);
  }

  int getThreshold() {
    return threshold;
  }

  void setThreshold(int t) {
    threshold =  t;
  }
}