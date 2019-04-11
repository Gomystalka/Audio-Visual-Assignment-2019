import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

class DefaultWave {
  float r = 10;//
  float gap = 10;//
  int circleCount;//
  color[] randColors;
  
  float time = 0;//
  
  float freq = 0.1f;//
  float mult = 40f;//
  float heightMult = 20f;//
  
  PApplet instance;
  
  public DefaultWave(PApplet instance) {
    this.instance = instance;
  }
  
  void setupSketch() {
    circleCount = PApplet.floor(instance.width / (r * 2));//
    
    randColors = new color[circleCount];
    
    for(int i = 0; i < randColors.length; i++) {
      randColors[i] = color(instance.random(0, 255), instance.random(0, 255), instance.random(0, 255));
    }
  }
  
  void drawSketch() {
    instance.pushStyle();
    instance.noStroke();//
    float x = (r * 2) / 2;//
    for(int i = 0; i < circleCount; i++) {//
      for(int k = 0; k < 14; k++) {//
        instance.fill(instance.red(randColors[i]), instance.green(randColors[i]), instance.blue(randColors[i]), k * 14);//
        instance.ellipse(x, (mult + (k * heightMult) * PApplet.sin(freq * (this.time + i)) + instance.height / 2), r, r);//
      }
      x += r * 2;//
    }
    this.time += 0.3f;//
    //time += 0.3f;
  }
  
  void borderRect(float x, float y, float w, float h, boolean top, boolean bottom, boolean left, boolean right) {
    pushStyle();
    noStroke();
    rect(x, y, w, h);
    popStyle();
    if(top) line(x, y, (x + w) - 1, y);
    if(bottom) line(x, y + h, (x + w) - 1, y + h);
    if(left) line(x, y, x, y + h);
    if(right) line(x + w, y, x + w, y + h);
  }
}
