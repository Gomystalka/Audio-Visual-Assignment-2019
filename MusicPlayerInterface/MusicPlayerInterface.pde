import ddf.minim.*; //<>//
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.awt.Frame;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.event.FocusListener;
import java.awt.event.FocusEvent;
import java.awt.Color;
import javax.swing.JDialog;
import javax.swing.ImageIcon;

import processing.awt.PSurfaceAWT;

Minim m;
AudioPlayer ap;
String fileName = "bensound-summer.mp3";

float val = 50;

long position;
int[] time;
int[] nextTime;

int lastSecond;

float sideGap = 24;
float barW, barH;

int nextPos;
float barSize, barSizePh;

java.awt.geom.Rectangle2D.Float progressBar;
java.awt.geom.Rectangle2D.Float handle;

float handleX;

boolean[] inputMap = new boolean[1024];
boolean interacting = false;
boolean canChangePosition = false;
boolean paused = false;
boolean end;

public boolean[] keys = new boolean[1024];

float volumeChangeTimer;
float volumeTimerTarget;

SecondaryWindow sw;
PSurfaceAWT.SmoothCanvas canvas;
Frame fr;

boolean attached = true;

void settings() {
  size(500, 200);
  end = false;
  m = new Minim(this);
  ap = m.loadFile(fileName);
  if(ap == null) {
    javax.swing.JOptionPane.showMessageDialog(null, "Invalid file path.");
    System.exit(-1);
  }
  ap.play();

  setVolume(ap, 50);

  barW = width - sideGap;
  barH = 10;

  handleX = sideGap / 2;

  progressBar = new java.awt.geom.Rectangle2D.Float(sideGap / 2, height - barH - sideGap / 2, barW, barH);
  handle = new java.awt.geom.Rectangle2D.Float(handleX, (height - barH - sideGap / 2) + (barH / 2), barH, barH);

  volumeTimerTarget = frameRate * 2.5f;
  volumeChangeTimer = volumeTimerTarget;
}

void setup() {
  surface.setTitle("Now playing - " + fileName);

  sw = new SecondaryWindow();
  //sw.setSizeVector(height * 3, height * 3);
  sw.setSizeVector(1000, 800);
  
  sw.run(this);

  sw._frame.setFocusable(true);

  sw._frame.addComponentListener(new ComponentAdapter() {
    @Override
      public void componentMoved(ComponentEvent ce) {
      if (fr != null && attached) {
        if (sw._canvas.hasFocus()) {
          surface.setLocation(sw._frame.getLocation().x - width, sw._frame.getLocation().y);
        }
      }
    }
  }
  );

  canvas = (PSurfaceAWT.SmoothCanvas)getSurface().getNative();
  fr = getFrameInstance(surface);
  fr.setFocusable(true);

  fr.addComponentListener(new ComponentAdapter() {
    @Override
      public void componentMoved(ComponentEvent ce) {
      if (!sw._canvas.hasFocus() && attached) {
        sw.getSurface().setLocation(fr.getLocation().x + width + 1, fr.getLocation().y);
      }
    }
  }
  );

  sw.getSurface().setTitle("Visualization");
  sw.getSurface().setLocation(fr.getLocation().x + width + 1, fr.getLocation().y);
  //createSecondaryDialog();
}

public Frame getFrameInstance(PSurface surf) {
  if (surf == null) return null;
  return ((PSurfaceAWT.SmoothCanvas) surf.getNative()).getFrame();
}

//Deprecated as a new JDialog does not inherit the drawing abilities of a PSurface
/*
@Deprecated
 void createSecondaryDialog() {
 dia = new JDialog();
 //dia.setUndecorated(true);
 dia.setResizable(false);
 dia.setTitle("Playlist");
 dia.setSize(width / 2, height * 3);
 dia.setIconImage(fr.getIconImage());
 dia.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
 dia.getContentPane().setBackground(Color.black);
 dia.setLocation((fr.getLocation().x + width / 2) + dia.getWidth() + 1, fr.getLocation().y);
 dia.setVisible(true);
 //dia.setIcon();
 }
 */

void mouseWheel(MouseEvent event) {
  val -= event.getCount();
  val = constrain(val, 0, 100);
  setVolume(ap, int(val));
  volumeChangeTimer = 0;
}

void keyReleased() {
  keys[keyCode] = false;
  if (keyCode == java.awt.event.KeyEvent.VK_SPACE) {
    if(!end) {
      toggleState();
    } else {
      paused = false;
      ap.play(0);
      end = false;
    }
  }
  
  switch(keyCode) {
    case java.awt.event.KeyEvent.VK_1:
      sw.mode[0] = !sw.mode[0];
      break;
    case java.awt.event.KeyEvent.VK_2:
      sw.mode[1] = !sw.mode[1];
      break;
    case java.awt.event.KeyEvent.VK_3:
      sw.mode[2] = !sw.mode[2];
      break;
    case java.awt.event.KeyEvent.VK_4:
      sw.mode[3] = !sw.mode[3];
      break;
    case java.awt.event.KeyEvent.VK_5:
      sw.mode[4] = !sw.mode[4];
      break;
    }
}

void keyPressed() {
  keys[keyCode] = true;
}

void toggleState() {
  if (ap.isPlaying()) {
    ap.pause();
    paused = true;
    surface.setTitle("Now playing - " + fileName + " - Paused");
  } else {
    ap.play();
    paused = false;
    surface.setTitle("Now playing - " + fileName);
  }
}

