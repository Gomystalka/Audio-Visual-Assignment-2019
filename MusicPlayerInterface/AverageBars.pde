import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

class BandBars {
  private FFT fft;
  private AudioPlayer ap;
  private PApplet instance;

  private float[] bars, lerpedBars;

  private float barWidth;
  private float barGap = 4;

  public BandBars(PApplet instance, FFT fft, AudioPlayer ap) {
    this.instance = instance;
    this.fft = fft;
    this.ap = ap;
  }

  public void setupSketch() {
    bars = new float[this.fft.avgSize()];
    lerpedBars = new float[bars.length];
    barWidth = instance.width / (float)bars.length;
  }

  public void drawSketch() {
    instance.pushStyle();
    for (int k = 0; k < bars.length; k++) {

      float amp = this.fft.getAvg(k) * ( instance.height / 35f);
      float lerpSpeed = 0.03f;

      lerpedBars[k] = PApplet.lerp(bars[k], amp, lerpSpeed);
      instance.fill(255f / (float)this.fft.avgSize() * k, 255, 255, 75);
      instance.stroke(255f / (float)this.fft.avgSize() * k, 255, 100);
      instance.rect((barWidth * k) + barGap / 2, instance.height - lerpedBars[k], barWidth - barGap, lerpedBars[k]);
      bars[k] = lerpedBars[k];
    }
    instance.popStyle();
  }
}
