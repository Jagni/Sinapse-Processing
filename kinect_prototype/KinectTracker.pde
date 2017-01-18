ArrayList<Triangle> myTriangles = new ArrayList<Triangle>();
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

    if (kinectless && sentPoints.size() > 0) {
      shouldCreatePoints = false;
    } else {
      sentPoints = new ArrayList<PVector>();
    }

    if (shouldCreatePoints) {
      createPoints();
    }

    if (receivedPoints.size() > 0){
      drawnPoints = receivedPoints;
    }
    else{
      drawnPoints = sentPoints;
    }

    kinectLayer.beginDraw();
    kinectLayer.translate(width/2, height/2, 0);
    kinectLayer.directionalLight(mainRed, mainGreen, mainBlue, -1, 0, 0);
    kinectLayer.directionalLight(secondaryRed, secondaryGreen, secondaryBlue, 1, 0, 0);
    //drawBoxes(kinectLayer);
    if (drawnPoints.size() > 0) {
      drawTriangles(kinectLayer);
    }
    //kinectLayer.filter(blur);
    kinectLayer.endDraw();

    if (record) {
      OBJExport recordLayer = (OBJExport) createGraphics(800, 600, "nervoussystem.obj.OBJExport", "colored.obj");
      recordLayer.setColor(true);
      recordLayer.beginDraw();
      drawTriangles(recordLayer);
      recordLayer.endDraw();
      recordLayer.dispose();
      record = false;
    }
  }

  void drawTriangles(PGraphics pg) {

    myTriangles.clear();
    new Triangulator().triangulate(drawnPoints, myTriangles);
    
    for (Triangle t : myTriangles)
    {
      //float p = t.diameter()/2;
      //float area = sqrt(p*((p-t.p1.dist(t.p2))*(p-t.p2.dist(t.p3))*(p-t.p3.dist(t.p1))));
      if (dist(t.p1.x, t.p1.y, t.p2.x, t.p2.y) < skip*5 && dist(t.p1.x, t.p1.y, t.p3.x, t.p3.y) < skip*5 &&  dist(t.p3.x, t.p3.y, t.p2.x, t.p2.y) < skip*5){
      //if (t.p1.dist(t.p2) < skip*4 && t.p1.dist(t.p3) < skip*4 && t.p3.dist(t.p2) < skip*4) {
        float zAverage = (t.p1.z + t.p2.z + t.p3.z)/3;
        PVector maxDepthVector = depthToWorld(0, 0, this.maximumDepth);
        PVector minDepthVector = depthToWorld(0, 0, minimumDepth);
        if (triangles){
        //pg.fill(map(zAverage, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, 255, 50));
        pg.fill(50 + maxAmplitude*205);
        pg.noStroke();
        pg.beginShape(TRIANGLES);
        pg.vertex(t.p1.x, t.p1.y, t.p1.z);
        pg.vertex(t.p2.x, t.p2.y, t.p2.z);
        pg.vertex(t.p3.x, t.p3.y, t.p3.z);
        pg.endShape();
        }

        float weight = map(t.p2.z, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, 3, 1);

        if (lines){
        line3D(t.p1.x, t.p1.y, t.p1.z, 
          t.p2.x, t.p2.y, t.p2.z, 
          weight, 
          color(50 + maxAmplitude*205), pg);

        weight = map(t.p3.z, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, 3, 1);


        line3D(t.p1.x, t.p1.y, t.p1.z, 
          t.p3.x, t.p3.y, t.p3.z, 
          weight, 
          color(200 + maxAmplitude*55), pg);
          
        weight = map(t.p1.z, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, 3, 1);


        line3D(t.p3.x, t.p3.y, t.p3.z, 
          t.p2.x, t.p2.y, t.p2.z, 
          weight, 
          color(255), pg);
        }
      }
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

          sentPoints.add( new PVector(v.x*factor, v.y*factor, factor-v.z*factor ) );
        }
      }
    }
  }

  void drawBoxes(PGraphics graphic) {
    PVector point1;
    PVector point2;
    int edgeCount = 0;

    for (int i = 0; i < drawnPoints.size(); i++) {
      int loopCount = 0;
      edgeCount = 0;
      point1 = drawnPoints.get(i);
      for (int j = i+1; j < drawnPoints.size(); j++) {
        loopCount++;
        point2 = drawnPoints.get(j);
        if ( point1.dist(point2) <= skip*2) {
          edgeCount++;
          PVector maxDepthVector = depthToWorld(0, 0, this.maximumDepth);
          PVector minDepthVector = depthToWorld(0, 0, minimumDepth);
          float weight;
          weight = map(point1.z, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, 5, 1);
          line3D(point1.x, point1.y, point1.z, 
            point2.x, point2.y, point2.z, 
            5, 
            color(255, 255, 255), graphic);
        }

        if (edgeCount >= 2) {
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