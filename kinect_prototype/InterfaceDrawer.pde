float squareSize;

void drawInterface(PGraphics pg){
  pg.beginDraw();
  squareSize = height/40;
  pg.fill(0);
  pg.stroke(secondaryRed, secondaryGreen, secondaryBlue);
  pg.pushMatrix();
  pg.strokeWeight(2);
  pg.translate(width/2, height/20);
  pg.line(-1.5*squareSize, squareSize*0.74, -1, 1.5*squareSize, squareSize*0.74, -1);
  pg.popMatrix();
  
  pg.pushMatrix();
  pg.translate(width/2 - 1.5*squareSize, height/20);
  pg.rotate(PI/4);
  pg.rect(0, 0, squareSize, squareSize);
  pg.popMatrix();
  
  pg.pushMatrix();
  pg.translate(width/2 + 1.5*squareSize, height/20);
  pg.rotate(PI/4);
  pg.rect(0, 0, squareSize, squareSize);
  pg.popMatrix();
  
  fft.forward(in.mix);
  
  for(int i = 1; i <= 3; i++)  {
    pg.pushMatrix();
    pg.translate(width - 10, height - 75);
    pg.rotate(PI);
    pg.fill(secondaryRed, secondaryGreen, secondaryBlue);
    pg.rect(i*15, 0, 10, fft.calcAvg((i-1)*fft.getBandWidth()*5 ,i*fft.getBandWidth()*5));
    pg.popMatrix();
  }
  pg.pushMatrix();
  pg.translate(55, height - 100);
  pg.rotate(-HALF_PI);
  pg.arc(0, 0, 45, 45, 0, TWO_PI - map(second(), 0, 60, 0, TWO_PI), PIE);
  pg.popMatrix();
  
  pg.filter(blur);

  pg.endDraw();
}