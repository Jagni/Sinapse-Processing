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
     r += 4;
     g --;
     b --;
   }
   
   if (cor == 'g'){
     g += 4;
     r --;
     b --;
   }
   
   if (cor == 'b'){
     b += 4;
     r --;
     g --;
   }
   
   r--;
   g--;
   b--;
   
   r = constrain(r, 100, 255.0);
   g = constrain(g, 100, 255.0);
   b = constrain(b, 100, 255.0);
 }

void checkAudio()
{
  
  if (maxFrequency <= 5){
    createColor('b');
  }
  
  if (maxFrequency > 5 && maxFrequency <= 10){
    createColor('g');
  }
  
  if (maxFrequency > 15){
    createColor('r');
  }

  fft.forward(in.mix);
 
  float maxFrequencyBand = 0;
  for(int i = 0; i < fft.specSize(); i++)
  {
    if (fft.getBand(i) > maxFrequencyBand){
      maxFrequency = i;
      maxFrequencyBand = fft.getBand(i);
    }
  }
  println(fft.getBandWidth());
  maxAmplitude = in.left.level() + in.right.level();
}