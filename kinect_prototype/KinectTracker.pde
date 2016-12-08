class KinectTracker {
  // Depth data
  int[] depth;
  int minimumDepth = threshold;
  int maximumDepth = 0;

  KinectTracker() {
    kinect.initDepth();
    kinect.enableMirror(true);
  }

  void display() {
    // Get the raw depth as array of integers
    minimumDepth = threshold;
    maximumDepth = 0;
    depth = kinect.getRawDepth();
    background(0);

    boolean shouldCreatePoints = true;
    
    if (kinectless && points.size() != 0) {
      shouldCreatePoints = false;
    }
    else{
      points = new ArrayList<PVector>();
    }

    if (shouldCreatePoints) {
      createPoints();
    }

    
    kinectLayer.beginDraw();
    kinectLayer.translate(width/2, height/2, 0);
    kinectLayer.directionalLight(255, 0, 255, -1, 0.25, 1);
    kinectLayer.directionalLight(0, 255, 255, 1, -0.25, -1);
    drawBoxes(kinectLayer);
    kinectLayer.endDraw();

    if (record) {
      OBJExport recordLayer = (OBJExport) createGraphics(800,600,"nervoussystem.obj.OBJExport","colored.obj");
      recordLayer.beginDraw();
      drawBoxes(recordLayer);
      recordLayer.endDraw();
      recordLayer.dispose();
      record = false;
    }
  }

  void createPoints() {
    int xRange, yRange;

    if (kinectless) {
      xRange = photo.width;
      yRange = photo.height;
    } else {
      xRange = kinect.width;
      yRange = kinect.height;
    }

    for (int x = 0; x < xRange; x += skip) {
      for (int y = 0; y < yRange; y += skip) {
        int offset = x + y * xRange;

        // Convert kinect data to world xyz coordinate
        int rawDepth;

        if (kinectless) {
          rawDepth = 1100 - (int) map(brightness(photo.pixels[offset]), 0, 255, 500, 1000);
        } else {
          rawDepth = depth[offset];
        }

        if (rawDepth < threshold) {

          if (rawDepth < minimumDepth) {
            minimumDepth = rawDepth;
          }

          if (rawDepth > maximumDepth) {
            maximumDepth = rawDepth;
          }

          PVector v = depthToWorld(x, y, rawDepth);

          points.add( new PVector(v.x*factor, v.y*factor, factor-v.z*factor ) );
        }
      }
    }
  }

  void drawBoxes(PGraphics graphic) {
    PVector point1;
    PVector point2;
    int edgeCount = 0;
    
    for (int i = 0; i < points.size(); i++) {
      int loopCount = 0;
      edgeCount = 0;
      point1 = points.get(i);
      for (int j = i+1; j < points.size(); j++) {
        loopCount++;
        point2 = points.get(j);
        if ( point1.dist(point2) <= factor/(skip*skip)) {
          edgeCount++;
          PVector maxDepthVector = depthToWorld(0, 0, this.maximumDepth);
          PVector minDepthVector = depthToWorld(0, 0, minimumDepth);
          float weight;
            weight = map(point1.z, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, 3, 0.3);
            line3D(point1.x, point1.y, point1.z, 
              point2.x, point2.y, point2.z, 
              weight, 
              color(255, 255, 255), graphic);
        }
        
        if (edgeCount >= 2 || loopCount >= 20) {
          break;
        }
      }
    }
  }
}

void line3D(float x1, float y1, float z1, 
  float x2, float y2, float z2, 
  float weight, 
  color colorLine, PGraphics graphic)
  // drawLine was programmed by James Carruthers
  // see <a href="<a href="http://processing.org/discourse/yabb2/YaBB.pl?num=1262458611/0#9" target="_blank" rel="nofollow">http://processing.org/discourse/yabb2/YaBB.pl?num=1262458611/0#9</a>" 
  // target="_blank" rel="nofollow"><a href="http://processing.org/discourse/yabb2/YaBB.pl?num=1262458611/0#9</a>" target="_blank" rel="nofollow">http://processing.org/discourse/yabb2/YaBB.pl?num=1262458611/0#9</a></a>;
{
  PVector p1 = new PVector(x1, y1, z1);
  PVector p2 = new PVector(x2, y2, z2);
  PVector v1 = new PVector(x2-x1, y2-y1, z2-z1);
  float rho = sqrt(pow(v1.x, 2)+pow(v1.y, 2)+pow(v1.z, 2));
  float phi = acos(v1.z/rho);
  float the = atan2(v1.y, v1.x);
  v1.mult(0.5);
  graphic.pushMatrix();
  graphic.translate(x1, y1, z1);
  graphic.translate(v1.x, v1.y, v1.z);
  graphic.rotateZ(the);
  graphic.rotateY(phi);
  graphic.noStroke();
  graphic.fill(colorLine);
  graphic.box(weight, weight, p1.dist(p2));
  graphic.popMatrix();
}