import ddf.minim.*;
import ddf.minim.analysis.*;

AudioInput in;
Minim minim;
FFT fft;

float maxFrequency;
float maxAmplitude = 0;

void setupAudio(){
  minim = new Minim(this);
  in = minim.getLineIn();
}

void createColor(char cor){
   if (cor == 'r'){
     r += 40*maxAmplitude;
     g += 4*maxAmplitude;
     b += 4*maxAmplitude;
   }
   
   if (cor == 'g'){
     g += 40*maxAmplitude;
     r += 4*maxAmplitude;
     b += 4*maxAmplitude;
   }
   
   if (cor == 'b'){
     b += 40*maxAmplitude;
     r += 4*maxAmplitude;
     g += 4*maxAmplitude;
   }
   
   r -= 0.66;
   g -= 0.66;
   b -= 0.66;
   
   r = constrain(r, 100, 255.0);
   g = constrain(g, 100, 255.0);
   b = constrain(b, 100, 255.0);
 }

void checkAudio()
{
  if (maxFrequency <= 10){
    createColor('b');
  }
  
  if (maxFrequency > 10 && maxFrequency <= 20){
    createColor('g');
  }
  
  if (maxFrequency > 20){
    createColor('r');
  }

  fft.forward(in.mix);
 
  float maxFrequencyBand = 0;
  for(int i = 0; i < fft.specSize(); i++)
  {
    if (fft.getBand(i) > maxFrequencyBand){
      maxFrequencyBand = fft.getBand(i);
      maxFrequency = i;
    }
  }
  
  maxAmplitude = in.left.level() + in.right.level();
}