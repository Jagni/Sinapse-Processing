float squareSize;

void drawInterface(PGraphics pg){
  pg.beginDraw();
  pg.background(0, 0);
  squareSize = height/40;
  pg.fill(0, 0);
  pg.stroke(secondaryRed, secondaryGreen, secondaryBlue);
  pg.pushMatrix();
  pg.strokeWeight(2);
  pg.translate(width/2, height/40);
  pg.line(-0.74*squareSize, squareSize*0.74, -1, 0.74*squareSize, squareSize*0.74, -1);
  pg.popMatrix();
  
  pg.pushMatrix();
  pg.translate(width/2 - 1.5*squareSize, height/40);
  pg.rotate(PI/4);
  pg.rect(0, 0, squareSize, squareSize);
  pg.popMatrix();
  
  pg.pushMatrix();
  pg.translate(width/2 + 1.5*squareSize, height/40);
  pg.rotate(PI/4);
  pg.rect(0, 0, squareSize, squareSize);
  pg.popMatrix();
  
  fft.forward(in.mix);
  
  for(int i = 1; i <= 3; i++)  {
    pg.pushMatrix();
    pg.translate(width - width/80, height - height/80);
    pg.rotate(PI);
    pg.fill(secondaryRed, secondaryGreen, secondaryBlue);
    pg.rect(i*width/120 + 1, 0, width/120, fft.calcAvg((i-1)*fft.getBandWidth()*width/120 ,i*fft.getBandWidth()*5));
    pg.popMatrix();
  }
  pg.pushMatrix();
  pg.translate(width/40, height - height/40);
  pg.rotate(-HALF_PI);
  pg.arc(0, 0, width/40, width/40, 0, TWO_PI - map(second(), 0, 60, 0, TWO_PI), PIE);
  pg.popMatrix();
  
  //pg.filter(blur);

  pg.endDraw();
}