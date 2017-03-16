ArrayList<Triangle> myTriangles = new ArrayList<Triangle>(); //<>// //<>//
ArrayList<Triangle> originalTriangles = new ArrayList<Triangle>();
ArrayList<PVector> originalPoints = new ArrayList<PVector>();
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

    drawnPoints = new ArrayList<PVector>();

    //if (kinectless && sentPoints.size() > 0) {
    //  shouldCreatePoints = true;
    //} else {
    sentPoints = new ArrayList<PVector>();
    originalPoints = new ArrayList<PVector>();
    //}

    if (shouldCreatePoints) {
      createPoints();
    }

    if (receivedPoints.size() > 0) {
      drawnPoints = new ArrayList<PVector>(receivedPoints);
      ArrayList<PVector> sentCopy = new ArrayList<PVector>(sentPoints);
      sentCopy.removeAll(drawnPoints);
      drawnPoints.addAll(sentCopy);
    } else {
      drawnPoints = new ArrayList<PVector>(sentPoints);
    }

    kinectLayer.beginDraw();
    kinectLayer.translate(width/2, height/2, 0);
    kinectLayer.directionalLight(mainRed, mainGreen, mainBlue, -1, 0, -0.25);
    kinectLayer.directionalLight(secondaryRed, secondaryGreen, secondaryBlue, 1, 0, -0.25);
    if (drawnPoints.size() > 0) {
      switch(avatars.get(avatarIndex)) {
      case "faraó":
        {
          drawTriangles(drawnPoints, kinectLayer);
          break;
        }

      case "bolinhas":
        {
          drawSpheres(drawnPoints, kinectLayer);
          break;
        }

      case "quadrados":
        {
          drawBoxes(drawnPoints, kinectLayer);
          break;
        }

      case "linhas":
        {
          drawCoordinatedBoxes(drawnPoints, kinectLayer);
          break;
        }
      case "hemesh":
        {
          drawGrid();
          break;
        }
      }
    }
    kinectLayer.endDraw();

    if (record) {
      OBJExport recordLayer = (OBJExport) createGraphics(800, 600, "nervoussystem.obj.OBJExport", "colored.obj");
      recordLayer.setColor(true);
      recordLayer.beginDraw();
      drawTriangles(drawnPoints, recordLayer);
      recordLayer.endDraw();
      recordLayer.dispose();
      record = false;
    }
  }

  void drawGrid() {
    pushMatrix();
    translate(width/2, height/2);
    float xFactor = map(cameraX, 0, width, -1, 1);
    float yFactor = map(cameraY, 0, height, -1, 1);
    rotateY(xFactor*QUARTER_PI);
    rotateX(yFactor*QUARTER_PI);
    HEC_Grid creator=new HEC_Grid();
    int xRange, yRange;
    if (kinectless) {
      xRange = photo.width;
      yRange = photo.height;
    } else {
      xRange = kinect.width;
      yRange = kinect.height;
    }
    creator.setU(xRange/skip);// number of cells in U direction
    creator.setV(yRange/skip);// number of cells in V direction
    creator.setUSize(width);// size of grid in U direction
    creator.setVSize(height);// size of grid in V direction
    creator.setWValues(gridMatrix);// displacement of grid points (W value)
    HE_Mesh mesh=new HE_Mesh(creator);
    fill(0);
    noStroke();
    render.drawFaces(mesh);
    stroke(color(mainRed, mainGreen, mainBlue));
    render.drawEdges(mesh);
    popMatrix();
  }

  void drawTriangles(ArrayList<PVector> points, PGraphics pg) {

    originalTriangles.clear();
    new Triangulator().triangulate(originalPoints, originalTriangles);

    for (int i = 0; i < originalTriangles.size(); i++) {
      Triangle t = originalTriangles.get(i);
      if (dist(t.p1.x, t.p1.y, t.p2.x, t.p2.y) < skip*0.0033 && dist(t.p1.x, t.p1.y, t.p3.x, t.p3.y) < skip*0.0033 &&  dist(t.p3.x, t.p3.y, t.p2.x, t.p2.y) < skip*0.0033) {
        //if (t.p1.dist(t.p2) < skip*4 && t.p1.dist(t.p3) < skip*4 && t.p3.dist(t.p2) < skip*4) {
        //float zAverage = (t.p1.z + t.p2.z + t.p3.z)/3;
        //PVector maxDepthVector = depthToWorld(0, 0, this.maximumDepth);
        //PVector minDepthVector = depthToWorld(0, 0, minimumDepth);
        if (triangles) {
          //pg.fill(map(zAverage, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, 255, 50));
          pg.fill(50 + maxAmplitude*205);
          pg.noStroke();
          pg.beginShape(TRIANGLES);
           pg.vertex(t.p1.x*factor, t.p1.y*factor, factor-t.p1.z*factor );
          pg.vertex(t.p2.x*factor, t.p2.y*factor, factor-t.p2.z*factor );
          pg.vertex(t.p3.x*factor, t.p3.y*factor, factor-t.p3.z*factor );
          pg.endShape();
        }

        float weight = 2;//map(t.p2.z, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, 3, 1);

        if (lines) {
          line3D(t.p1.x*factor, t.p1.y*factor, factor-t.p1.z*factor , 
            t.p2.x*factor, t.p2.y*factor, factor-t.p2.z*factor, 
            weight, 
            color(50 + maxAmplitude*205), pg);

          //weight = map(t.p3.z, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, 3, 1);


          line3D(t.p1.x*factor, t.p1.y*factor, factor-t.p1.z*factor, 
            t.p3.x*factor, t.p3.y*factor, factor-t.p3.z*factor, 
            weight, 
            color(200 + maxAmplitude*55), pg);

          //sweight = map(t.p1.z, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, 3, 1);


          line3D(t.p3.x*factor, t.p3.y*factor, factor-t.p3.z*factor, 
            t.p2.x*factor, t.p2.y*factor, factor-t.p2.z*factor, 
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
    gridMatrix = new float[(xRange/skip) + 1][(yRange/skip) + 1];
    int gridX = 0, gridY = 0;
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
          gridMatrix[gridX][gridY] = map(rawDepth, 0, 2046, 1023, 0)/10;
          PVector v = depthToWorld(x, y, rawDepth);
          originalPoints.add(v);
          sentPoints.add( new PVector(v.x*factor, v.y*factor, factor-v.z*factor ) );
        } else {
          gridMatrix[gridX][gridY] = 0;
        }
        gridY++;
      }
      gridX++;
      gridY = 0;
    }
  }

  void drawCoordinatedBoxes(ArrayList<PVector> points, PGraphics graphic) {
    PVector point1, point2;
    PVector originalPoint1, originalPoint2;
    int edgeCount = 0;
    int loopCount = 0;
    int xRange, yRange;
    if (kinectless) {
      xRange = photo.width;
      yRange = photo.height;
    } else {
      xRange = kinect.width;
      yRange = kinect.height;
    }
    for (int i = 0; i < points.size(); i++) {
      edgeCount = 0;
      loopCount = 0;
      originalPoint1 = originalPoints.get(i);
      point1 = points.get(i);
      for (int j = i+1; j < points.size(); j++) {
        loopCount++;
        originalPoint2 = originalPoints.get(j);
        point2 = points.get(j);
        float thresholdMap = map(threshold, 0, 2046, 1, 0.0075);
        if (originalPoint1.dist(originalPoint2) < skip*0.0015/thresholdMap){
        //if (dist(originalPoint1.x, originalPoint1.y, originalPoint2.x, originalPoint2.y) < skip*0.0025) {
          edgeCount++;
          PVector maxDepthVector = depthToWorld(0, 0, maximumDepth);
          PVector minDepthVector = depthToWorld(0, 0, minimumDepth);
          float weight;
          //weight = map(point1.z, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, 3, 1);
          line3D(point1.x, point1.y, point1.z, 
            point2.x, point2.y, point2.z, 
            2, 
            color(255, 255, 255), graphic);
        }

        if (edgeCount >= 3) {
          break;
        }

        if (loopCount >= 2*(yRange/skip)) {
          break;
        }
      }
    }
  }

  void drawSpheres(ArrayList<PVector> points, PGraphics graphic) {
    graphic.sphereDetail(10);
    graphic.noStroke();
    for (PVector point : points) {
      graphic.fill(255);
      graphic.pushMatrix();
      graphic.translate(point.x, point.y, point.z);
      PVector maxDepthVector = depthToWorld(0, 0, maximumDepth);
      PVector minDepthVector = depthToWorld(0, 0, minimumDepth);
      float weight;
      weight = map(point.z, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, skip*0.75, skip*0.3);
      graphic.sphere(weight);
      graphic.popMatrix();
    }
  }

  void drawBoxes(ArrayList<PVector> points, PGraphics graphic) {
    graphic.sphereDetail(10);
    graphic.noStroke();
    for (PVector point : points) {
      graphic.fill(255);
      graphic.pushMatrix();
      graphic.translate(point.x, point.y, point.z);
      graphic.rotateY(PI/4);
      PVector maxDepthVector = depthToWorld(0, 0, maximumDepth);
      PVector minDepthVector = depthToWorld(0, 0, minimumDepth);
      float weight;
      weight = map(point.z, factor-minDepthVector.z*factor, factor-maxDepthVector.z*factor, skip*0.75, skip*0.4);
      graphic.box(weight);
      graphic.popMatrix();
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