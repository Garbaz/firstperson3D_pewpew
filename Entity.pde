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

  abstract void update(float dt);
  abstract void show(float dt);

  void hit(VecPair intersects, float damage) {
  }
}
