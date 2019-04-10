import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

void setup()
{
  
  fullScreen();

  minim = new Minim(this);

  ai = minim.loadSample("bensound-summer.mp3", frameSize);
  ai.trigger();
  fft = new FFT(frameSize, sampleRate);
  colorMode(HSB);  

  bands = new float[10];
  lerpedBands = new float[bands.length];
}

Minim minim;
FFT fft; // Fast fourier transform
AudioSample ai;
int frameSize = 512;

int sampleRate = 44100;

float[] bands;
float[] lerpedBands;


void getFrequencyBands()
{        
  for (int i = 0; i < bands.length; i++)
  {
    int start = (int)pow(2, i) - 1;
    int w = (int)pow(2, i);
    int end = start + w;
    float average = 0;
    for (int j = start; j < end; j++)
    {
      average += fft.getBand(j) * (j + 1);
    }
    average /= (float) w;
    bands[i] = average * 5.0f;
    lerpedBands[i] = lerp(lerpedBands[i], bands[i], 0.05f);
  }
}


void draw()
{
  background(0);

  fft.window(FFT.HAMMING);
  fft.forward(ai.left);

  getFrequencyBands();
  

  float gap = width / (float) bands.length;
  noStroke();
  float colorGap = 255 / (float) bands.length;
  for (int i = 0; i < bands.length; i ++)
  {


    for (float circleNumber =0; circleNumber<5; circleNumber ++) {
     fill((i*colorGap)+(circleNumber*255/7), 255, 255-circleNumber*20);
    // fill(i * colorGap, 255, 255-circleNumber*20);
      ellipse (gap/2+(i*gap), height-(lerpedBands[i]*4)+gap*circleNumber, (gap/1.2)*lerpedBands[i]/150, (gap/1.2)*lerpedBands[i]/150);
    }
  }
}