void setVolume(AudioPlayer ap, int volumePercentage) {
  float volume = map(volumePercentage, 0, 100, -80, 5);
  ap.setGain(volume);
  if (volumePercentage <= 0) {
    if (!ap.isMuted()) {
      ap.mute();
    }
  } else {
    if (ap.isMuted()) {
      ap.unmute();
    }
  }
}

void draw() {
  background(0);
  
  fr.setAlwaysOnTop(!attached);

  if (sw != null) {
    sw.drawing = ap.isPlaying();
  }

  position = ap.position();

  time = convertTime(position);

  if (interacting && !inputMap[java.awt.event.MouseEvent.BUTTON1]) {
    interacting = false;
  }

  if (!interacting && inputMap[java.awt.event.MouseEvent.BUTTON1] && handle.contains(mouseX, mouseY)) {
    interacting = true;
    paused = false;
    end = false;
  }

  fill(255);
  textAlign(CENTER, TOP);
  textSize(72);
  textf("%s%s:%s%s:%s%s", 0, 0, width, height, (time[3] < 10 ? "0" : ""), time[3], (time[2] < 10 ? "0" : ""), time[2], (time[1] < 10 ? "0" : ""), time[1]);

  fill(255, 0, 255);
  textSize(16);
  textAlign(LEFT, TOP);
  float textHeight = textAscent() + textDescent();

  if (volumeChangeTimer < volumeTimerTarget) {
    volumeChangeTimer++;
    textf("Volume: %s", sideGap / 2, handle.y - barH - textHeight, barW, textHeight + 2, int(val) + "%");
  }

  textAlign(CENTER, CENTER);
  fill(255, 255, 0);
  textSize(10);
  textHeight = textAscent() + textDescent();

  if (interacting) {
    canChangePosition = true;
    barSizePh = mouseX - (sideGap / 2);
    nextPos = int(map(barSizePh, 0, barW, 0, ap.length()));
    nextTime = convertTime(nextPos);
    volumeChangeTimer = volumeTimerTarget;
  } else {
    if (canChangePosition) {
      canChangePosition = false;
      barSize = barSizePh;
      paused = false;
      ap.play(nextPos);
      if (ap.position() == nextPos) {
        interacting = false;
      }
    }
  }

  if (interacting) {
    float wdth = textWidth("XXXXXXXXX");
    float textX = handleX - (wdth / 2);
    textX = constrain(textX, (sideGap / 2) - 5, barW - (wdth / 2) - sideGap / 2);
    textf("%s%s:%s%s:%s%s", textX, handle.y - barH - textHeight, wdth, textHeight + 2, (nextTime[3] < 10 ? "0" : ""), nextTime[3], (nextTime[2] < 10 ? "0" : ""), nextTime[2], (nextTime[1] < 10 ? "0" : ""), nextTime[1]);
  }

  if (!interacting) { 
    handleX = map(position, 0, ap.length(), sideGap / 2, barW + sideGap / 2);
  } else {
    handleX = mouseX;
    handleX = constrain(handleX, sideGap / 2, barW + sideGap / 2);
  }

  if (paused) {
    if (sin(frameCount / 10) > 0) {
      textSize(64);
      fill(255, 215, 0);
      text("PAUSED", 0, 16, width, height);
    }
  }

  if (!paused && !ap.isPlaying()) {
    end = true;
    textSize(64);
    fill(115, 15, 0);
    text("END", 0, 16, width, height);
  }

  noStroke();
  fill(100, 0, 0);
  rect(sideGap / 2, height - barH - sideGap / 2, barW, barH);
  fill(255, 0, 0);
  rect(sideGap / 2, height - barH - sideGap / 2, handleX - sideGap / 2, barH);
  stroke(150, 10, 10);
  ellipse(handle.x + (handle.height) / 2, handle.y + (handle.height / 2), handle.width, handle.height);

  updateComponents();
}

void updateComponents() {
  progressBar = new java.awt.geom.Rectangle2D.Float(sideGap / 2, height - barH - sideGap / 2, barW, barH);
  handle = new java.awt.geom.Rectangle2D.Float(handleX - (barH + 2) / 2, (height - (barH + 2.5f) - sideGap / 2), barH + 5, barH + 5);
}

void mousePressed() {
  if (progressBar.contains(mouseX, mouseY) && !handle.contains(mouseX, mouseY) && !interacting) {
    barSize = mouseX - (sideGap / 2);
    int pos = int(map(barSize, 0, barW, 0, ap.length()));
    paused = false;
    end = false;
    ap.play(pos);
  }

  inputMap[java.awt.event.MouseEvent.BUTTON1] = true;
}

void mouseReleased() {
  inputMap[java.awt.event.MouseEvent.BUTTON1] = false;
}

public int[] convertTime(long millis) {
  millis = (long)constrain(millis, 0, ap.length());

  float seconds = int(floor(millis / 1000));
  float secondsI = int(floor(seconds % 60));

  float minutes = int(floor(seconds / 60));
  float minutesI = int(floor(minutes % 60));

  float hours = int(floor(minutes / 60));
  float hoursI = int(floor(hours % 60));

  return new int[] {int(millis), int(secondsI), int(minutesI), int(hoursI), int(seconds) /*Return seconds to use as a timer*/};
}

public void printf(String format, Object... args) {
  System.out.printf(format + "\n", args);
}

public void textf(String s, float x, float y, float w, float h, Object... args) {
  java.util.Formatter f = new java.util.Formatter();
  s = f.format(s, args).toString();

  if (w <= 0 || h <= 0) {
    text(s, x, y);
  } else {
    text(s, x, y, w, h);
  }
  f.close();
}
