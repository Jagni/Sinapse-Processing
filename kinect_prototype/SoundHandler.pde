AudioInput in;
Minim minim;
FFT fft;

float maxFrequency;
float maxAmplitude = 0;

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
    mainRed++;
  } else {
    mainRed--;
  }
  
  if (mainGreen < green(mainColor)) {
    mainGreen++;
  } else {
    mainGreen--;
  }
  
  if (mainBlue < blue(mainColor)) {
    mainBlue++;
  } else {
    mainBlue--;
  }
  
  
  if (secondaryRed < red(secondaryColor)) {
    secondaryRed++;
  } else {
    secondaryRed--;
  }
  
  if (secondaryGreen < green(secondaryColor)) {
    secondaryGreen++;
  } else {
    secondaryGreen--;
  }
  
  if (secondaryBlue < blue(secondaryColor)) {
    secondaryBlue++;
  } else {
    secondaryBlue--;
  }
}

void createColor(char cor) {

  if (cor == 'r') {    
    transitionToColors(laranjaAve, roxoMaria);
    //r += 4;
    //g --;
    //b --;
  }

  if (cor == 'g') {
    transitionToColors(azulAnjo, rosaPerua);
    //g += 4;
    //r --;
    //b --;
  }

  if (cor == 'b') {
    transitionToColors(verdeSofrido, marromDesmata);
    //b += 4;
    //r --;
    //g --;
  }

  //r--;
  //g--;
  //b--;

  //r = constrain(r, 100, 255.0);
  //g = constrain(g, 100, 255.0);
  //b = constrain(b, 100, 255.0);
}

void checkAudio()
{

  if (maxFrequency <= 7) {
    createColor('b');
  }

  if (maxFrequency > 7 && maxFrequency <= 12) {
    createColor('g');
  }

  if (maxFrequency > 17) {
    createColor('r');
  }

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