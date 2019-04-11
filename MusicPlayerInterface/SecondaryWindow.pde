import java.awt.Frame;
import processing.awt.PSurfaceAWT;
import processing.core.PSurface;
import processing.core.PApplet;

class SecondaryWindow extends PApplet {

  private int modeCount = 5;
  public boolean[] mode = new boolean[modeCount];

  private PApplet mainApp;
  public Frame _frame;
  public PSurfaceAWT.SmoothCanvas _canvas;
  private PVector size = new PVector();
  
  private float timer;
  private float timeLimit;

  boolean reverse = false;
  public boolean drawing = true;
  private boolean canResize = true;

  private FFT fft;

  BubbleSketch bubble;
  SquarePulse squares;
  DefaultWave defaultWave;
  Wave wave;
  BandBars bars;
  Projectiles projectiles;

  public void run(PApplet app) {
    this.mainApp = app;
    runSketch();
    _frame = getFrameInstance(this.getSurface());
    _canvas = (PSurfaceAWT.SmoothCanvas)getSurface().getNative();
  }

  public void keyPressed() {
    mainApp.keyCode = keyCode;
    mainApp.keyPressed();
  }

  public void keyReleased() {
    mainApp.keyCode = keyCode;
    mainApp.keyReleased();
  }

  public void settings() {
    size(int(size.x), int(size.y));
    //fullScreen();
    fft = new FFT(ap.bufferSize(), ap.sampleRate());
    fft.logAverages(22, 3);

    setupObjects();
  }

  public void setupObjects() {
    bars = new BandBars(this, fft);
    bars.setupSketch();
    
    projectiles = new Projectiles(this);

    wave = new Wave(this, ap);
    wave.setupSketch();

    bubble = new BubbleSketch(this, m, fft, ap);
    bubble.setupSketch();

    squares = new SquarePulse(this, ap);
    squares.setupSketch();

    defaultWave = new DefaultWave(this);
    defaultWave.setupSketch();
    
    timeLimit = random(2, 60);
  }

  public void setup() {
    colorMode(HSB);

    //mode[4] = true;
    //mode[3] = true;
    //mode[2] = true;
    //mode[1] = true;
    //mode[0] = true;
  }

  public void draw() {
    background(0);

    fft.window(FFT.HAMMING);
    fft.forward(ap.mix);

    if (squares != null) {
      if (mode[0])
        squares.drawSketch();
    }

    if (bubble != null) {
      if (mode[1])
        bubble.drawSketch();
    }

    if (bars != null) {
      if (mode[2])
        bars.drawSketch();
    }

    if (wave != null) {
      wave.drawing = drawing;
      if (mode[3])
        wave.drawSketch();
    }
    
    if(projectiles != null) {
      if(mode[4])
        projectiles.drawSketch();
    }

    if (keys[java.awt.event.KeyEvent.VK_ALT] && keys[java.awt.event.KeyEvent.VK_ENTER] && canResize) {
      canResize = false;
      if (!_frame.isResizable()) {
        attached = false;
        _frame.setResizable(true);
        java.awt.Dimension dim = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
        _frame.setSize(dim.width + 5, dim.height);
        _frame.setLocationRelativeTo(null);
        _frame.setAlwaysOnTop(true);
        fr.setLocation(0, 0);
      } else {
        _frame.setResizable(false);
        _frame.setSize(int(size.x), int(size.y));
        this.width = int(size.x);
        this.height = int(size.y);
        _frame.setAlwaysOnTop(false);
        _frame.setLocationRelativeTo(null);
        fr.setLocation(0, 0);
        attached = true;
      }

      try {
        Thread.sleep(100);
      } 
      catch(Exception e) {
      }
      setupObjects();
    }
    
    if(timer >= timeLimit && mode[4] && ap.isPlaying()) {
      timeLimit = random(2, 60);
      timer = 0;
      for(int i = 0; i < 1; i++) {
        projectiles.spawnProjectile();
      }
    }
    
    if(mode[4]) {
      timer++;
    }


    if (!keys[java.awt.event.KeyEvent.VK_ALT] && !keys[java.awt.event.KeyEvent.VK_ENTER]) {
      canResize = true;
    }
    //drawWave();

    boolean active = false;
    for (boolean b : mode) {
      if (b) {
        active = true;
        break;
      }
    }

    if (!active) {
      pushStyle();
      colorMode(RGB);
      fill(255, 0, 0);
      float tS = 32;
      textSize((tS * abs(sin(radians(frameCount * 1.5f)))) + tS * 1.5f);
      //textSize(sin(frameCount / 4) + 10 * 20);
      textAlign(CENTER, TOP);
      text("No modes selected", 0, 0, width, height);
      popStyle();

      if (defaultWave != null) {
        defaultWave.drawSketch();
      }
    }
  }

  public Frame getFrameInstance(PSurface surf) {
    if (surf == null) return null;
    return ((PSurfaceAWT.SmoothCanvas) surf.getNative()).getFrame();
  }

  public PSurface getSurface() {
    return surface;
  }

  public void setSizeVector(float w, float h) {
    size.x = w;
    size.y = h;
  }

  public PVector getSizeVector() {
    return size;
  }
}
