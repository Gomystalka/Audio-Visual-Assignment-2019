import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

class SquarePulse {
  ArrayList <Sq> sqr= new ArrayList<Sq>();
  int count=100;
  Sq s;
  AudioPlayer globalPlayer;
  PApplet instance;

  public SquarePulse(PApplet instance, AudioPlayer globalPlayer) {
    this.instance = instance;
    this.globalPlayer = globalPlayer;
  }

  public void setupSketch() {
    s = new Sq();
    //rectMode(CENTER);
    for (int i=0; i<count; i++) {
      sqr.add(new Sq());
    }

    ///ai = minim.loadSample("goka.mp3", width);
    //ai.trigger();
  }

  public void drawSketch() {
    //instance.background(0);
    instance.pushStyle();
    instance.pushMatrix();
    instance.rectMode(CENTER);
    instance.colorMode(HSB);
    s.drawSq();
    for (int i=0; i< sqr.size(); i++) {
      instance.stroke((255 / count) * i, 255, 255, 20);
      sqr.get(i).drawSq();
    }
    instance.popStyle();
    instance.popMatrix();
  }

  class  Sq {
    float x;
    float y;
    float speed;
    int b;
    float xy;
    float with;
    float c;

    public Sq() {
      c =instance.random(0, 255);
      xy=instance.random(0, 1000);
      x=xy; 
      y=xy;
      speed=instance.random(1, 5);
      b=50;
      with=instance.random(1, 5);
    }

    void drawSq() {
      instance.strokeWeight(with);
      instance.noFill();
      x+=speed;
      y+=speed;
      //instance.stroke(255 / sqr.size() * sqr.indexOf(this), 255, 255, 20);
      instance.rect(instance.width/2, instance.height/2, x, y);
      if (x>=1200) {
        x=0;
        y=0;
        for (int i = 0; i < globalPlayer.bufferSize(); i ++) {
          speed = PApplet.abs(instance.random(1, 5)+globalPlayer.mix.get(i)*100) ;  
      }
        with=instance.random(1, 5);
        c=instance.random(0, 255);
      }
    }
  }
}
