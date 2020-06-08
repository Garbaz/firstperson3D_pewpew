ArrayList<Particle> particles = new ArrayList<Particle>();

class Particle extends Entity {
  final color COLOR = #111111;
  final float SIZE = 0.5;
  final float LIFETIME = 0.1;
  float timer = 0;

  PVector dir;

  //boolean test_type = false;

  Particle(PVector pos, PVector dir) {
    super(pos);
    this.dir = dir.copy();
    shot_impact_particle_shader.set("weight", SIZE);
  }

  boolean update(float dt) {
    timer += dt;
    if (timer > LIFETIME) {
      return false;
    }
    return true;
  }

  void show(float dt) {
    push();
    translate(pos.x, pos.y, pos.z);
    shader(shot_impact_particle_shader);
    strokeCap(SQUARE);
    strokeWeight(SIZE);
    stroke(COLOR);
    point(0, 0, 0);
    resetShader();
    stroke(#ff0000);
    strokeWeight(1);
    line(0, 0, 0, dir.x, dir.y, dir.z);
    
    //if(test_type) {
    //  fill(#ff0000);
    //} else {
    //  fill(#00ff00);
    //}
    //noStroke();
    ////box(0.1, 10, 0.1);
    //sphere(0.05);
    pop();
  }
}
