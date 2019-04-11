import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

class BubbleSketch {
  PApplet instance;
  AudioPlayer globalPlayer;
  Minim minim;
  FFT fft;
  int frameSize = 512;
  int sampleRate = 44100;
  float[] bands;
  float[] lerpedBands;

  public BubbleSketch(PApplet instance, Minim minim, FFT fft, AudioPlayer globalPlayer) {
    this.instance = instance;
    this.minim = minim;
    this.fft = fft;
    this.globalPlayer = globalPlayer;
  }

  void setupSketch() {
    this.bands = new float[10];
    this.lerpedBands = new float[this.bands.length];
  }

  void getFrequencyBands() {        
    for (int i = 0; i < this.bands.length; i++) {
      int start = (int)pow(2, i) - 1;
      int w = (int)pow(2, i);
      int end = start + w;
      float average = 0;
      
      for (int j = start; j < end; j++) {
        average += this.fft.getBand(j) * (j + 1);
      }
      average /= (float) w;
      this.bands[i] = average * 5.0f;
      this.lerpedBands[i] = PApplet.lerp(this.lerpedBands[i], this.bands[i], 0.05f);
    }
  }

  public void drawSketch() {
    //instance.background(0);
    instance.pushStyle();
    instance.colorMode(HSB);
//this.fft.window(FFT.HAMMING);
    //this.fft.forward(globalPlayer.mix);

    getFrequencyBands();

    float gap = instance.width / (float) bands.length * 1.1f;
    instance.noStroke();
    float colorGap = 255 / (float) bands.length;
    for (int i = 0; i < bands.length; i ++) {
      for (float circleNumber =0; circleNumber<5; circleNumber ++) {
        instance.fill((i*colorGap)+(circleNumber*255/7), 255, 255 - circleNumber*20, 255 / 5 * circleNumber);
        float r = (gap/1.2)*this.lerpedBands[i] / width;
        instance.ellipse(i * gap, instance.height - (this.lerpedBands[i] / 4) + gap * circleNumber, r, r);
        //instance.ellipse (gap/2+(i*gap), constrain(instance.height-(this.lerpedBands[i] * 4) + gap*circleNumber, 0, height), (gap/1.2)*this.lerpedBands[i]/width, r);
      }
    }
    instance.popStyle();
  }
}
