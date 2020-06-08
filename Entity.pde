abstract class Entity {
  PVector pos;
  PVector vel;

  Entity(PVector pos, PVector vel) {
    this.pos = pos.copy();
    this.vel = vel.copy();
  }

  Entity(PVector pos) {
    this(pos, VEC(0));
  }

  abstract boolean update(float dt);
  abstract void show(float dt);

  void hit(IntersectResult intersects, float damage) {
    if (intersects != null) {
      //pa.test_type = true;
      particles.add(new Particle(intersects.first, intersects.normal_first));
      //Particle pb = new Particle(intersects.b);
      //pb.test_type = false;
      //particles.add(pb);
    }
  }
}
