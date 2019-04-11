class Projectiles {
  private ArrayList<Particle> particles = new ArrayList<Particle>();
  private PApplet instance;
  
  public Projectiles(PApplet instance) {
    this.instance = instance;
  }

  public void drawSketch() {
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle particle = particles.get(i);
      particle.update();
      particle.render();
      if (particle.dead) {
        particles.remove(i);
      }
    }
  }

  public void spawnProjectile() {
    boolean dir = int(instance.random(0, 2)) == 0 ? true : false;

    Particle particle = new Particle(dir);
    particle.position.y = instance.random(instance.height / 2f, instance.height - particle.size);

    particle.position.x = dir ? instance.random(-100, -particle.size) : instance.random(instance.width + 100, instance.width);

    particles.add(particle);
  }

  class Particle {
    private ArrayList<Segment> trailSegments = new ArrayList<Segment>();

    public PVector position, velocity;

    float tvY = 100f, drag = 0.005f;

    public static final float G = 9.8f, timeDelta = 1.0f/60.0f;

    public float acc = 1f;
    public float size = 20f;
    public boolean dead = false;

    public Particle(boolean dir) {
      position = new PVector(0, 0);
      velocity = new PVector(0, 0);

      float dirf = dir ? 1f : -1f;
      velocity.x = acc * instance.random(6f, 20f) * dirf;
      velocity.y = -(acc * instance.random(6f, 16f));
    }

    public void update() {
      position.x += velocity.x;
      position.y += velocity.y;

      //velocity.x += acc * timeDelta;
      //velocity.y -= 1f * timeDelta;

      if (velocity.y < tvY) { 
        velocity.y += G * timeDelta;
      } else {
        velocity.y = tvY;
      }

      if (trailSegments.size() > 0) {
        if (trailSegments.get(0).y > instance.height + size) {
          //velo
          dead = true;
          //instance.spawnProjectile();
        }
      }

      //if(trailSegments.size() < 12) {
      Segment s = new Segment(position.x, position.y);
      s.lifeDecrease = 12;
      trailSegments.add(s);
      //}
    }

    public void render() {
      for (int i = trailSegments.size() - 1; i >= 0; i--) {
        Segment seg = trailSegments.get(i);
        seg.update();

        if (seg.dead) {
          trailSegments.remove(i);
        }

        instance.pushStyle();
        instance.colorMode(HSB);
        instance.noStroke();
        instance.fill(255 / trailSegments.size() * PApplet.map(i, trailSegments.size() - 1, 0, 0, trailSegments.size() - 1), 255, 255, seg.life);
        instance.ellipse(seg.x, seg.y, size / 2, size / 2);
        instance.popStyle();
      }
    }
    class Segment {
      public float x, y;
      public float life, lifeDecrease = 10f;
      public boolean dead = false;

      public Segment(float x, float y) {
        this.life = 255;
        this.x = x;
        this.y = y;
      }

      public void update() {
        life -= lifeDecrease;

        if (life <= 0) {
          life = 0;
          dead = true;
        }
      }
    }
  }
}
