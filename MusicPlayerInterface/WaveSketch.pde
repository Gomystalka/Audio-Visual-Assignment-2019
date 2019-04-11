import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

class Wave {
  private PApplet instance;
  private AudioPlayer ap;
  
  ArrayList<PVector> points = new ArrayList<PVector>();
  ArrayList<Float> pointLife = new ArrayList<Float>();
  ArrayList<Integer> colors = new ArrayList<Integer>();
  
  private float[] bands, lerpedBands;
  private int bandCount = 128;
  private float x;
  private float ww;
  
  public boolean drawing = true;

  public Wave(PApplet instance, AudioPlayer ap) {
    this.instance = instance;
    this.ap = ap;
  }

  public void setupSketch() {
    ww = (instance.width + instance.width / 8) / (float)bandCount;

    bands = new float[int(bandCount)];
    lerpedBands = new float[int(bandCount)];
  }

  private void drawSketch() {
    instance.pushStyle();
    for (int j = 0; j < bandCount; j++) {
      //float infft = fft.getBand((int(map(j, 0, bandCount, 0, fft.specSize()))));
      float in = ap.mix.get(int(map(j, 0, bandCount, 0, ap.bufferSize())));
      //float in = fft.getFreq(int(map(j, 0, bandCount, 0, 10000)));
      //float in = fft.getFreq(j);

      //float in = fft.getBand(relevantBands.get(j));
      //float in = fft.getAvg(int(map(j, 0, relevantBands.size(), 0, fft.avgSize())));

      if (drawing) {
        bands[j] = PApplet.lerp(lerpedBands[j], in * instance.height * 2, 0.05f);
      } else {
        bands[j] = PApplet.lerp(lerpedBands[j], 0, 0.05f);
      }
      lerpedBands[j] = bands[j];
    }
    x = ww / 2;

    for (int i = 0; i < bandCount; i++) {
      instance.noStroke();
      float h = lerpedBands[i];

      int hue = int(PApplet.map(i, 0, bandCount, 0, 255));
      instance.fill(hue, 255, 255);

      points.add(new PVector(x, ((instance.height / 2) - h - (ww / 2))));
      pointLife.add(255f);
      colors.add(hue);

      instance.ellipse(x, ((instance.height / 2) - h - (ww / 2)), ww, ww);
      x += ww;
    }
    x = 0;
    instance.noStroke();

    for (int i = points.size() - 1; i >= 0; i--) {
      PVector v = points.get(i);
      float life = pointLife.get(i);
      int hue = colors.get(i);

      life -= 25;
      pointLife.set(i, life);

      if (life <= 0) {
        points.remove(i);
        pointLife.remove(i);
      }

      instance.noStroke();
      instance.fill(hue, 255, 255, life / 2);
      instance.ellipse(v.x, v.y, ww / 2, ww / 2);
    }
    instance.popStyle();
  }
}
