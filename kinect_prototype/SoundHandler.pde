AudioInput in;
Minim minim;
FFT fft;

float maxFrequency;
float maxAmplitude = 0;
int soundRange = 10;
int bandSkip = 0;

int mainRed, mainGreen, mainBlue;
int secondaryRed, secondaryGreen, secondaryBlue;
color laranjaAve = #FD5F00;
color roxoMaria = #9959B3;
color azulAnjo = #0DDEFF;
color rosaPerua = #FB0776;
color verdeSofrido = #17CD3D;
color marromDesmata = #B26100;

void setupAudio() {
  minim = new Minim(this);
  in = minim.getLineIn();
}

void transitionToColors(color mainColor, color secondaryColor) {
  if (mainRed < red(mainColor)) {
    mainRed+=6;
  } else {
    mainRed--;
  }

  if (mainGreen < green(mainColor)) {
    mainGreen+=6;
  } else {
    mainGreen--;
  }

  if (mainBlue < blue(mainColor)) {
    mainBlue+=6;
  } else {
    mainBlue--;
  }


  if (secondaryRed < red(secondaryColor)) {
    secondaryRed+=6;
  } else {
    secondaryRed--;
  }

  if (secondaryGreen < green(secondaryColor)) {
    secondaryGreen+=6;
  } else {
    secondaryGreen--;
  }

  if (secondaryBlue < blue(secondaryColor)) {
    secondaryBlue+=6;
  } else {
    secondaryBlue--;
  }
}

void createColor(char cor) {

  if (cor == 'r') {    
    transitionToColors(laranjaAve, roxoMaria);
  }

  if (cor == 'b') {
    transitionToColors(azulAnjo, rosaPerua);
  }

  if (cor == 'g') {
    transitionToColors(verdeSofrido, marromDesmata);
  }

  mainRed -=1;
  mainRed = (int) constrain(mainRed, 30, 255);
  
  mainGreen -=1;
  mainGreen = (int) constrain(mainGreen, 30, 255);
  
  mainBlue -=1;
  mainBlue = (int) constrain(mainBlue, 30, 255);
  
  secondaryRed -=1;
  secondaryRed = (int) constrain(secondaryRed, 30, 255);
  
  secondaryGreen -=1;
  secondaryGreen = (int) constrain(secondaryGreen, 30, 255);
  
  secondaryBlue -=1;
  secondaryBlue = (int) constrain(secondaryBlue, 30, 255);
}

void checkAudio()
{
  float blueAverage = fft.calcAvg(0, soundRange*fft.getBandWidth());
  float greenAverage = 3*fft.calcAvg((soundRange + bandSkip)*fft.getBandWidth(), 3*soundRange*2*fft.getBandWidth());
  float redAverage = 4*fft.calcAvg((soundRange*2 + bandSkip)*fft.getBandWidth(), 4*soundRange*3*fft.getBandWidth());
  
  if (maxAmplitude > 0.01){
    if (blueAverage > greenAverage && blueAverage > redAverage){
      createColor('b');
    }
    else if (greenAverage > redAverage){
      createColor('g');
    }
    else{
      createColor('r');
    }
  }
  else{
    createColor('n');
  }
  //if (maxAmplitude > 0.01) {
  //  if (maxFrequency <= 15) {
  //    createColor('b');
  //  } else if (maxFrequency > 15 && maxFrequency <= 20) {
  //    createColor('g');
  //  } else if (maxFrequency > 20) {
  //    createColor('r');
  //  }
  //} else {
  //  createColor('n');
  //}
 
  fft.forward(in.mix);

  float maxFrequencyBand = 0;
  for (int i = 0; i < fft.specSize(); i++)
  {
    if (fft.getBand(i) > maxFrequencyBand) {
      maxFrequency = i;
      maxFrequencyBand = fft.getBand(i);
    }
  }
  
  maxAmplitude = in.left.level() + in.right.level();
}