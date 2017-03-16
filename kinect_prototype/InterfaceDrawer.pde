float squareSize;

void drawInterface(PGraphics pg){
  pg.beginDraw();
  pg.background(0, 0);
  squareSize = height/30;
  pg.fill(0, 0);
  pg.stroke(183, 244, 245);
  pg.pushMatrix();
  pg.strokeWeight(3);
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
  
  //Microfone
  for(int i = 0; i <= 4; i++)  {
    pg.pushMatrix();
    float squareHeight = 1.5*fft.calcAvg(i*soundRange, (i+1)*fft.getBandWidth()*soundRange/2);
    //float squareHeight = fft.calcAvg(soundRange*(i-1)*fft.getBandWidth() ,*fft.getBandWidth());
    pg.translate(width - width/50, (height - height/50));
    pg.rotate(PI);
    pg.fill(183, 244, 245);
    pg.rect((i*width/300) + i*5, -squareHeight/2, width/350, squareHeight);
    pg.popMatrix();
  }
  
  //Tempo
  pg.pushMatrix();
  pg.noFill();
  pg.translate(width/25, height - height/25);
  pg.rotate(-HALF_PI);
  pg.arc(0, 0, width/40, width/40, 0, TWO_PI - map(millis(), 0, 60000, 0, TWO_PI), OPEN);
  pg.popMatrix();
  
  //pg.filter(blur);

  pg.endDraw();
}